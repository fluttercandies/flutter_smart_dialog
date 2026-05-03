param(
  [Parameter(Mandatory = $true)][string]$ArtifactRoot,
  [Parameter(Mandatory = $true)][string]$SessionKey,
  [Parameter(Mandatory = $true)][string]$AnchorRunId,
  [Parameter(Mandatory = $true)][string[]]$ParallelRunIds,
  [Parameter(Mandatory = $true)][string[]]$ReuseRunIds
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Normalize-RunIdList {
  param([string[]]$Values)

  $normalized = New-Object System.Collections.Generic.List[string]
  foreach ($value in @($Values)) {
    if ([string]::IsNullOrWhiteSpace([string]$value)) {
      continue
    }
    foreach ($part in ([string]$value -split '\s*,\s*')) {
      $clean = $part.Trim().Trim("'`"")
      if (-not [string]::IsNullOrWhiteSpace($clean)) {
        $normalized.Add($clean)
      }
    }
  }
  return @($normalized)
}

function Get-DelegateArtifactRecord {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$RunId
  )

  $configPath = Join-Path $Root "config_${RunId}.json"
  $statusPath = Join-Path $Root "status_${RunId}.json"
  $outputPath = Join-Path $Root "claude_${RunId}.md"

  if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Missing delegate config: $configPath"
  }
  if (-not (Test-Path -LiteralPath $statusPath)) {
    throw "Missing delegate status: $statusPath"
  }
  if (-not (Test-Path -LiteralPath $outputPath)) {
    throw "Missing delegate output: $outputPath"
  }

  return [pscustomobject]@{
    runId = $RunId
    config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    status = Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json
  }
}

