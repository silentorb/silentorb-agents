---
name: workbench-env
description: >-
  Create and maintain Silent Orb multi-repo workbench infrastructure: Docker
  Compose Dev Container, host sibling mounts under .mnt/, mnt-paths helpers,
  scripts/push, and agent-doc routing to the owning mount. Use when scaffolding
  or evolving a workbench, push script, compose mounts, or workbench AGENTS.md
  mount/doc tables.
---

# Workbench environment patterns

Procedural guidance to **create and maintain** workbench orchestration. Standing
defaults (Compose as default shape; route product docs to mounts) live in this
package’s [`AGENTS.md`](../AGENTS.md). Do not invent product-domain rules here —
capture the shared layout already used by Silent Orb / Aura / Imp workbenches.

Each workbench keeps its own mount list, services, and skip flags. This skill
does **not** ship shared runnable scripts.

## 1. Docker Compose + Dev Container

When creating or evolving a workbench, prefer:

| Piece | Pattern |
| --- | --- |
| Compose | `.devcontainer/docker-compose.yml` |
| Dev Container | `.devcontainer/devcontainer.json` with `dockerComposeFile` + attach `service` (+ `runServices` when multiple services start with the IDE) |
| Project name | Top-level Compose `name:` matching Dev Containers so host `docker compose` and the IDE share volumes/networks |
| Workspace | Single workbench folder; siblings appear under `.mnt/` |
| Volumes | YAML anchors for repeated bind lists; host path via `${FOO_REPO:-../../foo}:…/.mnt/foo` |
| Optional tooling | `docker-outside-of-docker` feature when the attach service must talk to the host daemon |

Multi-service is fine when roles differ (e.g. attach shell vs language-specific image). On-demand services stay out of `runServices`.

Keep Compose mount entries, `scripts/mnt-paths.sh`, and `scripts/push` repo lists in sync whenever mounts change.

## 2. Host directory mounting (`.mnt/`)

| Piece | Pattern |
| --- | --- |
| Bind mounts | Compose maps host siblings into `<workbench>/.mnt/<repo>` |
| Tracked stub | `.mnt/README.md` documents mounts; mount contents are gitignored |
| Path helper | `scripts/mnt-paths.sh` — `WORKBENCH_ROOT`, `MNT`, and one var per mount; sourced by other scripts |
| Overrides | Env vars (e.g. `TOME_REPO`, `AURA_ENGINE_PATH`) when opening the Dev Container |
| Optional mounts | Document required vs optional in the consumer `AGENTS.md` / README; scripts skip missing repos |

Resolve a repo for scripts as: prefer `.mnt/<name>`, then `../<name>` beside the workbench (and any documented env override).

**Variants:** some mounts may be `:ro` (skip in push); nested remounts for path deps (e.g. Cargo) stay workbench-specific.

## 3. Push script (`scripts/push`)

Maintain a workbench-root `scripts/push` that:

1. Sources `mnt-paths.sh` (or equivalent).
2. Resolves each named repo (`.mnt/` then sibling).
3. Skips missing, non-git, detached HEAD, and non-writable / no-`origin` paths.
4. Pushes the current branch (`-u origin <branch>` when no upstream).
5. Lists every **writable** mounted sibling the team expects to publish — aligned with Compose + `mnt-paths.sh`.

Workbench-specific policy stays in the consumer script (examples: optional `web` flag for auto-deploy site repos; `--follow-tags` for release tags; dependency order; skip read-only mounts).

Push the workbench repo itself from `WORKBENCH_ROOT` as well when it has a remote.

## 4. Agent-doc routing

When editing or adding agent documentation:

1. Put **product / domain** guidance in the mounted repo that owns it (`AGENTS.md`, `docs/`).
2. Keep the workbench-root `AGENTS.md` for orchestration: mount table, Compose/services, script pointers, verify matrix, and links into mounts.
3. Prefer the **nearest** mounted `AGENTS.md` when working inside a mount.
4. When adding a mount, update: Compose volumes, `mnt-paths.sh`, push list, `.mnt/README.md`, and the workbench mount / doc-routing table in the same change.

## Checklist (create or change mounts)

- [ ] Compose volume (and anchors / service lists)
- [ ] `scripts/mnt-paths.sh`
- [ ] `scripts/push` include/skip list
- [ ] `.mnt/README.md` (+ gitignore if new tree)
- [ ] Workbench `AGENTS.md` mount table and doc pointers
- [ ] `devcontainer.json` `runServices` / ports if services or ports change
