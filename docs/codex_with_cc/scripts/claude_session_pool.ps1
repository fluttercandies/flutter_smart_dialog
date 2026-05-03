Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-ClaudeSessionId {
  return [guid]::NewGuid().ToString()
}

function Get-EffectiveSessionKey {
  param([string]$Value)

  if (-not [string]::IsNullOrWhiteSpace($Value)) {
    return $Value
  }
  if (-not [string]::IsNullOrWhiteSpace($env:CODEX_THREAD_ID)) {
    return $env:CODEX_THREAD_ID
  }
  if (-not [string]::IsNullOrWhiteSpace($env:CODEX_SESSION_ID)) {
    return $env:CODEX_SESSION_ID
  }
  Write-Warning 'Using default Claude session key fallback. Pass -SessionKey explicitly or set CODEX_THREAD_ID / CODEX_SESSION_ID to avoid unintended session sharing.'
  return 'default'
}

function Get-SafeSessionKey {
  param([string]$Value)

  $safe = $Value -replace '[^A-Za-z0-9_.-]', '_'
  if ([string]::IsNullOrWhiteSpace($safe)) {
    return 'default'
  }
  return $safe
}

function Normalize-ClaudeDelegateList {
  param([string[]]$Items = @())

  $normalized = @()
  foreach ($item in @($Items)) {
    if ([string]::IsNullOrWhiteSpace([string]$item)) {
      continue
    }
    foreach ($part in ([string]$item -split '\s*;\s*')) {
      if (-not [string]::IsNullOrWhiteSpace($part)) {
        $normalized += $part.Trim()
      }
    }
  }
  return @($normalized)
}

function Get-TaskFingerprint {
  param(
    [string]$Text,
    [string[]]$ScopeItems,
    [string[]]$TestItems,
    [string]$TaskMode
  )

  $prefix = if ($Text.Length -gt 1000) { $Text.Substring(0, 1000) } else { $Text }
  $raw = @(
    "mode=$TaskMode"
    "scope=$(($ScopeItems | Sort-Object) -join '|')"
    "tests=$(($TestItems | Sort-Object) -join '|')"
    "task=$prefix"
  ) -join "`n"
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
  $hashBytes = [System.Security.Cryptography.SHA256]::HashData($bytes)
  return [Convert]::ToHexString($hashBytes).ToLowerInvariant()
}

function Test-LeaseExpired {
  param(
    [object]$Item,
    [int]$TimeoutSeconds
  )

  if ($null -eq $Item -or $TimeoutSeconds -lt 0) {
    return $false
  }
  if ($Item.status -ne 'leased') {
    return $false
  }
  if ($null -eq $Item.leasedAt -or [string]::IsNullOrWhiteSpace([string]$Item.leasedAt)) {
    return $true
  }
  try {
    $leasedAt = [DateTimeOffset]::Parse([string]$Item.leasedAt)
  } catch {
    return $true
  }
  return ([DateTimeOffset]::Now - $leasedAt).TotalSeconds -ge $TimeoutSeconds
}

function New-SessionPoolState {
  param([string]$Key)

  $now = (Get-Date).ToString('o')
  return [pscustomobject]@{
    version = 1
    sessionKey = $Key
    createdAt = $now
    updatedAt = $now
    primary = [pscustomobject]@{
      sessionId = $null
      status = 'available'
      leaseRunId = $null
      leasePid = $null
      leasedAt = $null
      lastUsedAt = $null
      lastRunId = $null
      lastResetAt = $null
      lastResetReason = $null
      lastResetFromSessionId = $null
      lastResetFromRunId = $null
    }
    parallelPool = @()
  }
}

function Ensure-SessionPoolSlotAuditFields {
  param(
    [Parameter(Mandatory = $true)][object]$Slot,
    [bool]$IncludeFingerprint = $false
  )

  foreach ($propertyName in @('lastResetAt', 'lastResetReason', 'lastResetFromSessionId', 'lastResetFromRunId', 'leasePid')) {
    if (-not ($Slot.PSObject.Properties.Name -contains $propertyName)) {
      $Slot | Add-Member -NotePropertyName $propertyName -NotePropertyValue $null
    }
  }
  if ($IncludeFingerprint -and -not ($Slot.PSObject.Properties.Name -contains 'lastTaskFingerprint')) {
    $Slot | Add-Member -NotePropertyName lastTaskFingerprint -NotePropertyValue $null
  }
}

