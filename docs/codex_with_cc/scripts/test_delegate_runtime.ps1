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
    [AllowNull()]
    [object]$Actual,
    [Parameter(Mandatory = $true)]
    [AllowNull()]
    [object]$Expected,
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if ($Actual -ne $Expected) {
    throw "[$Name] expected '$Expected' but got '$Actual'"
  }
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

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "codex_with_cc_delegate_runtime_$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
  $backendHelperPath = Join-Path $PSScriptRoot 'claude_delegate_backend_helpers.ps1'
  $sessionPoolHelperPath = Join-Path $PSScriptRoot 'claude_session_pool.ps1'
  $verifyScriptPath = Join-Path $PSScriptRoot 'verify_delegate_artifacts.ps1'
  $verifyChainScriptPath = Join-Path $PSScriptRoot 'verify_delegate_chain.ps1'
  $realChainValidationScriptPath = Join-Path $PSScriptRoot 'run_real_delegate_chain_validation.ps1'

  Assert-True -Condition (Test-Path -LiteralPath $backendHelperPath) -Name 'backend-helper-exists'
  Assert-True -Condition (Test-Path -LiteralPath $sessionPoolHelperPath) -Name 'session-pool-helper-exists'
  Assert-True -Condition (Test-Path -LiteralPath $verifyScriptPath) -Name 'verify-script-exists'
  Assert-True -Condition (Test-Path -LiteralPath $verifyChainScriptPath) -Name 'verify-chain-script-exists'
  Assert-True -Condition (Test-Path -LiteralPath $realChainValidationScriptPath) -Name 'real-chain-validation-script-exists'

  . $backendHelperPath
  . $sessionPoolHelperPath

  Assert-True -Condition ($null -ne (Get-Command Update-ClaudeDelegateStreamCapture -ErrorAction SilentlyContinue)) -Name 'backend-helper-exports-stream-capture'
  Assert-True -Condition ($null -ne (Get-Command New-ClaudeDelegateCliArgs -ErrorAction SilentlyContinue)) -Name 'backend-helper-exports-cli-args'
  Assert-True -Condition ($null -ne (Get-Command Test-ClaudeDelegateNeedsFreshSessionRetry -ErrorAction SilentlyContinue)) -Name 'backend-helper-exports-fresh-session-retry-check'
  Assert-True -Condition ($null -ne (Get-Command Get-ClaudeDelegateRetryDecision -ErrorAction SilentlyContinue)) -Name 'backend-helper-exports-retry-decision'
  Assert-True -Condition ($null -ne (Get-Command Get-ClaudeDelegateFailureSummary -ErrorAction SilentlyContinue)) -Name 'backend-helper-exports-failure-summary'
  Assert-True -Condition ($null -ne (Get-Command Get-ClaudeDelegateOutputResolution -ErrorAction SilentlyContinue)) -Name 'backend-helper-exports-output-resolution'
  Assert-True -Condition ($null -ne (Get-Command Reset-ClaudeSessionLeaseForFreshSession -ErrorAction SilentlyContinue)) -Name 'session-pool-exports-fresh-reset'

  $missingChildThreadMarker = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'marker rejection probe',
    '-ArtifactRoot', (Join-Path $tempRoot 'marker-probe'),
    '-SessionKey', 'marker-probe',
    '-SessionMode', 'PrimaryReuse',
    '-DryRun'
  )
  Assert-True -Condition ($missingChildThreadMarker.ExitCode -ne 0) -Name 'missing-child-thread-marker-fails'
  Assert-True -Condition (($missingChildThreadMarker.Output -join [Environment]::NewLine).Contains('CODEX_CLAUDE_CHILD_THREAD=1')) -Name 'missing-child-thread-marker-names-required-marker'
  Assert-True -Condition (($missingChildThreadMarker.Output -join [Environment]::NewLine).Contains('may only run inside a Codex spawn_agent child thread')) -Name 'missing-child-thread-marker-error-is-clear'

  $dryRunArtifactRoot = Join-Path $tempRoot 'dry-run-max-retry'
  $dryRunResult = Invoke-DelegateWorkerScript -ArgumentList @(
    '-Task', 'dry run max retry probe',
    '-ArtifactRoot', $dryRunArtifactRoot,
    '-SessionKey', 'dry-run-max-retry',
    '-SessionMode', 'PrimaryReuse',
    '-MaxRetryCount', '7',
    '-DryRun'
  ) -SetChildThreadMarker
  if ($dryRunResult.ExitCode -ne 0) {
    throw "delegate dry run with explicit max retry count failed unexpectedly.`n$($dryRunResult.Output -join [Environment]::NewLine)"
  }
  $dryRunConfig = Get-Content -LiteralPath ((Get-ChildItem -LiteralPath $dryRunArtifactRoot -Filter 'config_*.json' | Select-Object -First 1).FullName) -Raw | ConvertFrom-Json
  $dryRunStatus = Get-Content -LiteralPath ((Get-ChildItem -LiteralPath $dryRunArtifactRoot -Filter 'status_*.json' | Select-Object -First 1).FullName) -Raw | ConvertFrom-Json
  Assert-Equal -Actual ([int]$dryRunConfig.maxRetryCount) -Expected 7 -Name 'dry-run-config-records-max-retry-count'
  Assert-Equal -Actual ([int]$dryRunStatus.maxRetryCount) -Expected 7 -Name 'dry-run-status-records-max-retry-count'

  $cliArgs = @(New-ClaudeDelegateCliArgs `
    -Model 'sonnet' `
    -Effort 'high' `
    -SessionName 'test-session' `
    -SessionId ([guid]::NewGuid().ToString()) `
    -Resume $false `
    -MaxBudgetUsd $null `
    -BypassPermissions $true `
    -PromptText 'hello')
  Assert-True -Condition ($cliArgs -contains '--verbose') -Name 'cli-args-include-verbose-for-stream-json'
  Assert-True -Condition ($cliArgs -contains '--print') -Name 'cli-args-include-explicit-print-flag'
  Assert-True -Condition ($cliArgs -contains 'stream-json') -Name 'cli-args-include-stream-json'
  Assert-True -Condition ($cliArgs.IndexOf('--verbose') -lt $cliArgs.IndexOf('--print')) -Name 'cli-args-place-verbose-before-print'
  Assert-True -Condition ($cliArgs.IndexOf('--print') -lt $cliArgs.IndexOf('--output-format')) -Name 'cli-args-place-print-before-output-format'

  $successfulResumeDecision = Get-ClaudeDelegateRetryDecision `
    -RawLines @('No conversation found with session ID: 123') `
    -ResumeAttempt $true `
    -ExitCode 0 `
    -SawAssistantText $true `
    -SawResultSuccess $true `
    -CapturedFinalResultHeading $true
  Assert-True -Condition (-not $successfulResumeDecision.shouldRetry) -Name 'successful-resume-does-not-retry-on-stale-text'
  Assert-Equal -Actual ([string]$successfulResumeDecision.retryReason) -Expected '' -Name 'successful-resume-has-empty-retry-reason'

  $staleDecision = Get-ClaudeDelegateRetryDecision `
    -RawLines @('No conversation found with session ID: 123') `
    -ResumeAttempt $true `
    -ExitCode 1 `
    -SawAssistantText $false `
    -SawResultSuccess $false `
    -CapturedFinalResultHeading $false
  Assert-True -Condition ($staleDecision.shouldRetry) -Name 'stale-session-retries'
  Assert-Equal -Actual ([string]$staleDecision.retryReason) -Expected 'stale_claude_session' -Name 'stale-session-retry-reason'
  Assert-True -Condition ($staleDecision.retryWithFreshSession) -Name 'stale-session-uses-fresh-session'

  $staleDecisionVariant = Get-ClaudeDelegateRetryDecision `
    -RawLines @('Error: No conversation found for requested session ID abc123') `
    -ResumeAttempt $true `
    -ExitCode 1 `
    -SawAssistantText $false `
    -SawResultSuccess $false `
    -CapturedFinalResultHeading $false
  Assert-True -Condition ($staleDecisionVariant.shouldRetry) -Name 'stale-session-variant-retries'
  Assert-Equal -Actual ([string]$staleDecisionVariant.retryReason) -Expected 'stale_claude_session' -Name 'stale-session-variant-retry-reason'

  $streamJsonDecision = Get-ClaudeDelegateRetryDecision `
    -RawLines @('Error: When using --print, --output-format=stream-json requires --verbose') `
    -ResumeAttempt $false `
    -ExitCode 1 `
    -SawAssistantText $false `
    -SawResultSuccess $false `
    -CapturedFinalResultHeading $false
  Assert-True -Condition ($streamJsonDecision.shouldRetry) -Name 'stream-json-startup-error-retries'
  Assert-Equal -Actual ([string]$streamJsonDecision.retryReason) -Expected 'stream_json_startup' -Name 'stream-json-startup-retry-reason'
  Assert-True -Condition (-not $streamJsonDecision.retryWithFreshSession) -Name 'stream-json-startup-does-not-force-fresh-session'

  $streamJsonDecisionVariant = Get-ClaudeDelegateRetryDecision `
    -RawLines @('Error: stream-json output requires the --verbose flag when printing') `
    -ResumeAttempt $false `
    -ExitCode 1 `
    -SawAssistantText $false `
    -SawResultSuccess $false `
    -CapturedFinalResultHeading $false
  Assert-True -Condition ($streamJsonDecisionVariant.shouldRetry) -Name 'stream-json-startup-variant-retries'
  Assert-Equal -Actual ([string]$streamJsonDecisionVariant.retryReason) -Expected 'stream_json_startup' -Name 'stream-json-startup-variant-retry-reason'

  $toolResultFalsePositiveDecision = Get-ClaudeDelegateRetryDecision `
    -RawLines @(
      '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"throw \"No conversation found with session ID\"; throw \"stream-json requires --verbose\""}]}}'
    ) `
    -ResumeAttempt $true `
    -ExitCode 0 `
    -SawAssistantText $true `
    -SawResultSuccess $true `
    -CapturedFinalResultHeading $true
  Assert-True -Condition (-not $toolResultFalsePositiveDecision.shouldRetry) -Name 'tool-result-content-does-not-trigger-retry'
  Assert-True -Condition (-not $toolResultFalsePositiveDecision.sawStaleSessionText) -Name 'tool-result-content-does-not-trigger-stale-flag'
  Assert-True -Condition (-not $toolResultFalsePositiveDecision.sawStreamJsonVerboseError) -Name 'tool-result-content-does-not-trigger-stream-json-flag'

  $failureSummary = Get-ClaudeDelegateFailureSummary `
    -RawLines @(
      'Error: stream-json output requires the --verbose flag when printing',
      'Error: transient startup fault',
      'Noise that should be ignored once limit is reached'
    ) `
    -RetryReason 'stream_json_startup' `
    -AttemptCount 6 `
    -MaxRetryCount 5 `
    -ExitCode 1
  Assert-True -Condition ($failureSummary.Contains('NEED_HUMAN_INTERVENTION')) -Name 'failure-summary-names-human-intervention'
  Assert-True -Condition ($failureSummary.Contains('stream_json_startup')) -Name 'failure-summary-includes-retry-reason'
  Assert-True -Condition ($failureSummary.Contains('attempt 6/6')) -Name 'failure-summary-includes-attempt-ceiling'
  Assert-True -Condition ($failureSummary.Contains('stream-json output requires the --verbose flag when printing')) -Name 'failure-summary-includes-error-snippet'

  $captureState = @{
    assistantTexts = New-Object System.Collections.Generic.List[string]
    traceLines = New-Object System.Collections.Generic.List[string]
    finalText = ''
    sawAssistantText = $false
    sawResultSuccess = $false
    capturedFinalResultHeading = $false
  }
  $records = @(
    '{"type":"system","subtype":"status","status":"requesting"}',
    '{"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"thinking_delta","thinking":"hidden"}}}',
    '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Process Log\nSummary\nChanged Files\nVerification\nFinal Result\nok\nRisks Or Follow-ups"}]}}',
    '{"type":"result","subtype":"success"}'
  )
  foreach ($recordLine in $records) {
    $record = $recordLine | ConvertFrom-Json -Depth 20
    Update-ClaudeDelegateStreamCapture -Record $record -State $captureState | Out-Null
  }
  Assert-True -Condition ($captureState.finalText -like '*Final Result*') -Name 'stream-capture-extracts-final-text'
  Assert-True -Condition ($captureState.traceLines.Count -ge 2) -Name 'stream-capture-produces-trace'
  Assert-True -Condition ($captureState.sawAssistantText) -Name 'stream-capture-flags-assistant-text'
  Assert-True -Condition ($captureState.sawResultSuccess) -Name 'stream-capture-flags-result-success'
  Assert-True -Condition ($captureState.capturedFinalResultHeading) -Name 'stream-capture-flags-final-result-heading'

  $existingStructuredOutputPath = Join-Path $tempRoot 'existing-structured-output.md'
  $existingStructuredOutput = @"
Process Log
- Existing structured report

Summary
Kept

Changed Files
None

Verification
- n/a

Final Result
delegate-ok

Risks Or Follow-ups
None
"@
  [System.IO.File]::WriteAllText($existingStructuredOutputPath, $existingStructuredOutput, (New-Object System.Text.UTF8Encoding($false)))
  $outputResolution = Get-ClaudeDelegateOutputResolution `
    -FinalText '任务完成，详细报告已直接写入委托输出文件。' `
    -OutputPath $existingStructuredOutputPath `
    -ExitCode 0 `
    -SawResultSuccess $true `
    -CapturedFinalResultHeading $false
  Assert-True -Condition ($outputResolution.delegateSucceeded) -Name 'existing-structured-output-counts-as-success'
  Assert-True -Condition ($outputResolution.existingStructuredOutput) -Name 'existing-structured-output-detected'
  Assert-True -Condition (-not $outputResolution.shouldPersistFinalText) -Name 'existing-structured-output-is-not-overwritten'

  $runId = 'artifact-verify-test'
  $artifactRoot = Join-Path $tempRoot 'artifact-root'
  $sessionPoolsRoot = Join-Path $artifactRoot 'session-pools'
  New-Item -ItemType Directory -Path $sessionPoolsRoot -Force | Out-Null
  $statusVerifyPath = Join-Path $artifactRoot "status_${runId}.json"
  $outputVerifyPath = Join-Path $artifactRoot "claude_${runId}.md"
  $configVerifyPath = Join-Path $artifactRoot "config_${runId}.json"
  $promptVerifyPath = Join-Path $artifactRoot "prompt_${runId}.md"
  $streamVerifyPath = Join-Path $artifactRoot "stream_${runId}.jsonl"
  $traceVerifyPath = Join-Path $artifactRoot "trace_${runId}.log"
  $sessionKey = 'artifact-verify-session'
  $sessionStatePath = Join-Path $sessionPoolsRoot "$sessionKey.json"
  $sessionState = @{
    version = 1
    sessionKey = $sessionKey
    createdAt = (Get-Date).ToString('o')
    updatedAt = (Get-Date).ToString('o')
    primary = @{
      sessionId = [guid]::NewGuid().ToString()
      status = 'available'
      leaseRunId = $null
      leasedAt = $null
      lastUsedAt = (Get-Date).ToString('o')
      lastRunId = $runId
    }
    parallelPool = @()
  }
  $verifyOutput = @"
