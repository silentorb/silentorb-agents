# silentorb-agents-workbench

Multi-repo workbench orchestration patterns. **Installing this package enables
its skills** and the standing defaults below.

## Standing defaults (whenever installed)

These apply without the user asking, unless the project already uses a different
deliberate layout or the user opts out.

### Host-first, sibling layout

- Agents (Claude Code, Cursor) run on the **host (WSL)** from the workbench
  directory. Related repos are **sibling checkouts** (`../<repo>`) and are never
  mounted into the workbench tree.
- Toolchains run in **Docker Compose** services (`.devcontainer/docker-compose.yml`).
  Inside containers every repo, the workbench included, is mounted at
  `/workspaces/<repo>`, so sibling-relative paths resolve the same everywhere.
- Compose is the **single source of truth**. The Dev Container
  (`devcontainer.json`) is an optional thin attach layer with no mounts, env,
  devices, or start hooks of its own. Agent-only attach services use
  `profiles: ["ide"]`.
- The Compose project `name` matches what Dev Containers would use
  (`<workbench>_devcontainer`), so host scripts and the IDE share one stack.

### Agent-doc routing

- Product / domain agent docs live in the **sibling repo that owns them**
  (prefer that repo's `AGENTS.md` / `docs/`).
- Workbench-root docs cover **orchestration only** (repo table, services,
  scripts, verify matrix pointers). Large on-demand indexes go in `docs/`,
  not the always-loaded `AGENTS.md`.
- `CLAUDE.md` contains only `@AGENTS.md`.

Concrete repo tables and verify commands stay in the **consuming** workbench
`AGENTS.md`.

## Skills

| Trigger | Skill |
| --- | --- |
| Creating or maintaining a multi-repo workbench env (Compose services, `scripts/run` / `scripts/compose` / `scripts/push`, sibling repo list, agent-doc routing) | [workbench-env](./workbench-env/SKILL.md) |
