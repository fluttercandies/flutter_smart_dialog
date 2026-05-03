param(
  [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
  [string]$Task,

  [Parameter(Mandatory = $true, ParameterSetName = 'File')]
  [string]$TaskFile,

  [string[]]$Scope = @(),
  [string[]]$Tests = @(),
  [ValidateSet('Implement', 'Fix', 'Review')]
  [string]$Mode = 'Implement',
  [string]$Model = 'sonnet',
  [ValidateSet('low', 'medium', 'high', 'xhigh', 'max')]
  [string]$Effort = 'high',
  [string]$Name,
  [string]$NamePrefix = 'codex-delegate',
  [Nullable[decimal]]$MaxBudgetUsd,
  [string]$ArtifactRoot,
  [string]$OutputPath,
  [switch]$AllowParallel,
  [ValidateSet('PrimaryReuse', 'PrimaryAnchor', 'ParallelPool')]
  [string]$SessionMode = 'PrimaryReuse',
  [string]$SessionKey,
  [int]$SessionLeaseTimeoutSeconds = 21600,
  [int]$SessionLeaseWaitSeconds = 120,
  [switch]$ResetPrimarySession,
  [switch]$ResetParallelPool,
  [int]$LockTimeoutSeconds = 120,
  [int]$LockPollMilliseconds = 500,
  [ValidateRange(0, 100)]
  [int]$MaxRetryCount = 5,
  [switch]$BypassPermissions,
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$artifactSchemaVersion = 2
$invocationContract = 'spawn_agent_child_only'
$requiredChildThreadMarkerName = 'CODEX_CLAUDE_CHILD_THREAD'
$requiredChildThreadMarkerValue = '1'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$workflowRoot = Join-Path $repoRoot 'docs\codex_with_cc'
$entryPath = Join-Path $workflowRoot 'CODEX_WITH_CC.md'
$sessionPoolHelperPath = Join-Path $PSScriptRoot 'claude_session_pool.ps1'
$backendHelperPath = Join-Path $PSScriptRoot 'claude_delegate_backend_helpers.ps1'

if ([string]::IsNullOrWhiteSpace($ArtifactRoot)) {
  $ArtifactRoot = Join-Path $repoRoot '.codex\claude-delegate'
}
$resolvedArtifactRoot = [System.IO.Path]::GetFullPath($ArtifactRoot)

if (-not (Test-Path -LiteralPath $sessionPoolHelperPath)) {
  throw "Missing Claude session pool helper: $sessionPoolHelperPath"
}
if (-not (Test-Path -LiteralPath $backendHelperPath)) {
  throw "Missing Claude delegate backend helper: $backendHelperPath"
}
. $sessionPoolHelperPath
. $backendHelperPath

if (-not (Test-Path -LiteralPath $entryPath)) {
  throw "Missing workflow entry document: $entryPath"
}

$childThreadMarker = [Environment]::GetEnvironmentVariable($requiredChildThreadMarkerName)
if ([string]$childThreadMarker -ne $requiredChildThreadMarkerValue) {
  throw "delegate_to_claude.ps1 may only run inside a Codex spawn_agent child thread. Missing required child-thread marker '$requiredChildThreadMarkerName=$requiredChildThreadMarkerValue'. Main-thread/direct invocation is forbidden."
}

$claudeCommand = Get-Command claude -ErrorAction SilentlyContinue
if ($null -eq $claudeCommand) {
  throw "Claude Code CLI was not found. Install or expose the 'claude' command first."
}

if ($PSCmdlet.ParameterSetName -eq 'File') {
  if (-not (Test-Path -LiteralPath $TaskFile)) {
    throw "Task file was not found: $TaskFile"
  }
  $taskText = Get-Content -LiteralPath $TaskFile -Raw
} else {
  $taskText = $Task
}

if ([string]::IsNullOrWhiteSpace($taskText)) {
  throw 'Task text cannot be empty.'
}

$Scope = @(Normalize-ClaudeDelegateList -Items $Scope)
$Tests = @(Normalize-ClaudeDelegateList -Items $Tests)

if (-not (Test-Path -LiteralPath $resolvedArtifactRoot)) {
  New-Item -ItemType Directory -Path $resolvedArtifactRoot -Force | Out-Null
}

$effectiveSessionKey = Get-EffectiveSessionKey -Value $SessionKey
$safeSessionKey = Get-SafeSessionKey -Value $effectiveSessionKey
$sessionPoolsRoot = Join-Path $resolvedArtifactRoot 'session-pools'
$sessionStatePath = Join-Path $sessionPoolsRoot "$safeSessionKey.json"
$sessionStateLockPath = Join-Path $sessionPoolsRoot "$safeSessionKey.lock"

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$runId = '{0}_{1}' -f $timestamp, ([guid]::NewGuid().ToString('N').Substring(0, 8))
$effectiveName = if ([string]::IsNullOrWhiteSpace($Name)) {
  '{0}-{1}' -f $NamePrefix, $runId
} else {
  $Name
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $resolvedArtifactRoot "claude_${runId}.md"
}
$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$statusPath = Join-Path $resolvedArtifactRoot "status_${runId}.json"
$configPath = Join-Path $resolvedArtifactRoot "config_${runId}.json"
$promptPath = Join-Path $resolvedArtifactRoot "prompt_${runId}.md"
$rawStreamPath = Join-Path $resolvedArtifactRoot "stream_${runId}.jsonl"
$tracePath = Join-Path $resolvedArtifactRoot "trace_${runId}.log"
$lockPath = Join-Path $resolvedArtifactRoot 'delegate.lock'
$taskFingerprint = Get-TaskFingerprint -Text $taskText -ScopeItems $Scope -TestItems $Tests -TaskMode $Mode
$sessionLease = $null

Test-ClaudeDelegatePathWritable -Path $resolvedOutputPath
Test-ClaudeDelegatePathWritable -Path $statusPath
Test-ClaudeDelegatePathWritable -Path $configPath
Test-ClaudeDelegatePathWritable -Path $rawStreamPath
Test-ClaudeDelegatePathWritable -Path $tracePath

$scopeText = if ($Scope.Count -gt 0) {
  ($Scope | ForEach-Object { "- $_" }) -join [Environment]::NewLine
} else {
  '- No explicit file scope was provided. Infer the narrowest safe scope from the task and current code.'
}

$testsText = if ($Tests.Count -gt 0) {
  ($Tests | ForEach-Object { "- $_" }) -join [Environment]::NewLine
} else {
  '- Run the smallest relevant verification you can identify from the change.'
}

$workerProtocolText = @"
- This prompt is already the only allowed Claude worker context for this delegated run.
- Never call `docs/codex_with_cc/scripts/delegate_to_claude.ps1`, `claude`, or `spawn_agent` recursively from inside this worker.
- Treat `docs/codex_with_cc/CODEX_WITH_CC.md` as the workflow contract to inspect when the task scope requires it, not as an execution recipe for this worker.
- If the task is an audit or validation, inspect the scoped files and run the listed verification commands directly instead of creating nested delegate runs.
- If you think another delegate run is required, stop and explain why in `Final Result` instead of invoking it yourself.
"@

$prompt = @"
You are Claude Code acting as an implementation worker for Codex.

This worker script is reserved for Codex `spawn_agent` child threads. It is not a valid main-thread entry point.

Codex owns architecture, task boundaries, and final review. Your job is to execute the delegated task directly in this repository, keep changes narrow, verify them, and report exactly what changed.

Repository root:
$repoRoot

Delegated output report path:
$resolvedOutputPath

Mode:
$Mode

Allowed / intended scope:
$scopeText

Required or expected verification:
$testsText

Worker protocol:
$workerProtocolText

Task:
$taskText

Hard requirements:
- Read docs/codex_with_cc/CODEX_WITH_CC.md before scanning other repository files.
- Use docs/codex_with_cc/CODEX_WITH_CC.md as the single workflow contract for delegation, audit flow, session mode interpretation, and worker report requirements.
- Keep edits inside the intended scope unless the task is impossible without a small supporting change.
- You must run necessary verification before handing work back. Run every command listed under Required or expected verification; if none is listed, infer the smallest meaningful format/analyze/test command for the changed area.
- Do not return code that you know fails to compile, analyze, or pass the required focused tests. Fix verification failures and rerun them until they pass.
- If verification is blocked by an external dependency or a clearly pre-existing unrelated failure, report the exact command, failure summary, and why it is not caused by your changes.
- Never claim verification passed unless you actually ran the command and saw it pass.
- Process and summarize your own CLI output. The Codex child thread will forward your final structured result; it should not reinterpret long logs for you.
- Treat this script as a child-thread worker entry only. Do not reinterpret it as permission for the Codex main thread to invoke Claude directly.
- Write enough detail in Process Log for the user to understand what happened, but keep raw verbose command output in the transcript/log instead of duplicating it.
- Finish with these exact headings:
  Process Log
  Summary
  Changed Files
  Verification
  Final Result
  Risks Or Follow-ups
"@

Set-Content -LiteralPath $promptPath -Value $prompt -Encoding UTF8

$configData = [ordered]@{
  artifactSchema = $artifactSchemaVersion
  invocationContract = $invocationContract
  childThreadMarkerName = $requiredChildThreadMarkerName
  childThreadMarkerValidated = $true
  runId = $runId
  repoRoot = $repoRoot
  mode = $Mode
  model = $Model
  effort = $Effort
  sessionName = $effectiveName
  sessionMode = $SessionMode
  sessionKey = $effectiveSessionKey
  sessionStatePath = $sessionStatePath
  sessionStateLockPath = $sessionStateLockPath
  promptPath = $promptPath
  outputPath = $resolvedOutputPath
  statusPath = $statusPath
  rawStreamPath = $rawStreamPath
  tracePath = $tracePath
  lockPath = $lockPath
  taskFile = if ($PSCmdlet.ParameterSetName -eq 'File') { [System.IO.Path]::GetFullPath($TaskFile) } else { $null }
  maxBudgetUsd = if ($null -ne $MaxBudgetUsd) { ([decimal]$MaxBudgetUsd).ToString([Globalization.CultureInfo]::InvariantCulture) } else { $null }
  bypassPermissions = [bool]$BypassPermissions
  allowParallel = [bool]$AllowParallel
  initialSessionId = $null
  initialResume = $null
  attemptCount = 0
  retryCount = 0
  maxRetryCount = $MaxRetryCount
}
Write-ClaudeDelegateJsonFile -Path $configPath -Data $configData

$statusData = [ordered]@{
  artifactSchema = $artifactSchemaVersion
  invocationContract = $invocationContract
  childThreadMarkerName = $requiredChildThreadMarkerName
  childThreadMarkerValidated = $true
  runId = $runId
  status = 'starting'
  pid = $PID
  outputPath = $resolvedOutputPath
  promptPath = $promptPath
  rawStreamPath = $rawStreamPath
  tracePath = $tracePath
  linesWritten = 0
  outputBytes = 0
  exitCode = $null
  attemptCount = 0
  retryCount = 0
  maxRetryCount = $MaxRetryCount
  attempts = @()
}
Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData

$lockStream = $null
if (-not $AllowParallel) {
  if ($LockTimeoutSeconds -lt 0) {
    throw "LockTimeoutSeconds must be >= 0. Current: $LockTimeoutSeconds"
  }
  if ($LockPollMilliseconds -lt 50) {
    throw "LockPollMilliseconds must be >= 50. Current: $LockPollMilliseconds"
  }

  $lockDeadline = (Get-Date).AddSeconds($LockTimeoutSeconds)
  while ($true) {
    try {
      $lockStream = [System.IO.File]::Open(
        $lockPath,
        [System.IO.FileMode]::OpenOrCreate,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None
      )
      $lockInfo = @{
        runId = $runId
        sessionName = $effectiveName
        pid = $PID
        startedAt = (Get-Date).ToString('o')
        mode = $Mode
      } | ConvertTo-Json -Compress

      $lockStream.SetLength(0)
      $writer = New-Object System.IO.StreamWriter($lockStream, (New-Object System.Text.UTF8Encoding($false)), 1024, $true)
      try {
        $writer.WriteLine($lockInfo)
        $writer.Flush()
      } finally {
        $writer.Dispose()
      }
      break
    } catch [System.IO.IOException] {
      if ((Get-Date) -ge $lockDeadline) {
        $lockSnapshot = ''
        if (Test-Path -LiteralPath $lockPath) {
          try {
            $lockSnapshot = Get-Content -LiteralPath $lockPath -Raw -ErrorAction Stop
          } catch {
            $lockSnapshot = '<unreadable>'
          }
        }
        throw "Another delegate_to_claude run is still active. Use -AllowParallel to bypass, or wait. Lock: $lockPath. Holder: $lockSnapshot"
      }
      Start-Sleep -Milliseconds $LockPollMilliseconds
    }
  }
}

$utf8NoBom = Set-ClaudeDelegateUtf8Console
$rawStreamWriter = $null
$traceWriter = $null
$captureState = @{
  assistantTexts = New-Object System.Collections.Generic.List[string]
  traceLines = New-Object System.Collections.Generic.List[string]
  finalText = ''
  sawAssistantText = $false
  sawResultSuccess = $false
  capturedFinalResultHeading = $false
}

Push-Location $repoRoot
try {
  $sessionLease = Acquire-ClaudeSessionLease `
    -StatePath $sessionStatePath `
    -LockPath $sessionStateLockPath `
    -Key $effectiveSessionKey `
    -Mode $SessionMode `
    -RunId $runId `
    -Fingerprint $taskFingerprint `
    -LeaseTimeoutSeconds $SessionLeaseTimeoutSeconds `
    -WaitSeconds $SessionLeaseWaitSeconds `
    -ResetPrimary ([bool]$ResetPrimarySession) `
    -ResetPool ([bool]$ResetParallelPool)

  $configData.sessionId = [string]$sessionLease.sessionId
  $configData.resume = [bool]$sessionLease.resume
  Write-ClaudeDelegateJsonFile -Path $configPath -Data $configData

  Write-Host "Delegating to Claude Code: $($claudeCommand.Source)"
  Write-Host "RunId: $runId"
  Write-Host "Session Name: $effectiveName"
  Write-Host "Session Mode: $SessionMode"
  Write-Host "Session Key: $effectiveSessionKey"
  Write-Host "Claude Session Id: $($sessionLease.sessionId)"
  Write-Host "Claude Session Argument: $(if ($sessionLease.resume) { '--resume' } else { '--session-id' }) $($sessionLease.sessionId)"
  Write-Host "Prompt: $promptPath"
  Write-Host "Output: $resolvedOutputPath"
  Write-Host "Status: $statusPath"
  Write-Host "Trace: $tracePath"
  Write-Host "Raw Stream: $rawStreamPath"

  if ($DryRun) {
    Write-Host 'Dry run enabled; Claude Code was not invoked.'
    $statusData.status = 'completed'
    $statusData.exitCode = 0
    Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData
    return
  }

  $statusData.status = 'running'
  Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData

  $rawStreamWriter = New-Object System.IO.StreamWriter($rawStreamPath, $false, $utf8NoBom)
  $traceWriter = New-Object System.IO.StreamWriter($tracePath, $false, $utf8NoBom)

  $promptText = Get-Content -LiteralPath $promptPath -Raw
  $attempt = 0
  $maxAttempts = $MaxRetryCount + 1
  $retryCount = 0
  $delegateSucceeded = $false
  $exitCode = -1
  $finalText = ''
  $outputResolution = $null
  $failureDisposition = ''
  $failureSummary = ''

  while ($attempt -lt $maxAttempts) {
    $attempt++
    $captureState = @{
      assistantTexts = New-Object System.Collections.Generic.List[string]
      traceLines = New-Object System.Collections.Generic.List[string]
      finalText = ''
      sawAssistantText = $false
      sawResultSuccess = $false
      capturedFinalResultHeading = $false
    }
    $attemptRawLines = New-Object System.Collections.Generic.List[string]
    $attemptRecord = [pscustomobject]([ordered]@{
      attempt = $attempt
      sessionId = [string]$sessionLease.sessionId
      resume = [bool]$sessionLease.resume
      retryReason = $null
      exitCode = $null
      sawAssistantText = $false
      sawResultSuccess = $false
      capturedFinalResult = $false
      sawStaleSessionText = $false
      sawStreamJsonVerboseError = $false
    })
    $claudeArgs = @(New-ClaudeDelegateCliArgs `
      -Model $Model `
      -Effort $Effort `
      -SessionName $effectiveName `
      -SessionId ([string]$sessionLease.sessionId) `
      -Resume ([bool]$sessionLease.resume) `
      -MaxBudgetUsd $MaxBudgetUsd `
      -BypassPermissions ([bool]$BypassPermissions) `
      -PromptText $promptText)

    if ($attempt -eq 1) {
      $configData.initialSessionId = [string]$sessionLease.sessionId
      $configData.initialResume = [bool]$sessionLease.resume
    }
    $configData.sessionId = [string]$sessionLease.sessionId
    $configData.resume = [bool]$sessionLease.resume
    $configData.attemptCount = $attempt
    $configData.retryCount = $retryCount
    Write-ClaudeDelegateJsonFile -Path $configPath -Data $configData

    $statusData.attemptCount = $attempt
    $statusData.retryCount = $retryCount
    $statusData.attempts = @($statusData.attempts + $attemptRecord)
    Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData

    Write-Host "Attempt $attempt/$maxAttempts"
    Write-Host "Claude Session Id: $($sessionLease.sessionId)"
    Write-Host "Claude Session Argument: $(if ($sessionLease.resume) { '--resume' } else { '--session-id' }) $($sessionLease.sessionId)"

    $traceWriter.WriteLine("[attempt] $attempt session=$($sessionLease.sessionId) resume=$([bool]$sessionLease.resume)")
    $traceWriter.Flush()

    & claude @claudeArgs 2>&1 | ForEach-Object {
      $lineText = [string]$_
      if ([string]::IsNullOrWhiteSpace($lineText)) {
        return
      }

      $attemptRawLines.Add($lineText)
      $rawStreamWriter.WriteLine($lineText)
      $rawStreamWriter.Flush()

      $traceLines = @()
      try {
        $record = $lineText | ConvertFrom-Json -Depth 30
        $traceLines = @(Update-ClaudeDelegateStreamCapture -Record $record -State $captureState)
      } catch {
        $traceLines = @('[raw] non-json output line')
      }

      foreach ($traceLine in $traceLines) {
        $traceWriter.WriteLine($traceLine)
      }
      $traceWriter.Flush()

      $statusData.linesWritten = [int]$statusData.linesWritten + 1
      $statusData.lastOutputAt = (Get-Date).ToString('o')
      Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData
    }

    $exitCode = [int]$LASTEXITCODE
    $finalText = [string]$captureState.finalText
    if ([string]::IsNullOrWhiteSpace($finalText) -and $captureState.assistantTexts.Count -gt 0) {
      $finalText = ($captureState.assistantTexts[$captureState.assistantTexts.Count - 1]).Trim()
    }

    $retryDecision = Get-ClaudeDelegateRetryDecision `
      -RawLines @($attemptRawLines.ToArray()) `
      -ResumeAttempt ([bool]$sessionLease.resume) `
      -ExitCode $exitCode `
      -SawAssistantText ([bool]$captureState.sawAssistantText) `
      -SawResultSuccess ([bool]$captureState.sawResultSuccess) `
      -CapturedFinalResultHeading ([bool]$captureState.capturedFinalResultHeading)

    $attemptRecord.exitCode = $exitCode
    $attemptRecord.sawAssistantText = [bool]$captureState.sawAssistantText
    $attemptRecord.sawResultSuccess = [bool]$captureState.sawResultSuccess
    $attemptRecord.capturedFinalResult = [bool]$captureState.capturedFinalResultHeading
    $attemptRecord.sawStaleSessionText = [bool]$retryDecision.sawStaleSessionText
    $attemptRecord.sawStreamJsonVerboseError = [bool]$retryDecision.sawStreamJsonVerboseError

    if ([bool]$retryDecision.shouldRetry -and $attempt -lt $maxAttempts) {
      $retryCount++
      $attemptRecord.retryReason = [string]$retryDecision.retryReason
      $statusData.retryCount = $retryCount
      $statusData.lastRetryReason = [string]$retryDecision.retryReason
      Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData
      if ([bool]$retryDecision.retryWithFreshSession) {
        Write-Warning "Claude rejected resumed session '$($sessionLease.sessionId)'. Retrying once with a fresh session."
        $traceWriter.WriteLine("[retry] stale session id rejected; resetting lease for a fresh Claude session")
        $traceWriter.Flush()

        $sessionLease = Reset-ClaudeSessionLeaseForFreshSession `
          -StatePath $sessionStatePath `
          -LockPath $sessionStateLockPath `
          -Key $effectiveSessionKey `
          -Lease $sessionLease `
          -RunId $runId `
          -Fingerprint $taskFingerprint `
          -Reason ([string]$retryDecision.retryReason)
      } else {
        Write-Warning "Claude startup failed before structured output was produced. Retrying once with the current session arguments."
        $traceWriter.WriteLine("[retry] stream-json startup failed before structured output; retrying with current session")
        $traceWriter.Flush()
      }

      continue
    }

    if ([bool]$retryDecision.shouldRetry) {
      $failureDisposition = 'NEED_HUMAN_INTERVENTION'
      $failureSummary = Get-ClaudeDelegateFailureSummary `
        -RawLines @($attemptRawLines.ToArray()) `
        -RetryReason ([string]$retryDecision.retryReason) `
        -AttemptCount $attempt `
        -MaxRetryCount $MaxRetryCount `
        -ExitCode $exitCode
      $statusData.failureDisposition = $failureDisposition
      $statusData.failureSummary = $failureSummary
      $statusData.finalRetryReason = [string]$retryDecision.retryReason
      $configData.failureDisposition = $failureDisposition
      $configData.failureSummary = $failureSummary
      $configData.finalRetryReason = [string]$retryDecision.retryReason
      Write-ClaudeDelegateJsonFile -Path $configPath -Data $configData
      Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData

      $traceWriter.WriteLine("[failure] retry ceiling reached; forcing NEED_HUMAN_INTERVENTION")
      $traceWriter.WriteLine("[failure] $failureSummary")
      $traceWriter.Flush()

      $finalText = @"
Process Log
- Delegate worker detected a retryable Claude failure and exhausted the configured retry budget.
- Automatic recovery stopped to avoid unbounded compute burn.

Summary
Automatic retry recovery hit the configured ceiling and requires human or Codex intervention.

Changed Files
None

Verification
- not run; the worker never reached a trustworthy execution state

Final Result
FAIL / NEED_HUMAN_INTERVENTION
$failureSummary

Risks Or Follow-ups
- Inspect Claude CLI startup/session health before retrying this delegated task again.
"@
    }

    $outputResolution = Get-ClaudeDelegateOutputResolution `
      -FinalText $finalText `
      -OutputPath $resolvedOutputPath `
      -ExitCode $exitCode `
      -SawResultSuccess ([bool]$captureState.sawResultSuccess) `
      -CapturedFinalResultHeading ([bool]$captureState.capturedFinalResultHeading)

    if ([bool]$outputResolution.existingStructuredOutput -or [bool]$outputResolution.finalTextHasFinalResult) {
      $attemptRecord.capturedFinalResult = $true
    }

    $delegateSucceeded = [bool]$outputResolution.delegateSucceeded
    break
  }

  if ($null -eq $outputResolution) {
    $outputResolution = Get-ClaudeDelegateOutputResolution `
      -FinalText $finalText `
      -OutputPath $resolvedOutputPath `
      -ExitCode $exitCode `
      -SawResultSuccess $false `
      -CapturedFinalResultHeading $false
  }

  if ([bool]$outputResolution.shouldPersistFinalText) {
    [System.IO.File]::WriteAllText($resolvedOutputPath, $finalText, $utf8NoBom)
  } elseif (-not (Test-Path -LiteralPath $resolvedOutputPath)) {
    [System.IO.File]::WriteAllText($resolvedOutputPath, 'Claude delegate finished without a structured text result.', $utf8NoBom)
  }

  $outputHasFinalResult = Test-ClaudeDelegateHasFinalResult -Path $resolvedOutputPath
  if ($statusData.attempts.Count -gt 0 -and $outputHasFinalResult) {
    $statusData.attempts[$statusData.attempts.Count - 1].capturedFinalResult = $true
  }

  $statusData.outputBytes = (Get-Item -LiteralPath $resolvedOutputPath).Length
  $statusData.exitCode = $exitCode
  $statusData.retryCount = $retryCount
  if ($delegateSucceeded -and $outputHasFinalResult) {
    $statusData.status = 'completed'
  } else {
    $statusData.status = 'failed'
  }
  if (-not [string]::IsNullOrWhiteSpace($failureDisposition)) {
    $statusData.failureDisposition = $failureDisposition
    $statusData.failureSummary = $failureSummary
    $configData.failureDisposition = $failureDisposition
    $configData.failureSummary = $failureSummary
    Write-ClaudeDelegateJsonFile -Path $configPath -Data $configData
  }
  Write-ClaudeDelegateJsonFile -Path $statusPath -Data $statusData

  if ($exitCode -ne 0) {
    if ([string]$failureDisposition -eq 'NEED_HUMAN_INTERVENTION') {
      throw "Claude delegate retry ceiling reached: $failureSummary"
    }
    throw "Claude Code exited with code $exitCode"
  }
  if ($statusData.status -ne 'completed') {
    if ([string]$failureDisposition -eq 'NEED_HUMAN_INTERVENTION') {
      throw "Claude delegate retry ceiling reached: $failureSummary"
    }
    throw "Claude Code finished without a valid structured Final Result report. Output: $resolvedOutputPath"
  }
} finally {
  if ($null -ne $rawStreamWriter) {
    $rawStreamWriter.Dispose()
  }
  if ($null -ne $traceWriter) {
    $traceWriter.Dispose()
  }

  Release-ClaudeSessionLease `
    -StatePath $sessionStatePath `
    -LockPath $sessionStateLockPath `
    -Key $effectiveSessionKey `
    -Lease $sessionLease `
    -RunId $runId `
    -Fingerprint $taskFingerprint

  if ($null -ne $lockStream) {
    try {
      $lockStream.Dispose()
    } finally {
      if (Test-Path -LiteralPath $lockPath) {
        try {
          Remove-Item -LiteralPath $lockPath -Force -ErrorAction Stop
        } catch {
          Write-Warning "Failed to remove lock file: $lockPath"
        }
      }
    }
  }
  Pop-Location
}
