Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Set-ClaudeDelegateUtf8Console {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [Console]::InputEncoding = $utf8NoBom
  [Console]::OutputEncoding = $utf8NoBom
  $global:OutputEncoding = $utf8NoBom
  chcp.com 65001 > $null
  return $utf8NoBom
}

function Write-ClaudeDelegateJsonFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][object]$Data
  )

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $directory = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
  }

  $payload = $Data
  if ($payload -is [hashtable]) {
    $payload = [ordered]@{} + $payload
  }
  if ($payload.PSObject.Properties.Name -contains 'updatedAt') {
    $payload.updatedAt = (Get-Date).ToString('o')
  } else {
    $payload | Add-Member -NotePropertyName updatedAt -NotePropertyValue ((Get-Date).ToString('o')) -Force
  }

  $json = $payload | ConvertTo-Json -Depth 12
  $tempPath = Join-Path $directory ('.{0}.{1}.tmp' -f ([IO.Path]::GetFileName($Path)), ([guid]::NewGuid().ToString('N')))
  try {
    [System.IO.File]::WriteAllText($tempPath, $json, $utf8NoBom)
    Move-Item -LiteralPath $tempPath -Destination $Path -Force
  } finally {
    if (Test-Path -LiteralPath $tempPath) {
      Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    }
  }
}

