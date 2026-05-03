# Codex With Claude Code

This document is the portable entry point for the Codex -> Codex child agent -> Claude Code CLI workflow.

## Required Reading
1. Read this file before using the workflow in this repository.

## Core Contract
1. The Codex main thread must not run `claude` directly.
2. The Codex main thread must not run `docs/codex_with_cc/scripts/delegate_to_claude.ps1` directly.
3. Every Claude Code delegation must be carried by a Codex `spawn_agent` child thread.
4. The child thread must set `CODEX_CLAUDE_CHILD_THREAD=1` before invoking `delegate_to_claude.ps1`.
5. The child thread should use `model: gpt-5.3-codex`, `reasoning_effort: high`, and `fork_context: false`.
6. Medium and large tasks should be written to a task file and passed with `-TaskFile`.
7. Claude workers must keep changes inside the delegated scope, run the required verification, and finish with the exact report headings defined in this document.

## Roles
- Codex main thread: understand the request, define scope, create child threads, review results, and decide final acceptance.
- Codex child thread: provide a visible conversation-tree node and invoke the worker script.
- Claude Code CLI: execute the delegated task, run verification, and produce a structured report.

## Session Modes
- `PrimaryReuse`: default serial mode. Reuses the main Claude session for continuity.
- `PrimaryAnchor`: parallel-batch anchor. Its result becomes the main reusable context for later serial work.
- `ParallelPool`: independent parallel side work. Uses reusable pool sessions without writing to the main session.

Only use `-AllowParallel` when task scopes are independent.

## Worker Output
Claude Code must finish with these exact headings:

```text
Process Log
Summary
Changed Files
Verification
Final Result
Risks Or Follow-ups
```

Verification must list the commands actually run and their outcomes. If verification is blocked, the report must explain the blocker and whether it is unrelated to the delegated change.

## Artifacts
Delegation artifacts are written under `.codex/claude-delegate` by default:
- `claude_<RunId>.md`
- `status_<RunId>.json`
- `config_<RunId>.json`
- `prompt_<RunId>.md`
- `stream_<RunId>.jsonl`
- `trace_<RunId>.log`
- `session-pools/<SessionKey>.json`

Use `verify_delegate_artifacts.ps1` for each run and `verify_delegate_chain.ps1` for multi-run continuity checks.

## Standard Worker Command
Run this only inside a Codex child thread:

```powershell
$env:CODEX_CLAUDE_CHILD_THREAD = '1'
pwsh -NoProfile -File .\docs\codex_with_cc\scripts\delegate_to_claude.ps1 `
  -TaskFile .\.codex\codex_with_cc\tasks\<task-file>.md `
  -SessionMode PrimaryReuse `
  -SessionKey <stable-session-key> `
  -BypassPermissions
```

Use `PrimaryAnchor -AllowParallel` for the main branch of a parallel batch and `ParallelPool -AllowParallel` for independent side work.

## Verification
Run the local regression tests after installing or changing this workflow:

```powershell
pwsh -NoProfile -File .\docs\codex_with_cc\scripts\test_delegate_runtime.ps1
pwsh -NoProfile -File .\docs\codex_with_cc\scripts\test_delegate_session_pool.ps1
```

Generate a real chain validation scaffold with:

```powershell
pwsh -NoProfile -File .\docs\codex_with_cc\scripts\run_real_delegate_chain_validation.ps1
```
