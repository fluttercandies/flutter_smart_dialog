param(
  [Parameter(Mandatory = $true)]
  [string]$RunId,
  [string]$ArtifactRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$backendHelperPath = Join-Path $PSScriptRoot 'claude_delegate_backend_helpers.ps1'
if (-not (Test-Path -LiteralPath $backendHelperPath)) {
  throw "Missing Claude delegate backend helper: $backendHelperPath"
}
. $backendHelperPath

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if ([string]::IsNullOrWhiteSpace($ArtifactRoot)) {
  $ArtifactRoot = Join-Path $repoRoot '.codex\claude-delegate'
}
$resolvedArtifactRoot = [System.IO.Path]::GetFullPath($ArtifactRoot)

$configPath = Join-Path $resolvedArtifactRoot "config_${RunId}.json"
$statusPath = Join-Path $resolvedArtifactRoot "status_${RunId}.json"
$outputPath = Join-Path $resolvedArtifactRoot "claude_${RunId}.md"

if (-not (Test-Path -LiteralPath $configPath)) {
  throw "Missing delegate config: $configPath"
}
if (-not (Test-Path -LiteralPath $statusPath)) {
  throw "Missing delegate status: $statusPath"
}
if (-not (Test-Path -LiteralPath $outputPath)) {
  throw "Missing delegate output: $outputPath"
}

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$status = Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json

$expectedArtifactSchema = 2
$expectedInvocationContract = 'spawn_agent_child_only'
$expectedChildThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'

if (
  -not ($config.PSObject.Properties.Name -contains 'artifactSchema') -or
  -not ($config.PSObject.Properties.Name -contains 'invocationContract') -or
  -not ($status.PSObject.Properties.Name -contains 'artifactSchema') -or
  -not ($status.PSObject.Properties.Name -contains 'invocationContract')
) {
  throw 'Legacy delegate artifact is unsupported; rerun with current spawn_agent-based flow.'
}

if ([int]$config.artifactSchema -ne $expectedArtifactSchema -or [int]$status.artifactSchema -ne $expectedArtifactSchema) {
  throw "Unexpected delegate artifact schema. Expected $expectedArtifactSchema."
}

if ([string]$config.invocationContract -ne $expectedInvocationContract -or [string]$status.invocationContract -ne $expectedInvocationContract) {
  throw "Unexpected delegate invocation contract. Expected '$expectedInvocationContract'."
}
if (-not ($config.PSObject.Properties.Name -contains 'childThreadMarkerName') -or -not ($status.PSObject.Properties.Name -contains 'childThreadMarkerName')) {
  throw 'Delegate artifact is missing child-thread marker metadata.'
}
if ([string]$config.childThreadMarkerName -ne $expectedChildThreadMarkerName -or [string]$status.childThreadMarkerName -ne $expectedChildThreadMarkerName) {
  throw "Unexpected child-thread marker name. Expected '$expectedChildThreadMarkerName'."
}
if (-not ($config.PSObject.Properties.Name -contains 'childThreadMarkerValidated') -or -not ($status.PSObject.Properties.Name -contains 'childThreadMarkerValidated')) {
  throw 'Delegate artifact is missing child-thread validation state.'
}
if (-not [bool]$config.childThreadMarkerValidated -or -not [bool]$status.childThreadMarkerValidated) {
  throw 'Delegate artifact indicates the child-thread marker was not validated.'
}

if ([string]$config.outputPath -ne $outputPath) {
  throw "Config outputPath mismatch. Expected: $outputPath ; Actual: $([string]$config.outputPath)"
}
if ([string]$status.outputPath -ne $outputPath) {
  throw "Status outputPath mismatch. Expected: $outputPath ; Actual: $([string]$status.outputPath)"
}
if ([string]$status.status -notin @('starting', 'running', 'completed', 'failed')) {
  throw "Unexpected delegate status value: $([string]$status.status)"
}
$isCompleted = ([string]$status.status -eq 'completed')
$isStructuredFailure = ([string]$status.status -eq 'failed')
if (-not $isCompleted -and -not $isStructuredFailure) {
  throw "Delegate status is neither completed nor failed: $([string]$status.status)"
}
if (-not (Test-ClaudeDelegateHasFinalResult -Path $outputPath)) {
  throw "Delegate output does not contain a Final Result heading: $outputPath"
}
if ($isCompleted -and $status.PSObject.Properties.Name -contains 'exitCode' -and [int]$status.exitCode -ne 0) {
  throw "Delegate exitCode is not zero: $([int]$status.exitCode)"
}
if ($isStructuredFailure -and $status.PSObject.Properties.Name -contains 'exitCode' -and [int]$status.exitCode -eq 0) {
  throw 'Structured failed delegate must record a non-zero exitCode.'
}
if (-not ($status.PSObject.Properties.Name -contains 'attempts')) {
  throw 'Delegate status is missing attempts[] audit data.'
}
if (-not ($config.PSObject.Properties.Name -contains 'sessionMode')) {
  throw 'Delegate config is missing sessionMode.'
}
if (-not ($config.PSObject.Properties.Name -contains 'sessionKey')) {
  throw 'Delegate config is missing sessionKey.'
}

$attempts = @($status.attempts)
$statusAttemptCount = if ($status.PSObject.Properties.Name -contains 'attemptCount') { [int]$status.attemptCount } else { $attempts.Count }
$statusRetryCount = if ($status.PSObject.Properties.Name -contains 'retryCount') { [int]$status.retryCount } else { 0 }
$configAttemptCount = if ($config.PSObject.Properties.Name -contains 'attemptCount') { [int]$config.attemptCount } else { $statusAttemptCount }
$configRetryCount = if ($config.PSObject.Properties.Name -contains 'retryCount') { [int]$config.retryCount } else { $statusRetryCount }

if ($attempts.Count -ne $statusAttemptCount) {
  throw "Delegate attempts[] count mismatch. attempts=$($attempts.Count) status.attemptCount=$statusAttemptCount"
}
if ($statusAttemptCount -lt 1) {
  throw 'Delegate status must record at least one attempt.'
}
if ($configAttemptCount -ne $statusAttemptCount) {
  throw "Config/status attemptCount mismatch. config=$configAttemptCount status=$statusAttemptCount"
}
if ($configRetryCount -ne $statusRetryCount) {
  throw "Config/status retryCount mismatch. config=$configRetryCount status=$statusRetryCount"
}
if ($isStructuredFailure) {
  foreach ($propertyName in @('failureDisposition', 'failureSummary', 'maxRetryCount')) {
    if (-not ($status.PSObject.Properties.Name -contains $propertyName)) {
      throw "Structured failed delegate status is missing '$propertyName'."
    }
    if (-not ($config.PSObject.Properties.Name -contains $propertyName)) {
      throw "Structured failed delegate config is missing '$propertyName'."
    }
  }
  if ([string]$status.failureDisposition -ne 'NEED_HUMAN_INTERVENTION') {
    throw "Structured failed delegate must set failureDisposition to 'NEED_HUMAN_INTERVENTION'. Actual: $([string]$status.failureDisposition)"
  }
  if ([string]$config.failureDisposition -ne [string]$status.failureDisposition) {
    throw 'Structured failed delegate failureDisposition must match between config and status.'
  }
  if ([string]::IsNullOrWhiteSpace([string]$status.failureSummary)) {
    throw 'Structured failed delegate must record a non-empty failureSummary.'
  }
  if ([string]$config.failureSummary -ne [string]$status.failureSummary) {
    throw 'Structured failed delegate failureSummary must match between config and status.'
  }
  if ([int]$config.maxRetryCount -ne [int]$status.maxRetryCount) {
    throw 'Structured failed delegate maxRetryCount must match between config and status.'
  }
}

$recordedRetryReasons = 0
for ($i = 0; $i -lt $attempts.Count; $i++) {
  $attempt = $attempts[$i]
  foreach ($propertyName in @('attempt', 'sessionId', 'resume', 'retryReason', 'exitCode', 'sawAssistantText', 'sawResultSuccess', 'capturedFinalResult')) {
    if (-not ($attempt.PSObject.Properties.Name -contains $propertyName)) {
      throw "Delegate attempt[$i] is missing '$propertyName'."
    }
  }
  if ([int]$attempt.attempt -ne ($i + 1)) {
    throw "Delegate attempt numbering is not sequential at index $i. Expected $(($i + 1)) but found $([int]$attempt.attempt)."
  }
  if (-not [string]::IsNullOrWhiteSpace([string]$attempt.retryReason)) {
    $recordedRetryReasons++
  }
}

if ($recordedRetryReasons -ne $statusRetryCount) {
  throw "Delegate retry count mismatch. attempts-with-retryReason=$recordedRetryReasons status.retryCount=$statusRetryCount"
}

$firstAttempt = $attempts[0]
$finalAttempt = $attempts[$attempts.Count - 1]
if (-not ($config.PSObject.Properties.Name -contains 'initialSessionId')) {
  throw 'Delegate config is missing initialSessionId.'
}
if (-not ($config.PSObject.Properties.Name -contains 'initialResume')) {
  throw 'Delegate config is missing initialResume.'
}
if ([string]$config.initialSessionId -ne [string]$firstAttempt.sessionId) {
  throw "Config initialSessionId mismatch. Expected first attempt session $([string]$firstAttempt.sessionId) but found $([string]$config.initialSessionId)"
}
if ([bool]$config.initialResume -ne [bool]$firstAttempt.resume) {
  throw "Config initialResume mismatch. Expected first attempt resume $([bool]$firstAttempt.resume) but found $([bool]$config.initialResume)"
}
if ($config.PSObject.Properties.Name -contains 'sessionId' -and [string]$config.sessionId -ne [string]$finalAttempt.sessionId) {
  throw "Config final sessionId mismatch. Expected final attempt session $([string]$finalAttempt.sessionId) but found $([string]$config.sessionId)"
}
if ($config.PSObject.Properties.Name -contains 'resume' -and [bool]$config.resume -ne [bool]$finalAttempt.resume) {
  throw "Config final resume mismatch. Expected final attempt resume $([bool]$finalAttempt.resume) but found $([bool]$config.resume)"
}
if ([int]$finalAttempt.exitCode -ne [int]$status.exitCode) {
  throw "Final attempt exitCode mismatch. Expected $([int]$status.exitCode) but found $([int]$finalAttempt.exitCode)"
}
if ($isCompleted) {
  if (-not [bool]$finalAttempt.sawResultSuccess) {
    throw 'Completed delegate must record sawResultSuccess=true on the final attempt.'
  }
  if (-not [bool]$finalAttempt.capturedFinalResult) {
    throw 'Completed delegate must record capturedFinalResult=true on the final attempt.'
  }
}
if ($isStructuredFailure -and -not [bool]$finalAttempt.capturedFinalResult) {
  throw 'Structured failed delegate must record capturedFinalResult=true on the final attempt.'
}

$optionalPaths = @()
foreach ($propertyName in @('rawStreamPath', 'tracePath', 'promptPath')) {
  if ($config.PSObject.Properties.Name -contains $propertyName -and -not [string]::IsNullOrWhiteSpace([string]$config.$propertyName)) {
    $optionalPaths += [string]$config.$propertyName
  }
  if ($status.PSObject.Properties.Name -contains $propertyName -and -not [string]::IsNullOrWhiteSpace([string]$status.$propertyName)) {
    $optionalPaths += [string]$status.$propertyName
  }
}
foreach ($path in ($optionalPaths | Sort-Object -Unique)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Referenced artifact path is missing: $path"
  }
}

if (
  ($config.PSObject.Properties.Name -contains 'sessionStatePath') -and
  ($config.PSObject.Properties.Name -contains 'sessionKey') -and
  (-not [string]::IsNullOrWhiteSpace([string]$config.sessionStatePath)) -and
  (Test-Path -LiteralPath ([string]$config.sessionStatePath))
) {
  $sessionState = Get-Content -LiteralPath ([string]$config.sessionStatePath) -Raw | ConvertFrom-Json

  if ($sessionState.PSObject.Properties.Name -contains 'primary' -and
      $null -ne $sessionState.primary -and
      [string]$sessionState.primary.leaseRunId -eq $RunId) {
    throw "Primary session lease is still held by run $RunId."
  }

  if ($sessionState.PSObject.Properties.Name -contains 'parallelPool') {
    foreach ($slot in @($sessionState.parallelPool)) {
      if ([string]$slot.leaseRunId -eq $RunId) {
        throw "Parallel session lease is still held by run $RunId."
      }
    }
  }
}

Write-Host "Artifact verification passed for RunId: $RunId"
