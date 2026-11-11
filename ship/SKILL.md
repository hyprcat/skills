---
name: ship
description: Commit, push, PR, merge and deploy the way Affan does. Stage only the edits you made, one concern per commit, messages in the repo's own style with a behaviour-first subject, push, open or update a PR, fold in review comments, merge to main, and deploy with the repo's own script. Also checks out PRs into sibling worktrees and invites teammates to a repo. Use whenever he says commit, push, commit and push, ship it, make a PR, check PR N, checkout PR, review comments, merge, bring it to main, deploy, redeploy, "git pull and redeploy", or invite someone to the repo.
---

# Ship

## Commit

- **Only your edits.** Run `git status` first. Affan and other agents edit the same tree, so stage files by path
  (`git add <path>`, or `git add -p` in a file you share), never `git add -A` or `git add .`. In his words: "Be
  extremely surgical and only commit to the edits that you have made yourself."
- **One concern per commit.** A refactor and a behaviour change are two commits.
- **Match the repo's message style.** Read `git log --oneline -15` and write the same shape:
  - newest repos: `area: what changes, as a sentence`, e.g.
    `alma: click N clicks a listed or seen control with the pointer at its visible centre`
  - older and infra repos: Conventional Commits in plain words, e.g.
    `fix(acting): a run dropped with its hold gets a new epoch`
  - websites: an imperative sentence, e.g. `Drop the rotating globe from the HUD`
  - a new repo: `area: sentence`
- The subject says what changes for the user, often with the reason after a semicolon ("…; at 3 its rustc outgrows
  ACR's build machine"). Lowercase after the prefix, no trailing period. Add a body when the why doesn't fit.
- End with the attribution trailer the session gives (Co-Authored-By).
- Check `git diff --cached` before committing: no secrets, no `.env`, no build output, nobody's half-done files.
- Run the repo's gate first. Three repos require a passing check before every commit.

## Push and PR

- On `main` with work that should be reviewed, branch first: `feat/`, `fix/`, `claude/` for agent work, `deploy/…`,
  `cask/vX`.
- `git pull --rebase` before pushing. Never force-push a shared branch; `--force-with-lease` on your own branch only.
- `gh pr create` with a body of What / Why / How it was verified (memfold-computer's template), ending with the
  session's PR attribution line.

## Someone's PR

- If the main checkout has dirty work, don't stash his work. Put the PR in a sibling worktree instead:
  `git worktree add ../<repo>-pr<N> <branch>`. That's his norm (`creator-agent-pr100`, `ocu-pr-*`). In a clean tree,
  `gh pr checkout N` is fine.
- Read everything before changing anything:
  - `gh pr view N --comments`
  - `gh api repos/{owner}/{repo}/pulls/N/comments` for line comments
  - `gh pr checks N`
  - `gh pr diff N`
- Fold in each comment or say why not, and reply on the thread.
- Merge once checks pass and he has asked. Match how the repo merges: `git log --merges -5` shows merge commits;
  their absence means squash. Then delete the branch and remove the worktree.

## Deploy

- Use the repo's own path: its CLAUDE.md commands, `scripts/deploy*`, the CI workflow on `main`, or
  `vercel deploy --prod` for a Vercel project. Never invent a deploy.
- Afterwards, check that the live thing answers with the new code. Use the repo's `verify-live.sh` if it has one,
  or a request that shows the new behaviour. Then give the URL.

## Invite a teammate

`gh api -X PUT repos/{owner}/{repo}/collaborators/<login> -f permission=push` (admin only when asked). An org repo
may want the org's team instead; say which you did.