function Test-ClaudeDelegateTextHasFinalResultHeading {
  param([AllowNull()][string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return $false
  }

  return ($Text -match '(?m)^(?:#+\s*)?Final Result\s*$')
}

function Test-ClaudeDelegateHasFinalResult {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $content = Get-Content -LiteralPath $Path -Raw
  return (Test-ClaudeDelegateTextHasFinalResultHeading -Text $content)
}

function Get-ClaudeDelegateOutputResolution {
  param(
    [AllowNull()][string]$FinalText,
    [AllowNull()][string]$OutputPath,
    [Parameter(Mandatory = $true)][int]$ExitCode,
    [Parameter(Mandatory = $true)][bool]$SawResultSuccess,
    [Parameter(Mandatory = $true)][bool]$CapturedFinalResultHeading
  )

  $finalTextHasFinalResult = Test-ClaudeDelegateTextHasFinalResultHeading -Text $FinalText
  $existingStructuredOutput = Test-ClaudeDelegateHasFinalResult -Path $OutputPath
  $shouldPersistFinalText = (
    $finalTextHasFinalResult -or
    (-not $existingStructuredOutput -and -not [string]::IsNullOrWhiteSpace($FinalText))
  )
  $delegateSucceeded = (
    $ExitCode -eq 0 -and
    $SawResultSuccess -and
    ($CapturedFinalResultHeading -or $finalTextHasFinalResult -or $existingStructuredOutput)
  )

  return [pscustomobject]([ordered]@{
    finalTextHasFinalResult = $finalTextHasFinalResult
    existingStructuredOutput = $existingStructuredOutput
    shouldPersistFinalText = $shouldPersistFinalText
    delegateSucceeded = $delegateSucceeded
  })
}

function Test-ClaudeDelegatePidAlive {
  param([AllowNull()][object]$ProcessId)

  if ($null -eq $ProcessId) {
    return $false
  }
  $resolvedProcessId = [int]$ProcessId
  if ($resolvedProcessId -le 0) {
    return $false
  }

  $process = Get-Process -Id $resolvedProcessId -ErrorAction SilentlyContinue
  return ($null -ne $process)
}

function Test-ClaudeDelegatePathWritable {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $directory = Split-Path -Parent $fullPath
  if (-not (Test-Path -LiteralPath $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
  }

  $probePath = Join-Path $directory ('.write_probe_{0}.tmp' -f ([guid]::NewGuid().ToString('N')))
  try {
    [System.IO.File]::WriteAllText($probePath, 'ok', (New-Object System.Text.UTF8Encoding($false)))
    Remove-Item -LiteralPath $probePath -Force
  } catch {
    throw "Path is not writable: $fullPath. $($_.Exception.Message)"
  }
}

function Get-ClaudeDelegateTextBlocks {
  param([AllowNull()][object]$Content)

  if ($null -eq $Content) {
    return @()
  }

  $items = if ($Content -is [System.Collections.IEnumerable] -and -not ($Content -is [string])) {
    @($Content)
  } else {
    @($Content)
  }

  $texts = New-Object System.Collections.Generic.List[string]
  foreach ($item in $items) {
    if ($null -eq $item) {
      continue
    }
    $itemType = if ($item.PSObject.Properties.Name -contains 'type') { [string]$item.type } else { '' }
    if ($itemType -eq 'text' -and $item.PSObject.Properties.Name -contains 'text' -and -not [string]::IsNullOrWhiteSpace([string]$item.text)) {
      $texts.Add([string]$item.text)
    }
  }
  return @($texts)
}

function Update-ClaudeDelegateStreamCapture {
  param(
    [Parameter(Mandatory = $true)][object]$Record,
    [Parameter(Mandatory = $true)][hashtable]$State
  )

  if (-not $State.ContainsKey('assistantTexts')) {
    $State.assistantTexts = New-Object System.Collections.Generic.List[string]
  }
  if (-not $State.ContainsKey('traceLines')) {
    $State.traceLines = New-Object System.Collections.Generic.List[string]
  }
  if (-not $State.ContainsKey('finalText')) {
    $State.finalText = ''
  }
  if (-not $State.ContainsKey('sawAssistantText')) {
    $State.sawAssistantText = $false
  }
  if (-not $State.ContainsKey('sawResultSuccess')) {
    $State.sawResultSuccess = $false
  }
  if (-not $State.ContainsKey('capturedFinalResultHeading')) {
    $State.capturedFinalResultHeading = $false
  }

  $traceLines = New-Object System.Collections.Generic.List[string]
  $recordType = if ($Record.PSObject.Properties.Name -contains 'type') { [string]$Record.type } else { '' }

  switch ($recordType) {
    'system' {
      $subtype = if ($Record.PSObject.Properties.Name -contains 'subtype') { [string]$Record.subtype } else { '' }
      $status = if ($Record.PSObject.Properties.Name -contains 'status') { [string]$Record.status } else { '' }
      $parts = @('[system]')
      if (-not [string]::IsNullOrWhiteSpace($subtype)) { $parts += $subtype }
      if (-not [string]::IsNullOrWhiteSpace($status)) { $parts += $status }
      $traceLines.Add(($parts -join ' '))
      break
    }
    'assistant' {
      $message = if ($Record.PSObject.Properties.Name -contains 'message') { $Record.message } else { $null }
      $messageId = if ($null -ne $message -and $message.PSObject.Properties.Name -contains 'id') { [string]$message.id } else { '' }
      $texts = if ($null -ne $message -and $message.PSObject.Properties.Name -contains 'content') { @(Get-ClaudeDelegateTextBlocks -Content $message.content) } else { @() }
      if ($messageId) {
        $traceLines.Add("[assistant] message=$messageId")
      } else {
        $traceLines.Add('[assistant]')
      }
      if (@($texts).Count -gt 0) {
        $text = ($texts -join [Environment]::NewLine).Trim()
        if (-not [string]::IsNullOrWhiteSpace($text)) {
          $State.sawAssistantText = $true
          if (Test-ClaudeDelegateTextHasFinalResultHeading -Text $text) {
            $State.capturedFinalResultHeading = $true
          }
          $State.assistantTexts.Add($text)
          $State.finalText = $text
        }
      }
      break
    }
    'result' {
      $subtype = if ($Record.PSObject.Properties.Name -contains 'subtype') { [string]$Record.subtype } else { '' }
      $cost = if ($Record.PSObject.Properties.Name -contains 'cost_usd') { [string]$Record.cost_usd } else { '' }
      $line = '[result]'
      if ($subtype) { $line += " $subtype" }
      if ($cost) { $line += " cost=$cost" }
      if ($subtype -eq 'success') {
        $State.sawResultSuccess = $true
      }
      $traceLines.Add($line)
      break
    }
    'stream_event' {
      $event = if ($Record.PSObject.Properties.Name -contains 'event') { $Record.event } else { $null }
      $eventType = if ($null -ne $event -and $event.PSObject.Properties.Name -contains 'type') { [string]$event.type } else { '' }
      if (-not [string]::IsNullOrWhiteSpace($eventType)) {
        $traceLines.Add("[stream] $eventType")
      } else {
        $traceLines.Add('[stream]')
      }
      break
    }
    default {
      if (-not [string]::IsNullOrWhiteSpace($recordType)) {
        $traceLines.Add("[$recordType]")
      } else {
        $traceLines.Add('[unknown-record]')
      }
      break
    }
  }

  foreach ($line in $traceLines) {
    $State.traceLines.Add($line)
  }

  return @($traceLines)
}

function New-ClaudeDelegateCliArgs {
  param(
    [Parameter(Mandatory = $true)][string]$Model,
    [Parameter(Mandatory = $true)][string]$Effort,
    [Parameter(Mandatory = $true)][string]$SessionName,
    [Parameter(Mandatory = $true)][string]$SessionId,
    [Parameter(Mandatory = $true)][bool]$Resume,
    [AllowNull()][Nullable[decimal]]$MaxBudgetUsd,
    [Parameter(Mandatory = $true)][bool]$BypassPermissions,
    [Parameter(Mandatory = $true)][string]$PromptText
  )

  $claudeArgs = @(
    '--verbose',
    '--print',
    '--output-format', 'stream-json',
    '--model', $Model,
    '--effort', $Effort,
    '--name', $SessionName,
    '--permission-mode', 'acceptEdits'
  )

  if ($Resume) {
    $claudeArgs += @('--resume', $SessionId)
  } else {
    $claudeArgs += @('--session-id', $SessionId)
  }

  if ($null -ne $MaxBudgetUsd) {
    $claudeArgs += @('--max-budget-usd', ([decimal]$MaxBudgetUsd).ToString([Globalization.CultureInfo]::InvariantCulture))
  }

  if ($BypassPermissions) {
    $claudeArgs += '--dangerously-skip-permissions'
  }

  $claudeArgs += $PromptText
  return $claudeArgs
}

function Get-ClaudeDelegateNonJsonRawLines {
  param(
    [Parameter(Mandatory = $true)][string[]]$RawLines
  )

  $nonJsonRawLines = New-Object System.Collections.Generic.List[string]
  foreach ($rawLine in @($RawLines)) {
    if ([string]::IsNullOrWhiteSpace([string]$rawLine)) {
      continue
    }
    try {
      $null = ([string]$rawLine | ConvertFrom-Json -Depth 30)
    } catch {
      $nonJsonRawLines.Add(([string]$rawLine).Trim())
    }
  }

  return @($nonJsonRawLines.ToArray())
}

function Get-ClaudeDelegateRetryDecision {
  param(
    [Parameter(Mandatory = $true)][string[]]$RawLines,
    [Parameter(Mandatory = $true)][bool]$ResumeAttempt,
    [Parameter(Mandatory = $true)][int]$ExitCode,
    [Parameter(Mandatory = $true)][bool]$SawAssistantText,
    [Parameter(Mandatory = $true)][bool]$SawResultSuccess,
    [Parameter(Mandatory = $true)][bool]$CapturedFinalResultHeading
  )

  $joined = ((Get-ClaudeDelegateNonJsonRawLines -RawLines $RawLines) -join [Environment]::NewLine)
  $sawStaleSessionText = ($joined -match 'No conversation found.*session ID')
  $sawStreamJsonVerboseError = ($joined -match 'stream-json.*requires.*--verbose')
  $hasStructuredSuccess = ($SawResultSuccess -and $CapturedFinalResultHeading)

  $decision = [ordered]@{
    shouldRetry = $false
    retryReason = ''
    retryWithFreshSession = $false
    sawStaleSessionText = $sawStaleSessionText
    sawStreamJsonVerboseError = $sawStreamJsonVerboseError
    hasStructuredSuccess = $hasStructuredSuccess
    exitCode = $ExitCode
    sawAssistantText = $SawAssistantText
    sawResultSuccess = $SawResultSuccess
    capturedFinalResultHeading = $CapturedFinalResultHeading
  }

  if ($ResumeAttempt -and $sawStaleSessionText -and -not $hasStructuredSuccess) {
    $decision.shouldRetry = $true
    $decision.retryReason = 'stale_claude_session'
    $decision.retryWithFreshSession = $true
    return [pscustomobject]$decision
  }

  if ($sawStreamJsonVerboseError -and -not $hasStructuredSuccess) {
    $decision.shouldRetry = $true
    $decision.retryReason = 'stream_json_startup'
    $decision.retryWithFreshSession = $false
    return [pscustomobject]$decision
  }

  return [pscustomobject]$decision
}

function Get-ClaudeDelegateFailureSummary {
  param(
    [Parameter(Mandatory = $true)][string[]]$RawLines,
    [AllowNull()][string]$RetryReason,
    [Parameter(Mandatory = $true)][int]$AttemptCount,
    [Parameter(Mandatory = $true)][int]$MaxRetryCount,
    [Parameter(Mandatory = $true)][int]$ExitCode
  )

  $errorLines = @(Get-ClaudeDelegateNonJsonRawLines -RawLines $RawLines | Select-Object -Unique | Select-Object -First 2)
  $errorSnippet = if ($errorLines.Count -gt 0) {
    $errorLines -join ' | '
  } else {
    'No non-JSON stderr summary was captured.'
  }
  $reasonText = if ([string]::IsNullOrWhiteSpace($RetryReason)) { 'unknown_retry_condition' } else { $RetryReason }
  $maxAttempts = $MaxRetryCount + 1

  return "NEED_HUMAN_INTERVENTION after exhausting retry budget. retryReason=$reasonText. attempt $AttemptCount/$maxAttempts. exitCode=$ExitCode. $errorSnippet"
}

function Test-ClaudeDelegateNeedsFreshSessionRetry {
  param(
    [Parameter(Mandatory = $true)][string[]]$RawLines,
    [Parameter(Mandatory = $true)][bool]$ResumeAttempt
  )

  $decision = Get-ClaudeDelegateRetryDecision `
    -RawLines $RawLines `
    -ResumeAttempt $ResumeAttempt `
    -ExitCode 1 `
    -SawAssistantText $false `
    -SawResultSuccess $false `
    -CapturedFinalResultHeading $false
  return ([bool]$decision.shouldRetry -and [bool]$decision.retryWithFreshSession)
}