Process Log
- 中文校验

Summary
完成

Changed Files
None

Verification
- read only

Final Result
delegate-ok

Risks Or Follow-ups
None
"@
  [System.IO.File]::WriteAllText($outputVerifyPath, $verifyOutput, (New-Object System.Text.UTF8Encoding($false)))
  [System.IO.File]::WriteAllText($promptVerifyPath, '# prompt', (New-Object System.Text.UTF8Encoding($false)))
  [System.IO.File]::WriteAllText($streamVerifyPath, '{"type":"result"}', (New-Object System.Text.UTF8Encoding($false)))
  [System.IO.File]::WriteAllText($traceVerifyPath, '[00:00:00] ok', (New-Object System.Text.UTF8Encoding($false)))
  Write-ClaudeDelegateJsonFile -Path $statusVerifyPath -Data @{
    artifactSchema = 2
    invocationContract = 'spawn_agent_child_only'
    childThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
    childThreadMarkerValidated = $true
    runId = $runId
    status = 'completed'
    outputPath = $outputVerifyPath
    promptPath = $promptVerifyPath
    rawStreamPath = $streamVerifyPath
    tracePath = $traceVerifyPath
    exitCode = 0
    attemptCount = 2
    retryCount = 1
    attempts = @(
      @{
        attempt = 1
        sessionId = 'resume-session'
        resume = $true
        retryReason = 'stale_claude_session'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 2
        sessionId = 'fresh-session'
        resume = $false
        retryReason = $null
        exitCode = 0
        sawAssistantText = $true
        sawResultSuccess = $true
        capturedFinalResult = $true
      }
    )
  }
  Write-ClaudeDelegateJsonFile -Path $configVerifyPath -Data @{
    artifactSchema = 2
    invocationContract = 'spawn_agent_child_only'
    childThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
    childThreadMarkerValidated = $true
    runId = $runId
    outputPath = $outputVerifyPath
    statusPath = $statusVerifyPath
    promptPath = $promptVerifyPath
    sessionKey = $sessionKey
    sessionStatePath = $sessionStatePath
    sessionMode = 'PrimaryReuse'
    rawStreamPath = $streamVerifyPath
    tracePath = $traceVerifyPath
    initialSessionId = 'resume-session'
    initialResume = $true
    sessionId = 'fresh-session'
    resume = $false
    attemptCount = 2
    retryCount = 1
  }
  $sessionState | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $sessionStatePath -Encoding UTF8

  $verifyOutputText = & pwsh -NoProfile -File $verifyScriptPath -RunId $runId -ArtifactRoot $artifactRoot 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "verify_delegate_artifacts failed unexpectedly.`n$($verifyOutputText -join [Environment]::NewLine)"
  }
  Assert-True -Condition (($verifyOutputText -join [Environment]::NewLine).Contains('Artifact verification passed')) -Name 'verify-script-reports-success'

  $legacyRunId = 'artifact-verify-legacy'
  $legacyStatusPath = Join-Path $artifactRoot "status_${legacyRunId}.json"
  $legacyOutputPath = Join-Path $artifactRoot "claude_${legacyRunId}.md"
  $legacyConfigPath = Join-Path $artifactRoot "config_${legacyRunId}.json"
  [System.IO.File]::WriteAllText($legacyOutputPath, $verifyOutput, (New-Object System.Text.UTF8Encoding($false)))
  Write-ClaudeDelegateJsonFile -Path $legacyStatusPath -Data @{
    runId = $legacyRunId
    status = 'completed'
    outputPath = $legacyOutputPath
    exitCode = 0
  }
  Write-ClaudeDelegateJsonFile -Path $legacyConfigPath -Data @{
    runId = $legacyRunId
    outputPath = $legacyOutputPath
    statusPath = $legacyStatusPath
  }

  $legacyVerifyOutputText = & pwsh -NoProfile -File $verifyScriptPath -RunId $legacyRunId -ArtifactRoot $artifactRoot 2>&1
  Assert-True -Condition ($LASTEXITCODE -ne 0) -Name 'legacy-verify-script-fails'
  Assert-True -Condition (($legacyVerifyOutputText -join [Environment]::NewLine).Contains('Legacy delegate artifact is unsupported')) -Name 'legacy-verify-script-has-clear-error'

  $failedRunId = 'artifact-verify-failed'
  $failedStatusPath = Join-Path $artifactRoot "status_${failedRunId}.json"
  $failedOutputPath = Join-Path $artifactRoot "claude_${failedRunId}.md"
  $failedConfigPath = Join-Path $artifactRoot "config_${failedRunId}.json"
  $failedPromptPath = Join-Path $artifactRoot "prompt_${failedRunId}.md"
  $failedStreamPath = Join-Path $artifactRoot "stream_${failedRunId}.jsonl"
  $failedTracePath = Join-Path $artifactRoot "trace_${failedRunId}.log"
  $failedSummary = 'NEED_HUMAN_INTERVENTION after exhausting retry budget. retryReason=stream_json_startup. attempt 6/6. Error: stream-json output requires the --verbose flag when printing'
  $failedOutput = @"
