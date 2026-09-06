{ ... }:
let
  instructions = ''
    # Global agent instructions

    - Never use the em dash character. Use a plain hyphen instead.
    - When writing commit messages, never auto-add your agent name as co-author.
    - Never manually modify `CHANGELOG.md` files or any files marked as auto-generated.
    - When making technical decisions, do not give much weight to development cost. Prefer quality, simplicity, robustness, scalability, and long-term maintainability.
    - For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
    - When fixing bugs, always start by reproducing the bug in an end-to-end setting as closely aligned with the end-user experience as possible. This helps identify the real problem so the fix actually solves it.
    - When end-to-end testing a product, be picky about the UI and pursue pixel perfection. If something clearly looks off, even when unrelated to the current task, try to fix it along the way.
    - Apply the same standard to engineering excellence. If you encounter lint failures, test failures, or flaky tests, fix them even when they were not caused by the current work.
    - Before using dynamic workflows, ultra code, or any harness feature that immediately spawns a large swarm of subagents, explain the tradeoffs and ask the user for explicit approval.

    ## Maintaining this file

    - Keep this file limited to knowledge useful to almost every future agent session.
    - Do not repeat what a codebase already shows. Point to the authoritative file or command instead.
    - Prefer rewriting or pruning existing entries over appending new ones.
    - Preserve this quality bar for all agents and keep entries concise.
    - This file is managed by Home Manager. Update its declarative source in the NixOS configuration instead of editing generated copies.
  '';
in {
  home.file = {
    ".ante/AGENTS.md" = {
      force = true;
      text = instructions;
    };
    ".codex/AGENTS.md" = {
      force = true;
      text = instructions;
    };
    ".claude/CLAUDE.md" = {
      force = true;
      text = instructions;
    };
  };
}
