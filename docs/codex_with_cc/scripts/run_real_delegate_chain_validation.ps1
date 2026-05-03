param(
  [string]$ValidationRoot,
  [string]$Name,
  [string]$SessionKey
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
if ([string]::IsNullOrWhiteSpace($ValidationRoot)) {
  $ValidationRoot = Join-Path $repoRoot '.codex\claude-delegate-validation'
}
if ([string]::IsNullOrWhiteSpace($Name)) {
  $Name = '{0}-real-chain' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
}
if ([string]::IsNullOrWhiteSpace($SessionKey)) {
  $SessionKey = 'delegate-real-chain-{0}' -f ([guid]::NewGuid().ToString('N').Substring(0, 12))
}

$resolvedValidationRoot = [System.IO.Path]::GetFullPath($ValidationRoot)
$chainRoot = Join-Path $resolvedValidationRoot $Name
$artifactRoot = Join-Path $chainRoot 'artifacts'
$taskRoot = Join-Path $chainRoot 'tasks'

New-Item -ItemType Directory -Path $artifactRoot -Force | Out-Null
New-Item -ItemType Directory -Path $taskRoot -Force | Out-Null

$taskSpecs = @(
  @{
    FileName = 'anchor-read-protocol.md'
    SessionMode = 'PrimaryAnchor'
    SessionFlags = '-SessionMode PrimaryAnchor -AllowParallel'
    Scope = "docs/codex_with_cc/scripts/delegate_to_claude.ps1`ndocs/codex_with_cc/scripts/claude_session_pool.ps1`ndocs/codex_with_cc/CODEX_WITH_CC.md"
    Tests = "pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <anchor-run-id> -ArtifactRoot '$artifactRoot'"
    Task = @"
只读验证任务：通过 Codex spawn_agent 子线程承载 Claude worker，审查 delegate_to_claude.ps1 与 claude_session_pool.ps1 的主线锚点行为。

要求：
- 只读，不修改任何仓库文件。
- 聚焦 PrimaryAnchor 如何建立主线 session、如何与后续 PrimaryReuse 续接。
- 输出必须包含 Process Log / Summary / Changed Files / Verification / Final Result / Risks Or Follow-ups。
"@
  },
  @{
    FileName = 'parallel-artifact-audit.md'
    SessionMode = 'ParallelPool'
    SessionFlags = '-SessionMode ParallelPool -AllowParallel'
    Scope = "docs/codex_with_cc/scripts/verify_delegate_artifacts.ps1`ndocs/codex_with_cc/scripts/verify_delegate_chain.ps1`n.codex/claude-delegate"
    Tests = "pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <parallel-a-run-id> -ArtifactRoot '$artifactRoot'"
    Task = @"
只读验证任务：审查新 schema delegate artifacts 与 verify_delegate_artifacts.ps1 的契约要求。

要求：
- 只读，不修改任何仓库文件。
- 聚焦 artifactSchema / invocationContract / attempts[] / initialSessionId / initialResume 等字段是否支撑新链路验收。
- 输出必须包含 Process Log / Summary / Changed Files / Verification / Final Result / Risks Or Follow-ups。
"@
  },
  @{
    FileName = 'parallel-stream-audit.md'
    SessionMode = 'ParallelPool'
    SessionFlags = '-SessionMode ParallelPool -AllowParallel'
    Scope = "docs/codex_with_cc/scripts/claude_delegate_backend_helpers.ps1`n.codex/claude-delegate"
    Tests = "pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <parallel-b-run-id> -ArtifactRoot '$artifactRoot'"
    Task = @"
只读验证任务：审查 claude_delegate_backend_helpers.ps1 的 stream capture、retry decision 与 trace/rawStream 行为。

要求：
- 只读，不修改任何仓库文件。
- 聚焦 stale-session、stream-json startup、structured Final Result 判定与日志可读性。
- 输出必须包含 Process Log / Summary / Changed Files / Verification / Final Result / Risks Or Follow-ups。
"@
  },
  @{
    FileName = 'reuse-cross-check-1.md'
    SessionMode = 'PrimaryReuse'
    SessionFlags = '-SessionMode PrimaryReuse'
    Scope = "docs/codex_with_cc/scripts/delegate_to_claude.ps1`ndocs/codex_with_cc/scripts/claude_delegate_backend_helpers.ps1`ndocs/codex_with_cc/scripts/claude_session_pool.ps1`ndocs/codex_with_cc/scripts/verify_delegate_artifacts.ps1`ndocs/codex_with_cc/scripts/verify_delegate_chain.ps1`ndocs/codex_with_cc/scripts/run_real_delegate_chain_validation.ps1`ndocs/codex_with_cc/scripts/test_delegate_runtime.ps1`ndocs/codex_with_cc/scripts/test_delegate_session_pool.ps1`ndocs/codex_with_cc/CODEX_WITH_CC.md"
    Tests = "pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <reuse-1-run-id> -ArtifactRoot '$artifactRoot'"
    Task = @"
真实复核/返工任务：在锚点与并发旁路完成后，使用同一 SessionKey 续接主线，对前三份结果做交叉复核。

要求：
- 先复核，不做无关修改。
- 必须确认 PrimaryReuse 优先尝试 resume=true；如果恢复为 fresh session，必须解释审计链。
- 如果发现真实缺陷，允许在允许范围内修改仓库文件，并补齐最小必要测试。
- 如果修改任何仓库文件，必须遵守 docs/codex_with_cc/CODEX_WITH_CC.md 中的工作流约束，并在 Verification 中列出实际运行的验证命令。
- 输出必须包含 Process Log / Summary / Changed Files / Verification / Final Result / Risks Or Follow-ups。
"@
  },
  @{
    FileName = 'reuse-cross-check-2.md'
    SessionMode = 'PrimaryReuse'
    SessionFlags = '-SessionMode PrimaryReuse'
    Scope = "docs/codex_with_cc/scripts/delegate_to_claude.ps1`ndocs/codex_with_cc/scripts/claude_delegate_backend_helpers.ps1`ndocs/codex_with_cc/scripts/claude_session_pool.ps1`ndocs/codex_with_cc/scripts/verify_delegate_artifacts.ps1`ndocs/codex_with_cc/scripts/verify_delegate_chain.ps1`ndocs/codex_with_cc/scripts/run_real_delegate_chain_validation.ps1`ndocs/codex_with_cc/scripts/test_delegate_runtime.ps1`ndocs/codex_with_cc/scripts/test_delegate_session_pool.ps1`ndocs/codex_with_cc/CODEX_WITH_CC.md"
    Tests = "pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <reuse-2-run-id> -ArtifactRoot '$artifactRoot'"
    Task = @"
只读验证任务：再次在同一 SessionKey 下顺序续接主线，验证高缓存命中不是偶发成功。

要求：
- 只读，不修改任何仓库文件。
- 必须复核主线 session 是否连续、并发池租约是否释放、lastTaskFingerprint 是否保留。
- 如果发现仍有问题，明确指出需要进入新的串行返工轮次，不要做范围外修改。
- 输出必须包含 Process Log / Summary / Changed Files / Verification / Final Result / Risks Or Follow-ups。
"@
  }
)

foreach ($taskSpec in $taskSpecs) {
  $taskPath = Join-Path $taskRoot $taskSpec.FileName
$taskContent = @"
# Real Delegate Chain Validation Task

- SessionKey: $SessionKey
- ArtifactRoot: $artifactRoot
- SessionMode: $($taskSpec.SessionMode)
- Child-thread only: This task must run inside a Codex spawn_agent child thread with model 'gpt-5.3-codex', reasoning_effort 'high', fork_context 'false'.
- Required child-thread marker: set process environment CODEX_CLAUDE_CHILD_THREAD=1 before invoking the worker entry script.
- Worker entry script: docs/codex_with_cc/scripts/delegate_to_claude.ps1
- Required worker arguments: -TaskFile "$taskPath" -ArtifactRoot "$artifactRoot" -SessionKey "$SessionKey" $($taskSpec.SessionFlags) -BypassPermissions

Allowed scope:
$($taskSpec.Scope)

Verification command to run after this task completes:
$($taskSpec.Tests)

$($taskSpec.Task)
"@
  Set-Content -LiteralPath $taskPath -Value $taskContent -Encoding UTF8
}

$instructions = @"
Real delegate chain validation scaffold created.

Validation Root: $chainRoot
Artifact Root: $artifactRoot
Task Root: $taskRoot
Session Key: $SessionKey

Required Codex orchestration rules:
- The Codex main thread may only create spawn_agent child threads and collect results.
- Every Claude worker must run inside a child thread with:
  - model: gpt-5.3-codex
  - reasoning_effort: high
  - fork_context: false
- Every child thread must set CODEX_CLAUDE_CHILD_THREAD=1 and then call docs/codex_with_cc/scripts/delegate_to_claude.ps1 with -TaskFile.
- Do not run Claude CLI or delegate_to_claude.ps1 directly from the main thread.

Recommended execution order:
1. Child thread: anchor-read-protocol.md (PrimaryAnchor)
2. Child thread: parallel-artifact-audit.md (ParallelPool)
3. Child thread: parallel-stream-audit.md (ParallelPool)
4. Wait for the anchor + both parallel runs to finish
5. Child thread: reuse-cross-check-1.md (PrimaryReuse)
6. Child thread: reuse-cross-check-2.md (PrimaryReuse)

Post-run verification commands:
- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <anchor-run-id> -ArtifactRoot "$artifactRoot"
- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <parallel-a-run-id> -ArtifactRoot "$artifactRoot"
- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <parallel-b-run-id> -ArtifactRoot "$artifactRoot"
- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <reuse-1-run-id> -ArtifactRoot "$artifactRoot"
- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_artifacts.ps1 -RunId <reuse-2-run-id> -ArtifactRoot "$artifactRoot"
- pwsh -NoProfile -File .\docs\codex_with_cc\scripts\verify_delegate_chain.ps1 -ArtifactRoot "$artifactRoot" -SessionKey "$SessionKey" -AnchorRunId <anchor-run-id> -ParallelRunIds <parallel-a-run-id>,<parallel-b-run-id> -ReuseRunIds <reuse-1-run-id>,<reuse-2-run-id>
"@

Write-Host $instructions