function Read-SessionPoolState {
  param(
    [string]$Path,
    [string]$Key
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return New-SessionPoolState -Key $Key
  }
  $state = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
  if ($null -eq $state.primary) {
    $state | Add-Member -NotePropertyName primary -NotePropertyValue (New-SessionPoolState -Key $Key).primary
  }
  if ($null -eq $state.parallelPool) {
    $state | Add-Member -NotePropertyName parallelPool -NotePropertyValue @()
  }
  Ensure-SessionPoolSlotAuditFields -Slot $state.primary
  foreach ($slot in @($state.parallelPool)) {
    Ensure-SessionPoolSlotAuditFields -Slot $slot -IncludeFingerprint $true
  }
  return $state
}

function Write-SessionPoolState {
  param(
    [string]$Path,
    [object]$State
  )

  $State.updatedAt = (Get-Date).ToString('o')
  $parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  $tmpPath = "$Path.tmp"
  $State | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $tmpPath -Encoding UTF8
  Move-Item -LiteralPath $tmpPath -Destination $Path -Force
}

function Invoke-SessionStateUpdate {
  param(
    [string]$StatePath,
    [string]$LockPath,
    [string]$Key,
    [int]$TimeoutSeconds,
    [scriptblock]$Update
  )

  $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
  $stream = $null
  while ($true) {
    try {
      $lockParent = Split-Path -Parent $LockPath
      if (-not (Test-Path -LiteralPath $lockParent)) {
        New-Item -ItemType Directory -Path $lockParent -Force | Out-Null
      }
      $stream = [System.IO.File]::Open(
        $LockPath,
        [System.IO.FileMode]::OpenOrCreate,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None
      )
      break
    } catch [System.IO.IOException] {
      if ((Get-Date) -ge $deadline) {
        throw "Timed out waiting for Claude session pool lock: $LockPath"
      }
      Start-Sleep -Milliseconds 100
    }
  }

  try {
    $state = Read-SessionPoolState -Path $StatePath -Key $Key
    $result = & $Update $state
    Write-SessionPoolState -Path $StatePath -State $state
    return $result
  } finally {
    if ($null -ne $stream) {
      $stream.Dispose()
    }
  }
}

