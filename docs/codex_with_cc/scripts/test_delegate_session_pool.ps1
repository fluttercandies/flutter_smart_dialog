$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-True {
  param(
    [Parameter(Mandatory = $true)]
    [bool]$Condition,
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if (-not $Condition) {
    throw "[$Name] assertion failed"
  }
}

function Assert-Equal {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Actual,
    [Parameter(Mandatory = $true)]
    [string]$Expected,
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if ($Actual -ne $Expected) {
    throw "[$Name] expected '$Expected' but got '$Actual'"
  }
}

function Write-DelegateArtifact {
  param(
    [Parameter(Mandatory = $true)][string]$ArtifactRoot,
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $true)][hashtable]$ConfigData,
    [Parameter(Mandatory = $true)][hashtable]$StatusData,
    [string]$OutputText = @"
Process Log
- synthetic

Summary
synthetic

Changed Files
None

Verification
- synthetic

Final Result
PASS

Risks Or Follow-ups
None
"@
  )

  $outputPath = Join-Path $ArtifactRoot "claude_${RunId}.md"
  $promptPath = Join-Path $ArtifactRoot "prompt_${RunId}.md"
  $configPath = Join-Path $ArtifactRoot "config_${RunId}.json"
  $statusPath = Join-Path $ArtifactRoot "status_${RunId}.json"
  $tracePath = Join-Path $ArtifactRoot "trace_${RunId}.log"
  $streamPath = Join-Path $ArtifactRoot "stream_${RunId}.jsonl"
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

  [System.IO.File]::WriteAllText($outputPath, $OutputText, $utf8NoBom)
  [System.IO.File]::WriteAllText($promptPath, '# synthetic prompt', $utf8NoBom)
  [System.IO.File]::WriteAllText($tracePath, '[synthetic] ok', $utf8NoBom)
  [System.IO.File]::WriteAllText($streamPath, '{"type":"result","subtype":"success"}', $utf8NoBom)

  $fullConfig = [ordered]@{
    artifactSchema = 2
    invocationContract = 'spawn_agent_child_only'
    childThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
    childThreadMarkerValidated = $true
    runId = $RunId
    promptPath = $promptPath
    outputPath = $outputPath
    statusPath = $statusPath
    rawStreamPath = $streamPath
    tracePath = $tracePath
  } + $ConfigData
  $fullStatus = [ordered]@{
    artifactSchema = 2
    invocationContract = 'spawn_agent_child_only'
    childThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
    childThreadMarkerValidated = $true
    runId = $RunId
    status = 'completed'
    outputPath = $outputPath
    promptPath = $promptPath
    rawStreamPath = $streamPath
    tracePath = $tracePath
    exitCode = 0
  } + $StatusData

  $fullConfig | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $configPath -Encoding UTF8
  $fullStatus | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $statusPath -Encoding UTF8
}

function Invoke-DelegateWorkerScript {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$ArgumentList,
    [switch]$SetChildThreadMarker
  )

  $markerName = 'CODEX_CLAUDE_CHILD_THREAD'
  $originalMarker = [Environment]::GetEnvironmentVariable($markerName, 'Process')
  try {
    if ($SetChildThreadMarker) {
      [Environment]::SetEnvironmentVariable($markerName, '1', 'Process')
    } else {
      [Environment]::SetEnvironmentVariable($markerName, $null, 'Process')
    }

    $scriptPath = Join-Path $PSScriptRoot 'delegate_to_claude.ps1'
    $output = & pwsh -NoProfile -File $scriptPath @ArgumentList 2>&1
    return [pscustomobject]@{
      ExitCode = $LASTEXITCODE
      Output = @($output)
    }
  } finally {
    [Environment]::SetEnvironmentVariable($markerName, $originalMarker, 'Process')
  }
}

function Invoke-DelegateDryRun {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactRoot,
    [Parameter(Mandatory = $true)]
    [string]$SessionKey,
    [Parameter(Mandatory = $true)]
    [string]$SessionMode,
    [string]$Task = 'session pool dry run',
    [switch]$AllowParallel
  )

  $args = @(
    '-Task', $Task,
    '-ArtifactRoot', $ArtifactRoot,
    '-SessionKey', $SessionKey,
    '-SessionMode', $SessionMode,
    '-DryRun'
  )
  if ($AllowParallel) {
    $args += '-AllowParallel'
  }

  $result = Invoke-DelegateWorkerScript -ArgumentList $args -SetChildThreadMarker
  if ($result.ExitCode -ne 0) {
    throw "delegate dry run failed for $SessionMode. Output:`n$($result.Output -join [Environment]::NewLine)"
  }
  return ($result.Output -join [Environment]::NewLine)
}