Process Log
- Retry ceiling reached during delegate startup recovery.

Summary
Automatic retry budget exhausted.

Changed Files
None

Verification
- not run; worker never reached repository mutation stage

Final Result
FAIL / NEED_HUMAN_INTERVENTION
$failedSummary

Risks Or Follow-ups
- A human or Codex orchestration layer must inspect the delegate startup failure before retrying again.
"@
  [System.IO.File]::WriteAllText($failedOutputPath, $failedOutput, (New-Object System.Text.UTF8Encoding($false)))
  [System.IO.File]::WriteAllText($failedPromptPath, '# prompt', (New-Object System.Text.UTF8Encoding($false)))
  [System.IO.File]::WriteAllText($failedStreamPath, '{"type":"result","subtype":"error"}', (New-Object System.Text.UTF8Encoding($false)))
  [System.IO.File]::WriteAllText($failedTracePath, '[00:00:00] retry budget exhausted', (New-Object System.Text.UTF8Encoding($false)))
  Write-ClaudeDelegateJsonFile -Path $failedStatusPath -Data @{
    artifactSchema = 2
    invocationContract = 'spawn_agent_child_only'
    childThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
    childThreadMarkerValidated = $true
    runId = $failedRunId
    status = 'failed'
    outputPath = $failedOutputPath
    promptPath = $failedPromptPath
    rawStreamPath = $failedStreamPath
    tracePath = $failedTracePath
    exitCode = 1
    attemptCount = 6
    retryCount = 5
    maxRetryCount = 5
    failureDisposition = 'NEED_HUMAN_INTERVENTION'
    failureSummary = $failedSummary
    lastRetryReason = 'stream_json_startup'
    attempts = @(
      @{
        attempt = 1
        sessionId = 'failed-session-1'
        resume = $false
        retryReason = 'stream_json_startup'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 2
        sessionId = 'failed-session-1'
        resume = $false
        retryReason = 'stream_json_startup'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 3
        sessionId = 'failed-session-1'
        resume = $false
        retryReason = 'stream_json_startup'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 4
        sessionId = 'failed-session-1'
        resume = $false
        retryReason = 'stream_json_startup'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 5
        sessionId = 'failed-session-1'
        resume = $false
        retryReason = 'stream_json_startup'
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $false
      },
      @{
        attempt = 6
        sessionId = 'failed-session-1'
        resume = $false
        retryReason = $null
        exitCode = 1
        sawAssistantText = $false
        sawResultSuccess = $false
        capturedFinalResult = $true
      }
    )
  }
  Write-ClaudeDelegateJsonFile -Path $failedConfigPath -Data @{
    artifactSchema = 2
    invocationContract = 'spawn_agent_child_only'
    childThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
    childThreadMarkerValidated = $true
    runId = $failedRunId
    outputPath = $failedOutputPath
    statusPath = $failedStatusPath
    promptPath = $failedPromptPath
    sessionKey = 'artifact-verify-failed-session'
    sessionStatePath = $sessionStatePath
    sessionMode = 'PrimaryReuse'
    rawStreamPath = $failedStreamPath
    tracePath = $failedTracePath
    initialSessionId = 'failed-session-1'
    initialResume = $false
    sessionId = 'failed-session-1'
    resume = $false
    attemptCount = 6
    retryCount = 5
    maxRetryCount = 5
    failureDisposition = 'NEED_HUMAN_INTERVENTION'
    failureSummary = $failedSummary
  }

  $failedVerifyOutputText = & pwsh -NoProfile -File $verifyScriptPath -RunId $failedRunId -ArtifactRoot $artifactRoot 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "verify_delegate_artifacts should accept structured failed artifact.`n$($failedVerifyOutputText -join [Environment]::NewLine)"
  }
  Assert-True -Condition (($failedVerifyOutputText -join [Environment]::NewLine).Contains('Artifact verification passed')) -Name 'failed-artifact-verification-passes'

  $validationRoot = Join-Path $tempRoot 'real-chain-validation'
  $validationOutputText = & pwsh -NoProfile -File $realChainValidationScriptPath `
    -ValidationRoot $validationRoot `
    -Name 'sample-real-chain' `
    -SessionKey 'sample-real-chain-session' 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "run_real_delegate_chain_validation failed unexpectedly.`n$($validationOutputText -join [Environment]::NewLine)"
  }
  $validationTaskRoot = Join-Path $validationRoot 'sample-real-chain\tasks'
  $validationArtifactRoot = Join-Path $validationRoot 'sample-real-chain\artifacts'
  Assert-True -Condition (Test-Path -LiteralPath $validationTaskRoot) -Name 'real-chain-validation-creates-task-root'
  $validationTasks = Get-ChildItem -LiteralPath $validationTaskRoot -Filter '*.md'
  Assert-Equal -Actual $validationTasks.Count -Expected 5 -Name 'real-chain-validation-creates-five-tasks'
  Assert-True -Condition (($validationOutputText -join [Environment]::NewLine).Contains('verify_delegate_chain.ps1')) -Name 'real-chain-validation-prints-chain-verify-command'
  $anchorTaskText = Get-Content -LiteralPath (Join-Path $validationTaskRoot 'anchor-read-protocol.md') -Raw
  $reuseTaskText = Get-Content -LiteralPath (Join-Path $validationTaskRoot 'reuse-cross-check-1.md') -Raw
  Assert-True -Condition ($anchorTaskText.Contains('SessionKey: sample-real-chain-session')) -Name 'real-chain-validation-expands-session-key'
  Assert-True -Condition ($anchorTaskText.Contains("ArtifactRoot: $validationArtifactRoot")) -Name 'real-chain-validation-expands-artifact-root'
  Assert-True -Condition ($anchorTaskText.Contains('SessionMode: PrimaryAnchor')) -Name 'real-chain-validation-expands-session-mode'
  Assert-True -Condition (-not $anchorTaskText.Contains('$SessionKey')) -Name 'real-chain-validation-does-not-leak-sessionkey-placeholder'
  Assert-True -Condition (-not $anchorTaskText.Contains('$artifactRoot')) -Name 'real-chain-validation-does-not-leak-artifactroot-placeholder'
  Assert-True -Condition (-not $anchorTaskText.Contains('$($taskSpec.SessionMode)')) -Name 'real-chain-validation-does-not-leak-sessionmode-placeholder'
  Assert-True -Condition (-not $anchorTaskText.Contains([string][char]11)) -Name 'real-chain-validation-does-not-emit-vertical-tab'
  Assert-True -Condition ($reuseTaskText.Contains('允许在允许范围内修改仓库文件')) -Name 'real-chain-validation-allows-reuse-repair-writes'
  Assert-True -Condition ($reuseTaskText.Contains('docs/codex_with_cc/CODEX_WITH_CC.md')) -Name 'real-chain-validation-reuse-scope-includes-codex-with-cc-entry'
  Assert-True -Condition (-not $reuseTaskText.Contains('docs/codex_with_cc/CLAUDE_CODE_DELEGATION.md')) -Name 'real-chain-validation-reuse-scope-omits-delegation-protocol'
  Assert-True -Condition (-not $reuseTaskText.Contains('docs/codex_with_cc/HOST_PROJECT_RULES.md')) -Name 'real-chain-validation-reuse-scope-omits-host-rules'
  Assert-True -Condition (-not $reuseTaskText.Contains('docs/codex_with_cc/PROJECT_MEMORY.md')) -Name 'real-chain-validation-reuse-scope-omits-project-memory'

  $sessionPoolHelperLiteralPath = $sessionPoolHelperPath.Replace("'", "''")
  $sessionWarningOutput = & pwsh -NoProfile -Command @'
    $env:CODEX_THREAD_ID = $null
    $env:CODEX_SESSION_ID = $null
    . '__SESSION_POOL_HELPER_PATH__'
    $value = Get-EffectiveSessionKey
    Write-Host "SESSION=$value"
'@.Replace('__SESSION_POOL_HELPER_PATH__', $sessionPoolHelperLiteralPath) 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "session key fallback probe failed.`n$($sessionWarningOutput -join [Environment]::NewLine)"
  }
  Assert-True -Condition (($sessionWarningOutput -join [Environment]::NewLine).Contains('SESSION=default')) -Name 'session-fallback-still-returns-default'
  Assert-True -Condition (($sessionWarningOutput -join [Environment]::NewLine).Contains('default Claude session key fallback')) -Name 'session-fallback-warns'

  Write-Host 'delegate runtime tests passed' -ForegroundColor Green
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