function Assert-True {
  param(
    [Parameter(Mandatory = $true)][bool]$Condition,
    [Parameter(Mandatory = $true)][string]$Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

$artifactVerifyScriptPath = Join-Path $PSScriptRoot 'verify_delegate_artifacts.ps1'
if (-not (Test-Path -LiteralPath $artifactVerifyScriptPath)) {
  throw "Missing delegate artifact verifier: $artifactVerifyScriptPath"
}

$resolvedArtifactRoot = [System.IO.Path]::GetFullPath($ArtifactRoot)
$ParallelRunIds = @(Normalize-RunIdList -Values $ParallelRunIds)
$ReuseRunIds = @(Normalize-RunIdList -Values $ReuseRunIds)
$allRunIds = @($AnchorRunId) + @($ParallelRunIds) + @($ReuseRunIds)

foreach ($runId in $allRunIds) {
  & pwsh -NoProfile -File $artifactVerifyScriptPath -RunId $runId -ArtifactRoot $resolvedArtifactRoot | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Artifact verification failed for run: $runId"
  }
}

$anchorRecord = Get-DelegateArtifactRecord -Root $resolvedArtifactRoot -RunId $AnchorRunId
$parallelRecords = @($ParallelRunIds | ForEach-Object { Get-DelegateArtifactRecord -Root $resolvedArtifactRoot -RunId $_ })
$reuseRecords = @($ReuseRunIds | ForEach-Object { Get-DelegateArtifactRecord -Root $resolvedArtifactRoot -RunId $_ })

Assert-True -Condition ([string]$anchorRecord.config.sessionMode -eq 'PrimaryAnchor') -Message 'Anchor run must use PrimaryAnchor.'
Assert-True -Condition ([string]$anchorRecord.config.sessionKey -eq $SessionKey) -Message 'Anchor run sessionKey mismatch.'

$sessionStatePath = [string]$anchorRecord.config.sessionStatePath
Assert-True -Condition (-not [string]::IsNullOrWhiteSpace($sessionStatePath)) -Message 'Anchor run is missing sessionStatePath.'
Assert-True -Condition (Test-Path -LiteralPath $sessionStatePath) -Message "Missing session state path: $sessionStatePath"

$expectedMainSessionId = [string]$anchorRecord.config.sessionId
$primaryCacheHit = $true
$parallelPoolReuse = $false
$staleResetOccurred = $false
$artifactContractValid = $true

foreach ($parallelRecord in $parallelRecords) {
  Assert-True -Condition ([string]$parallelRecord.config.sessionMode -eq 'ParallelPool') -Message "Parallel run '$($parallelRecord.runId)' must use ParallelPool."
  Assert-True -Condition ([string]$parallelRecord.config.sessionKey -eq $SessionKey) -Message "Parallel run '$($parallelRecord.runId)' sessionKey mismatch."
  if ([bool]$parallelRecord.config.initialResume) {
    $parallelPoolReuse = $true
  }
}

foreach ($reuseRecord in $reuseRecords) {
  Assert-True -Condition ([string]$reuseRecord.config.sessionMode -eq 'PrimaryReuse') -Message "Reuse run '$($reuseRecord.runId)' must use PrimaryReuse."
  Assert-True -Condition ([string]$reuseRecord.config.sessionKey -eq $SessionKey) -Message "Reuse run '$($reuseRecord.runId)' sessionKey mismatch."
  Assert-True -Condition ([bool]$reuseRecord.config.initialResume) -Message "Reuse run '$($reuseRecord.runId)' must start by attempting resume=true."
  Assert-True -Condition ([string]$reuseRecord.config.initialSessionId -eq $expectedMainSessionId) -Message "Reuse run '$($reuseRecord.runId)' did not start from the expected main session."

  $attempts = @($reuseRecord.status.attempts)
  $firstAttempt = $attempts[0]
  $finalAttempt = $attempts[$attempts.Count - 1]
  Assert-True -Condition ([bool]$firstAttempt.resume) -Message "Reuse run '$($reuseRecord.runId)' first attempt must be resume=true."

  if ([string]$finalAttempt.sessionId -ne $expectedMainSessionId) {
    $staleResetOccurred = $true
    Assert-True -Condition ([int]$reuseRecord.status.retryCount -ge 1) -Message "Reuse run '$($reuseRecord.runId)' changed primary session without recording a retry."
    Assert-True -Condition ([string]$reuseRecord.status.lastRetryReason -eq 'stale_claude_session') -Message "Reuse run '$($reuseRecord.runId)' must record stale_claude_session when changing primary session."
    Assert-True -Condition (-not [bool]$finalAttempt.resume) -Message "Reuse run '$($reuseRecord.runId)' fresh recovery attempt must be resume=false."
    $expectedMainSessionId = [string]$finalAttempt.sessionId
  }
}

$sessionState = Get-Content -LiteralPath $sessionStatePath -Raw | ConvertFrom-Json
Assert-True -Condition ([string]$sessionState.sessionKey -eq $SessionKey) -Message 'Session pool sessionKey mismatch.'
Assert-True -Condition ([string]$sessionState.primary.status -eq 'available') -Message 'Primary session slot must be available after chain completion.'
Assert-True -Condition ([string]$sessionState.primary.sessionId -eq $expectedMainSessionId) -Message 'Final primary session ID does not match the expected chain head.'

if ($staleResetOccurred) {
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$sessionState.primary.lastResetAt)) -Message 'Primary session reset is missing lastResetAt.'
  Assert-True -Condition ([string]$sessionState.primary.lastResetReason -eq 'stale_claude_session') -Message 'Primary session reset reason must be stale_claude_session.'
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$sessionState.primary.lastResetFromSessionId)) -Message 'Primary session reset is missing lastResetFromSessionId.'
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$sessionState.primary.lastResetFromRunId)) -Message 'Primary session reset is missing lastResetFromRunId.'
}

foreach ($parallelRecord in $parallelRecords) {
  $parallelSessionId = [string]$parallelRecord.config.sessionId
  $poolSlot = @($sessionState.parallelPool) | Where-Object { [string]$_.sessionId -eq $parallelSessionId } | Select-Object -First 1
  Assert-True -Condition ($null -ne $poolSlot) -Message "Parallel pool slot for run '$($parallelRecord.runId)' was not found."
  Assert-True -Condition ([string]$poolSlot.status -eq 'available') -Message "Parallel pool slot for run '$($parallelRecord.runId)' must be available after chain completion."
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$poolSlot.lastTaskFingerprint)) -Message "Parallel pool slot for run '$($parallelRecord.runId)' is missing lastTaskFingerprint."
}

$orphanLeaseDetected = (
  [string]$sessionState.primary.status -eq 'leased' -or
  @($sessionState.parallelPool | Where-Object { [string]$_.status -eq 'leased' }).Count -gt 0
)

$summary = [ordered]@{
  primaryCacheHit = $primaryCacheHit
  parallelPoolReuse = $parallelPoolReuse
  staleResetOccurred = $staleResetOccurred
  orphanLeaseDetected = $orphanLeaseDetected
  artifactContractValid = $artifactContractValid
  chainPassed = (-not $orphanLeaseDetected)
}

$summary | ConvertTo-Json -Depth 6

if ($orphanLeaseDetected) {
  throw 'Delegate chain verification failed because a session lease is still active.'
}