function Acquire-ClaudeSessionLease {
  param(
    [string]$StatePath,
    [string]$LockPath,
    [string]$Key,
    [string]$Mode,
    [string]$RunId,
    [string]$Fingerprint,
    [int]$LeaseTimeoutSeconds,
    [int]$WaitSeconds,
    [bool]$ResetPrimary,
    [bool]$ResetPool
  )

  $deadline = (Get-Date).AddSeconds([Math]::Max(0, $WaitSeconds))
  while ($true) {
    $lease = Invoke-SessionStateUpdate -StatePath $StatePath -LockPath $LockPath -Key $Key -TimeoutSeconds 30 -Update {
      param($state)

      if ($ResetPrimary) {
        $state.primary.sessionId = $null
        $state.primary.status = 'available'
        $state.primary.leaseRunId = $null
        $state.primary.leasedAt = $null
        $state.primary.lastUsedAt = $null
        $state.primary.lastRunId = $null
      }
      if ($ResetPool) {
        $state.parallelPool = @()
      }

      if (Test-LeaseExpired -Item $state.primary -TimeoutSeconds $LeaseTimeoutSeconds) {
        Write-Warning "Reclaiming expired primary Claude session lease: $($state.primary.leaseRunId)"
        $state.primary.status = 'available'
        $state.primary.leaseRunId = $null
        $state.primary.leasePid = $null
        $state.primary.leasedAt = $null
      }
      if ($state.primary.status -eq 'leased' -and $null -ne $state.primary.leasePid) {
        $pidVal = [int]$state.primary.leasePid
        if ($pidVal -gt 0) {
          $process = Get-Process -Id $pidVal -ErrorAction SilentlyContinue
          if ($null -eq $process) {
            Write-Warning "Reclaiming primary lease from dead process (PID $pidVal, run $($state.primary.leaseRunId))"
            $state.primary.status = 'available'
            $state.primary.leaseRunId = $null
            $state.primary.leasePid = $null
            $state.primary.leasedAt = $null
          }
        }
      }

      $pool = @($state.parallelPool)
      for ($i = 0; $i -lt $pool.Count; $i++) {
        if (Test-LeaseExpired -Item $pool[$i] -TimeoutSeconds $LeaseTimeoutSeconds) {
          Write-Warning "Reclaiming expired parallel Claude session lease: $($pool[$i].leaseRunId)"
          $pool[$i].status = 'available'
          $pool[$i].leaseRunId = $null
          $pool[$i].leasePid = $null
          $pool[$i].leasedAt = $null
        } elseif ($pool[$i].status -eq 'leased' -and $null -ne $pool[$i].leasePid) {
          $pidVal = [int]$pool[$i].leasePid
          if ($pidVal -gt 0) {
            $process = Get-Process -Id $pidVal -ErrorAction SilentlyContinue
            if ($null -eq $process) {
              Write-Warning "Reclaiming parallel lease from dead process (PID $pidVal, run $($pool[$i].leaseRunId))"
              $pool[$i].status = 'available'
              $pool[$i].leaseRunId = $null
              $pool[$i].leasePid = $null
              $pool[$i].leasedAt = $null
            }
          }
        }
      }
      $state.parallelPool = @($pool)

      if ($Mode -eq 'PrimaryReuse' -or $Mode -eq 'PrimaryAnchor') {
        if ($state.primary.status -eq 'leased') {
          return $null
        }
        $resume = -not [string]::IsNullOrWhiteSpace([string]$state.primary.sessionId)
        if (-not $resume) {
          $state.primary.sessionId = New-ClaudeSessionId
        }
        $state.primary.status = 'leased'
        $state.primary.leaseRunId = $RunId
        $state.primary.leasePid = $PID
        $state.primary.leasedAt = (Get-Date).ToString('o')
        return [pscustomobject]@{
          mode = $Mode
          sessionId = [string]$state.primary.sessionId
          resume = $resume
          poolIndex = $null
          leased = $true
        }
      }

      $availablePool = @()
      for ($i = 0; $i -lt $pool.Count; $i++) {
        if ($pool[$i].status -ne 'leased') {
          $availablePool += [pscustomobject]@{
            index = $i
            item = $pool[$i]
            fingerprintMatch = ([string]$pool[$i].lastTaskFingerprint -eq $Fingerprint)
          }
        }
      }

      $selected = $availablePool |
        Sort-Object @{ Expression = { if ($_.fingerprintMatch) { 0 } else { 1 } } },
                    @{ Expression = { if ($_.item.lastUsedAt) { [DateTimeOffset]::Parse([string]$_.item.lastUsedAt) } else { [DateTimeOffset]::MinValue } } } |
        Select-Object -First 1

      if ($null -eq $selected) {
        $newItem = [pscustomobject]@{
          sessionId = New-ClaudeSessionId
          status = 'leased'
          leaseRunId = $RunId
          leasePid = $PID
          leasedAt = (Get-Date).ToString('o')
          lastUsedAt = $null
          lastRunId = $null
          lastTaskFingerprint = $Fingerprint
          lastResetAt = $null
          lastResetReason = $null
          lastResetFromSessionId = $null
          lastResetFromRunId = $null
        }
        $pool += $newItem
        $state.parallelPool = @($pool)
        return [pscustomobject]@{
          mode = $Mode
          sessionId = [string]$newItem.sessionId
          resume = $false
          poolIndex = $pool.Count - 1
          leased = $true
        }
      }

      $item = $pool[$selected.index]
      $resume = -not [string]::IsNullOrWhiteSpace([string]$item.sessionId)
      if (-not $resume) {
        $item.sessionId = New-ClaudeSessionId
      }
      $item.status = 'leased'
      $item.leaseRunId = $RunId
      $item.leasePid = $PID
      $item.leasedAt = (Get-Date).ToString('o')
      $item.lastTaskFingerprint = $Fingerprint
      $pool[$selected.index] = $item
      $state.parallelPool = @($pool)
      return [pscustomobject]@{
        mode = $Mode
        sessionId = [string]$item.sessionId
        resume = $resume
        poolIndex = $selected.index
        leased = $true
      }
    }

    if ($null -ne $lease) {
      return $lease
    }
    if ((Get-Date) -ge $deadline) {
      throw "Claude primary session is leased by another delegate. SessionKey: $Key. Use a longer -SessionLeaseWaitSeconds or choose ParallelPool."
    }
    Start-Sleep -Milliseconds 250
  }
}

