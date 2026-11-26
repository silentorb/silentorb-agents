---
name: workbench-env
description: >-
  Create and maintain Silent Orb multi-repo workbench infrastructure: sibling
  repo layout, Docker Compose services with /workspaces/<repo> mounts, an
  optional thin Dev Container, scripts/run + scripts/compose + scripts/push,
  Claude/Cursor config, and agent-doc routing to the owning repo. Use when
  scaffolding or evolving a workbench, its Compose services, scripts, or
  workbench AGENTS.md repo/doc tables.
---

# Workbench environment patterns

Procedural guidance to **create and maintain** workbench orchestration. The
standing defaults (host-first, sibling layout, compose canonical, docs routed to
the owning repo) live in this package's [`AGENTS.md`](../AGENTS.md). Don't
invent product-domain rules here.

Each workbench keeps its own repo list, services, and scripts. This skill does
**not** ship shared runnable scripts; each workbench carries a small copy.

## 1. Repo layout

| Piece | Pattern |
| --- | --- |
| Host | Workbench and product repos are siblings (`~/dev/<repo>`), with no nested `.mnt/` |
| Containers | Every repo mounted at `/workspaces/<repo>`, workbench included (`workspaceFolder: /workspaces/<workbench>`) |
| Product repos | Path deps and workspaces point at siblings (`../imp-rs`), never at workbench-specific paths |
| Overrides | `.devcontainer/.env` (gitignored) + committed `.env.example`; `*_PATH` / `*_REPO` vars with `../../<repo>` defaults |

## 2. Docker Compose (canonical) + optional Dev Container

| Piece | Pattern |
| --- | --- |
| Compose | `.devcontainer/docker-compose.yml`, top-level `name: <workbench>_devcontainer` |
| Volumes | YAML anchor list `${FOO_PATH:-../../foo}:/workspaces/foo`. Each service gets only what it needs |
| Services | One per toolchain role (e.g. Rust, Bun/WebKit, Windows cross). Set `user: vscode` and `working_dir`. Default command `sleep infinity` |
| Profiles | On-demand tool or cross-compile services get a named profile. The IDE/agent attach service gets `profiles: ["ide"]` |
| Everything runtime | Devices, env, ports, init/chown steps live in compose (an entrypoint script if needed), **not** in `devcontainer.json` |
| Dev Container | `dockerComposeFile`, `service`, `runServices`, `workspaceFolder`, `remoteUser`, editor customizations. Features only for in-container agents (e.g. docker-outside-of-docker) |

## 3. Scripts

| Script | Pattern |
| --- | --- |
| `scripts/lib/paths.sh` | `WORKBENCH_ROOT`, `DEV_ROOT` (`/workspaces` in a container, otherwise the workbench parent), `CONTAINER_ROOT=/workspaces`, compose project/file, one var per repo |
| `scripts/compose` | `docker compose -p <project> -f <file> "$@"`, plus `rebuild <svc>` (build + force-recreate) |
| `scripts/run [-C dir] <svc> <cmd…>` | Host: `up -d --no-recreate <svc>`, then `exec -T -w <dir mapped to /workspaces/…>`. In a container: run in place |
| Tool scripts | On the host, re-exec into the owning service (e.g. an `in_tools "$0" "$@"` preamble); in a container, run in place |
| `scripts/push` | Resolve `$DEV_ROOT/<name>`. Skip missing, non-git, detached HEAD, no-`origin`, read-only. Push in dependency order, then the workbench |

Never recreate services implicitly; an IDE may be attached. Host-path
translation (e.g. `LOCAL_WORKSPACE_FOLDER`) is only needed for
docker-outside-of-docker calls made from inside the Dev Container.

## 4. Agent config and docs

1. `CLAUDE.md` = `@AGENTS.md`. Keep the workbench `AGENTS.md` lean: purpose,
   repo table (`../<repo>`, role, required/optional), "Running things"
   (service ↔ toolchain, `scripts/run` examples), verify matrix, conventions.
   Move big routing tables into an on-demand `docs/` file.
2. `.claude/settings.json`: `permissions.additionalDirectories` for siblings
   (they're within the user-level working-directory allowance) and an
   allowlist for `scripts/run` / `scripts/compose` read-only verbs.
3. Skills: committed relative symlinks
   `.claude/skills/<skill>` → `../../../silentorb-agents/packages/<pkg>/<skill>`
   (and the same under `.agents/skills/` for Cursor).
4. `.gitignore`: `.claude/worktrees/`, `.claude/settings.local.json`, `.env`.
5. `<workbench>.code-workspace` with `../<repo>` folders for IDE use on the host.
6. Product / domain guidance goes in the repo that owns it.

## Checklist (add or change a sibling repo)

- [ ] Compose volume anchor(s) and the services that need it
- [ ] `.env.example` override var
- [ ] `scripts/lib/paths.sh` var
- [ ] `scripts/push` list (if writable / published)
- [ ] `.claude/settings.json` `additionalDirectories`
- [ ] `<workbench>.code-workspace` folder
- [ ] Workbench `AGENTS.md` repo table and verify matrix