function Read-SessionState {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactRoot,
    [Parameter(Mandatory = $true)]
    [string]$SessionKey
  )

  $statePath = Join-Path $ArtifactRoot "session-pools\$SessionKey.json"
  Assert-True -Condition (Test-Path -LiteralPath $statePath) -Name 'state-file-exists'
  return Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "codex_with_cc_delegate_session_pool_$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
  $poolHelperPath = Join-Path $PSScriptRoot 'claude_session_pool.ps1'
  $verifyChainScriptPath = Join-Path $PSScriptRoot 'verify_delegate_chain.ps1'
  Assert-True -Condition (Test-Path -LiteralPath $poolHelperPath) -Name 'session-pool-helper-exists'
  Assert-True -Condition (Test-Path -LiteralPath $verifyChainScriptPath) -Name 'verify-chain-script-exists'
  . $poolHelperPath
  Assert-True -Condition ($null -ne (Get-Command Acquire-ClaudeSessionLease -ErrorAction SilentlyContinue)) -Name 'session-pool-helper-exports-acquire'
  Assert-True -Condition ($null -ne (Get-Command Release-ClaudeSessionLease -ErrorAction SilentlyContinue)) -Name 'session-pool-helper-exports-release'
  Assert-True -Condition ($null -ne (Get-Command Reset-ClaudeSessionLeaseForFreshSession -ErrorAction SilentlyContinue)) -Name 'session-pool-helper-exports-reset'

  $markerFailure = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'marker failure probe',
    '-ArtifactRoot', $tempRoot,
    '-SessionKey', 'marker-failure-probe',
    '-SessionMode', 'PrimaryReuse',
    '-DryRun'
  )
  Assert-True -Condition ($markerFailure.ExitCode -ne 0) -Name 'missing-child-thread-marker-fails-in-session-pool-test'
  Assert-True -Condition (($markerFailure.Output -join [Environment]::NewLine).Contains('CODEX_CLAUDE_CHILD_THREAD=1')) -Name 'missing-child-thread-marker-names-required-marker-in-session-pool-test'
  Assert-True -Condition (($markerFailure.Output -join [Environment]::NewLine).Contains('may only run inside a Codex spawn_agent child thread')) -Name 'missing-child-thread-marker-error-clear-in-session-pool-test'

  $sessionKey = 'session-pool-test'

  $first = Invoke-DelegateDryRun -ArtifactRoot $tempRoot -SessionKey $sessionKey -SessionMode 'PrimaryReuse' -Task 'serial A'
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  $primaryId = [string]$state.primary.sessionId
  Assert-True -Condition ([guid]::TryParse($primaryId, [ref]([guid]::Empty))) -Name 'primary-session-id-is-guid'
  Assert-True -Condition ($first.Contains("--session-id $primaryId")) -Name 'first-primary-uses-session-id'
  Assert-Equal -Actual ([string]$state.primary.status) -Expected 'available' -Name 'primary-released-after-dry-run'

  $anchor = Invoke-DelegateDryRun -ArtifactRoot $tempRoot -SessionKey $sessionKey -SessionMode 'PrimaryAnchor' -Task 'parallel anchor' -AllowParallel
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.primary.sessionId) -Expected $primaryId -Name 'anchor-keeps-primary-id'
  Assert-True -Condition ($anchor.Contains("--resume $primaryId")) -Name 'anchor-resumes-primary'

  $parallelA = Invoke-DelegateDryRun -ArtifactRoot $tempRoot -SessionKey $sessionKey -SessionMode 'ParallelPool' -Task 'parallel sidecar A' -AllowParallel
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.parallelPool.Count) -Expected '1' -Name 'parallel-pool-creates-first-id'
  $poolId = [string]$state.parallelPool[0].sessionId
  Assert-True -Condition ($parallelA.Contains("--session-id $poolId")) -Name 'first-parallel-uses-session-id'

  $parallelB = Invoke-DelegateDryRun -ArtifactRoot $tempRoot -SessionKey $sessionKey -SessionMode 'ParallelPool' -Task 'parallel sidecar A' -AllowParallel
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.parallelPool.Count) -Expected '1' -Name 'parallel-pool-reuses-available-id'
  Assert-True -Condition ($parallelB.Contains("--resume $poolId")) -Name 'second-parallel-resumes-pool-id'

  $state.parallelPool[0].status = 'leased'
  $state.parallelPool[0].leaseRunId = 'active-parallel'
  $state.parallelPool[0].leasedAt = (Get-Date).ToString('o')
  $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $tempRoot "session-pools\$sessionKey.json") -Encoding UTF8
  $parallelC = Invoke-DelegateDryRun -ArtifactRoot $tempRoot -SessionKey $sessionKey -SessionMode 'ParallelPool' -Task 'parallel sidecar C' -AllowParallel
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.parallelPool.Count) -Expected '2' -Name 'parallel-pool-grows-while-existing-id-leased'
  $newPoolId = [string]$state.parallelPool[1].sessionId
  Assert-True -Condition ($parallelC.Contains("--session-id $newPoolId")) -Name 'leased-pool-creates-new-session-id'

  $after = Invoke-DelegateDryRun -ArtifactRoot $tempRoot -SessionKey $sessionKey -SessionMode 'PrimaryReuse' -Task 'serial D'
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.primary.sessionId) -Expected $primaryId -Name 'serial-after-parallel-keeps-primary'
  Assert-True -Condition ($after.Contains("--resume $primaryId")) -Name 'serial-after-parallel-resumes-primary'

  $freshResetLease = Acquire-ClaudeSessionLease `
    -StatePath (Join-Path $tempRoot "session-pools\$sessionKey.json") `
    -LockPath (Join-Path $tempRoot "session-pools\$sessionKey.lock") `
    -Key $sessionKey `
    -Mode 'PrimaryReuse' `
    -RunId 'fresh-reset-run' `
    -Fingerprint 'fresh-reset-fingerprint' `
    -LeaseTimeoutSeconds 60 `
    -WaitSeconds 0 `
    -ResetPrimary $false `
    -ResetPool $false
  $resetResult = Reset-ClaudeSessionLeaseForFreshSession `
    -StatePath (Join-Path $tempRoot "session-pools\$sessionKey.json") `
    -LockPath (Join-Path $tempRoot "session-pools\$sessionKey.lock") `
    -Key $sessionKey `
    -Lease $freshResetLease `
    -RunId 'fresh-reset-run' `
    -Fingerprint 'fresh-reset-fingerprint' `
    -Reason 'stale_claude_session'
  Assert-True -Condition (-not [bool]$resetResult.resume) -Name 'fresh-reset-returns-non-resume-lease'
  Assert-True -Condition ([string]$resetResult.sessionId -ne [string]$freshResetLease.sessionId) -Name 'fresh-reset-changes-session-id'
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.primary.lastResetReason) -Expected 'stale_claude_session' -Name 'fresh-reset-records-reason'
  Assert-Equal -Actual ([string]$state.primary.lastResetFromRunId) -Expected 'fresh-reset-run' -Name 'fresh-reset-records-source-run'
  Assert-Equal -Actual ([string]$state.primary.lastResetFromSessionId) -Expected ([string]$freshResetLease.sessionId) -Name 'fresh-reset-records-source-session'
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$state.primary.lastResetAt)) -Name 'fresh-reset-records-timestamp'
  Release-ClaudeSessionLease `
    -StatePath (Join-Path $tempRoot "session-pools\$sessionKey.json") `
    -LockPath (Join-Path $tempRoot "session-pools\$sessionKey.lock") `
    -Key $sessionKey `
    -Lease $resetResult `
    -RunId 'fresh-reset-run' `
    -Fingerprint 'fresh-reset-fingerprint'

  $state.primary.status = 'leased'
  $state.primary.leaseRunId = 'active-primary'
  $state.primary.leasedAt = (Get-Date).ToString('o')
  $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $tempRoot "session-pools\$sessionKey.json") -Encoding UTF8
  $blocked = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'blocked primary',
    '-ArtifactRoot', $tempRoot,
    '-SessionKey', $sessionKey,
    '-SessionMode', 'PrimaryAnchor',
    '-SessionLeaseTimeoutSeconds', '60',
    '-SessionLeaseWaitSeconds', '0',
    '-AllowParallel',
    '-DryRun'
  ) -SetChildThreadMarker
  Assert-True -Condition ($blocked.ExitCode -ne 0) -Name 'active-primary-blocks-second-primary'
  Assert-True -Condition (($blocked.Output -join [Environment]::NewLine).Contains('Claude primary session is leased')) -Name 'active-primary-error-is-clear'

  $state.primary.status = 'leased'
  $state.primary.leaseRunId = 'stale-primary'
  $state.primary.leasedAt = (Get-Date).AddSeconds(-120).ToString('o')
  $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $tempRoot "session-pools\$sessionKey.json") -Encoding UTF8
  $recovered = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'recover stale primary',
    '-ArtifactRoot', $tempRoot,
    '-SessionKey', $sessionKey,
    '-SessionMode', 'PrimaryReuse',
    '-SessionLeaseTimeoutSeconds', '1',
    '-SessionLeaseWaitSeconds', '0',
    '-DryRun'
  ) -SetChildThreadMarker
  if ($recovered.ExitCode -ne 0) {
    throw "stale primary recovery failed. Output:`n$($recovered.Output -join [Environment]::NewLine)"
  }
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.primary.status) -Expected 'available' -Name 'stale-primary-released'

  # Test PID-based stale primary lease reclamation (crashed process)
  $state.primary.status = 'leased'
  $state.primary.leaseRunId = 'dead-pid-primary'
  $state.primary.leasePid = 999999999
  $state.primary.leasedAt = (Get-Date).ToString('o')
  $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $tempRoot "session-pools\$sessionKey.json") -Encoding UTF8
  $pidRecovered = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'recover dead-pid primary',
    '-ArtifactRoot', $tempRoot,
    '-SessionKey', $sessionKey,
    '-SessionMode', 'PrimaryReuse',
    '-SessionLeaseTimeoutSeconds', '3600',
    '-SessionLeaseWaitSeconds', '0',
    '-DryRun'
  ) -SetChildThreadMarker
  if ($pidRecovered.ExitCode -ne 0) {
    throw "PID-based stale primary recovery failed. Output:`n$($pidRecovered.Output -join [Environment]::NewLine)"
  }
  $state = Read-SessionState -ArtifactRoot $tempRoot -SessionKey $sessionKey
  Assert-Equal -Actual ([string]$state.primary.status) -Expected 'available' -Name 'pid-stale-primary-released'
  Assert-True -Condition ($null -eq $state.primary.leasePid) -Name 'pid-stale-primary-leasepid-cleared'

  $budgetOutput = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'budget dry run',
    '-ArtifactRoot', $tempRoot,
    '-SessionKey', 'budget-session-pool-test',
    '-SessionMode', 'PrimaryReuse',
    '-MaxBudgetUsd', '0.35',
    '-DryRun'
  ) -SetChildThreadMarker
  if ($budgetOutput.ExitCode -ne 0) {
    throw "budget dry run failed. Output:`n$($budgetOutput.Output -join [Environment]::NewLine)"
  }

  $splitScopeOutput = Invoke-DelegateDryRun `
    -ArtifactRoot $tempRoot `
    -SessionKey 'split-scope-session-pool-test' `
    -SessionMode 'PrimaryReuse' `
    -Task 'split scope dry run'
  $splitPromptPath = (($splitScopeOutput -split "`r?`n") | Where-Object { $_ -like 'Prompt:*' } | Select-Object -Last 1) -replace '^Prompt:\s*',''
  Assert-True -Condition (Test-Path -LiteralPath $splitPromptPath) -Name 'split-scope-prompt-exists'

  $splitOutput = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'split scope explicit dry run',
    '-ArtifactRoot', $tempRoot,
    '-SessionKey', 'split-scope-session-pool-test-2',
    '-SessionMode', 'PrimaryReuse',
    '-Scope', 'docs/codex_with_cc/scripts;docs/codex_with_cc',
    '-Tests', 'pwsh -NoProfile -File .\docs\codex_with_cc\scripts\test_delegate_session_pool.ps1;git diff --check',
    '-DryRun'
  ) -SetChildThreadMarker
  if ($splitOutput.ExitCode -ne 0) {
    throw "split scope dry run failed. Output:`n$($splitOutput.Output -join [Environment]::NewLine)"
  }
  $splitPromptPath = (($splitOutput.Output -join [Environment]::NewLine) -split "`r?`n" | Where-Object { $_ -like 'Prompt:*' } | Select-Object -Last 1) -replace '^Prompt:\s*',''
  $splitPrompt = Get-Content -LiteralPath $splitPromptPath -Raw
  Assert-True -Condition ($splitPrompt.Contains("- docs/codex_with_cc/scripts`r`n- docs/codex_with_cc") -or $splitPrompt.Contains("- docs/codex_with_cc/scripts`n- docs/codex_with_cc")) -Name 'semicolon-scope-splits-into-prompt-lines'
  Assert-True -Condition ($splitPrompt.Contains("- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\test_delegate_session_pool.ps1")) -Name 'semicolon-tests-first-line-present'
  Assert-True -Condition ($splitPrompt.Contains("- git diff --check")) -Name 'semicolon-tests-second-line-present'
  Assert-True -Condition ($splitPrompt.Contains('Never call docs/codex_with_cc/scripts/delegate_to_claude.ps1, claude, or spawn_agent recursively')) -Name 'prompt-explicitly-forbids-recursive-delegation'
  Assert-True -Condition (-not $splitPrompt.Contains('Recommended execution order:')) -Name 'prompt-does-not-inline-full-delegation-playbook'

  $chainArtifactRoot = Join-Path $tempRoot 'chain-artifacts'
  $chainSessionKey = 'chain-verify-session'
  $chainSessionStatePath = Join-Path $chainArtifactRoot "session-pools\$chainSessionKey.json"
  $chainSessionIdInitial = [guid]::NewGuid().ToString()
  $chainSessionIdReset = [guid]::NewGuid().ToString()
  $parallelSessionOne = [guid]::NewGuid().ToString()
  $parallelSessionTwo = [guid]::NewGuid().ToString()
  New-Item -ItemType Directory -Path (Split-Path -Parent $chainSessionStatePath) -Force | Out-Null

  Write-DelegateArtifact -ArtifactRoot $chainArtifactRoot -RunId 'anchor-run' -ConfigData @{
    sessionKey = $chainSessionKey
    sessionStatePath = $chainSessionStatePath
    sessionMode = 'PrimaryAnchor'
    initialSessionId = $chainSessionIdInitial
    initialResume = $false
    sessionId = $chainSessionIdInitial
    resume = $false
    attemptCount = 1
    retryCount = 0
  } -StatusData @{
    attemptCount = 1
    retryCount = 0
    attempts = @(
      @{
        attempt = 1
        sessionId = $chainSessionIdInitial
        resume = $false
        retryReason = $null
        exitCode = 0
        sawAssistantText = $true
        sawResultSuccess = $true
        capturedFinalResult = $true
      }
    )
  }

  Write-DelegateArtifact -ArtifactRoot $chainArtifactRoot -RunId 'parallel-run-a' -ConfigData @{
    sessionKey = $chainSessionKey
    sessionStatePath = $chainSessionStatePath
    sessionMode = 'ParallelPool'
    initialSessionId = $parallelSessionOne
    initialResume = $false
    sessionId = $parallelSessionOne
    resume = $false
    attemptCount = 1
    retryCount = 0
  } -StatusData @{
    attemptCount = 1
    retryCount = 0
    attempts = @(
      @{
        attempt = 1
        sessionId = $parallelSessionOne
        resume = $false
        retryReason = $null
        exitCode = 0
        sawAssistantText = $true
        sawResultSuccess = $true
        capturedFinalResult = $true
      }
    )
  }

  Write-DelegateArtifact -ArtifactRoot $chainArtifactRoot -RunId 'parallel-run-b' -ConfigData @{
    sessionKey = $chainSessionKey
    sessionStatePath = $chainSessionStatePath
    sessionMode = 'ParallelPool'
    initialSessionId = $parallelSessionTwo
    initialResume = $true
    sessionId = $parallelSessionTwo
    resume = $true
    attemptCount = 1
    retryCount = 0
  } -StatusData @{
    attemptCount = 1
    retryCount = 0
    attempts = @(
      @{
        attempt = 1
        sessionId = $parallelSessionTwo
        resume = $true
        retryReason = $null
        exitCode = 0
        sawAssistantText = $true
        sawResultSuccess = $true
        capturedFinalResult = $true
      }
    )
  }

  Write-DelegateArtifact -ArtifactRoot $chainArtifactRoot -RunId 'reuse-run-a' -ConfigData @{
    sessionKey = $chainSessionKey
    sessionStatePath = $chainSessionStatePath
    sessionMode = 'PrimaryReuse'
    initialSessionId = $chainSessionIdInitial
    initialResume = $true
    sessionId = $chainSessionIdReset
    resume = $false
    attemptCount = 2
    retryCount = 1
  } -StatusData @{
    attemptCount = 2
    retryCount = 1
    lastRetryReason = 'stale_claude_session'
    attempts = @(
      @{
        attempt = 1
        sessionId = $chainSessionIdInitial
        resume = $true
        retryReason = 'stale_claude_session'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 2
        sessionId = $chainSessionIdReset
        resume = $false
        retryReason = $null
        exitCode = 0
        sawAssistantText = $true
        sawResultSuccess = $true
        capturedFinalResult = $true
      }
    )
  }

  Write-DelegateArtifact -ArtifactRoot $chainArtifactRoot -RunId 'reuse-run-b' -ConfigData @{
    sessionKey = $chainSessionKey
    sessionStatePath = $chainSessionStatePath
    sessionMode = 'PrimaryReuse'
    initialSessionId = $chainSessionIdReset
    initialResume = $true
    sessionId = $chainSessionIdReset
    resume = $true
    attemptCount = 1
    retryCount = 0
  } -StatusData @{
    attemptCount = 1
    retryCount = 0
    attempts = @(
      @{
        attempt = 1
        sessionId = $chainSessionIdReset
        resume = $true
        retryReason = $null
        exitCode = 0
        sawAssistantText = $true
        sawResultSuccess = $true
        capturedFinalResult = $true
      }
    )
  }

  @(
    @{
      version = 1
      sessionKey = $chainSessionKey
      createdAt = (Get-Date).ToString('o')
      updatedAt = (Get-Date).ToString('o')
      primary = @{
        sessionId = $chainSessionIdReset
        status = 'available'
        leaseRunId = $null
        leasedAt = $null
        lastUsedAt = (Get-Date).ToString('o')
        lastRunId = 'reuse-run-b'
        lastResetAt = (Get-Date).ToString('o')
        lastResetReason = 'stale_claude_session'
        lastResetFromSessionId = $chainSessionIdInitial
        lastResetFromRunId = 'reuse-run-a'
      }
      parallelPool = @(
        @{
          sessionId = $parallelSessionOne
          status = 'available'
          leaseRunId = $null
          leasedAt = $null
          lastUsedAt = (Get-Date).ToString('o')
          lastRunId = 'parallel-run-a'
          lastTaskFingerprint = 'fingerprint-a'
          lastResetAt = $null
          lastResetReason = $null
          lastResetFromSessionId = $null
          lastResetFromRunId = $null
        },
        @{
          sessionId = $parallelSessionTwo
          status = 'available'
          leaseRunId = $null
          leasedAt = $null
          lastUsedAt = (Get-Date).ToString('o')
          lastRunId = 'parallel-run-b'
          lastTaskFingerprint = 'fingerprint-b'
          lastResetAt = $null
          lastResetReason = $null
          lastResetFromSessionId = $null
          lastResetFromRunId = $null
        }
      )
    }
  ) | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $chainSessionStatePath -Encoding UTF8

  $chainVerifyOutput = & pwsh -NoProfile -File $verifyChainScriptPath `
    -ArtifactRoot $chainArtifactRoot `
    -SessionKey $chainSessionKey `
    -AnchorRunId 'anchor-run' `
    -ParallelRunIds 'parallel-run-a','parallel-run-b' `
    -ReuseRunIds 'reuse-run-a','reuse-run-b' 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "chain verify failed unexpectedly. Output:`n$($chainVerifyOutput -join [Environment]::NewLine)"
  }
  $chainVerifyJson = ($chainVerifyOutput -join [Environment]::NewLine) | ConvertFrom-Json
  Assert-True -Condition ([bool]$chainVerifyJson.chainPassed) -Name 'chain-verify-passes-success-case'
  Assert-True -Condition ([bool]$chainVerifyJson.staleResetOccurred) -Name 'chain-verify-detects-stale-reset'
  Assert-True -Condition ([bool]$chainVerifyJson.parallelPoolReuse) -Name 'chain-verify-detects-parallel-pool-reuse'

  Write-Host 'delegate session pool tests passed' -ForegroundColor Green
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