function Release-ClaudeSessionLease {
  param(
    [string]$StatePath,
    [string]$LockPath,
    [string]$Key,
    [object]$Lease,
    [string]$RunId,
    [string]$Fingerprint
  )

  if ($null -eq $Lease -or -not $Lease.leased) {
    return
  }

  Invoke-SessionStateUpdate -StatePath $StatePath -LockPath $LockPath -Key $Key -TimeoutSeconds 30 -Update {
    param($state)

    $now = (Get-Date).ToString('o')
    if ($Lease.mode -eq 'PrimaryReuse' -or $Lease.mode -eq 'PrimaryAnchor') {
      if ([string]$state.primary.leaseRunId -eq $RunId) {
        $state.primary.status = 'available'
        $state.primary.leaseRunId = $null
        $state.primary.leasePid = $null
        $state.primary.leasedAt = $null
        $state.primary.lastUsedAt = $now
        $state.primary.lastRunId = $RunId
      }
      return $null
    }

    if ($Lease.mode -eq 'ParallelPool') {
      $pool = @($state.parallelPool)
      for ($i = 0; $i -lt $pool.Count; $i++) {
        if ([string]$pool[$i].sessionId -eq [string]$Lease.sessionId -and [string]$pool[$i].leaseRunId -eq $RunId) {
          $pool[$i].status = 'available'
          $pool[$i].leaseRunId = $null
          $pool[$i].leasePid = $null
          $pool[$i].leasedAt = $null
          $pool[$i].lastUsedAt = $now
          $pool[$i].lastRunId = $RunId
          $pool[$i].lastTaskFingerprint = $Fingerprint
          break
        }
      }
      $state.parallelPool = @($pool)
    }
    return $null
  } | Out-Null
}

function Reset-ClaudeSessionLeaseForFreshSession {
  param(
    [string]$StatePath,
    [string]$LockPath,
    [string]$Key,
    [object]$Lease,
    [string]$RunId,
    [string]$Fingerprint,
    [string]$Reason = 'fresh_session_retry'
  )

  if ($null -eq $Lease -or -not $Lease.leased) {
    throw 'Cannot reset a Claude session lease that is not currently leased.'
  }

  return Invoke-SessionStateUpdate -StatePath $StatePath -LockPath $LockPath -Key $Key -TimeoutSeconds 30 -Update {
    param($state)

    $now = (Get-Date).ToString('o')
    if ($Lease.mode -eq 'PrimaryReuse' -or $Lease.mode -eq 'PrimaryAnchor') {
      if ([string]$state.primary.leaseRunId -ne $RunId) {
        throw "Cannot reset primary Claude session lease; expected run '$RunId' but found '$($state.primary.leaseRunId)'."
      }

      $state.primary.sessionId = New-ClaudeSessionId
      $state.primary.status = 'leased'
      $state.primary.leaseRunId = $RunId
      $state.primary.leasedAt = $now
      $state.primary.lastUsedAt = $null
      $state.primary.lastRunId = $null
      $state.primary.lastResetAt = $now
      $state.primary.lastResetReason = $Reason
      $state.primary.lastResetFromSessionId = [string]$Lease.sessionId
      $state.primary.lastResetFromRunId = $RunId

      return [pscustomobject]@{
        mode = $Lease.mode
        sessionId = [string]$state.primary.sessionId
        resume = $false
        poolIndex = $null
        leased = $true
      }
    }

    if ($Lease.mode -eq 'ParallelPool') {
      $pool = @($state.parallelPool)
      for ($i = 0; $i -lt $pool.Count; $i++) {
        if ([string]$pool[$i].sessionId -eq [string]$Lease.sessionId -and [string]$pool[$i].leaseRunId -eq $RunId) {
          $pool[$i].sessionId = New-ClaudeSessionId
          $pool[$i].status = 'leased'
          $pool[$i].leaseRunId = $RunId
          $pool[$i].leasedAt = $now
          $pool[$i].lastUsedAt = $null
          $pool[$i].lastRunId = $null
          $pool[$i].lastTaskFingerprint = $Fingerprint
          $pool[$i].lastResetAt = $now
          $pool[$i].lastResetReason = $Reason
          $pool[$i].lastResetFromSessionId = [string]$Lease.sessionId
          $pool[$i].lastResetFromRunId = $RunId
          $state.parallelPool = @($pool)

          return [pscustomobject]@{
            mode = $Lease.mode
            sessionId = [string]$pool[$i].sessionId
            resume = $false
            poolIndex = $i
            leased = $true
          }
        }
      }

      throw "Cannot reset parallel Claude session lease for run '$RunId'; the leased session was not found."
    }

    throw "Unsupported Claude session mode for reset: $($Lease.mode)"
  }
}
