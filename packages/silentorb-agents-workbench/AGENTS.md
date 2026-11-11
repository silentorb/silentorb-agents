# silentorb-agents-workbench

Multi-repo workbench orchestration patterns. **Installing this package enables
its skills** and the standing defaults below.

## Standing defaults (whenever installed)

These apply without the user asking, unless the project already uses a different
deliberate layout or the user opts out.

### Dev Container + Docker Compose

Assume a multi-repo workbench uses a **Dev Container with Docker Compose**:

- Compose file under `.devcontainer/` (typically `docker-compose.yml`)
- `devcontainer.json` sets `dockerComposeFile` and an attach `service`
- Host sibling repos bind-mount under **`.mnt/`** (not cloned at container start)
- Compose project `name` matches what Dev Containers would use so host CLI and
  the IDE share one stack

Prefer that shape when **creating or evolving** a workbench. It is the default
assumption, not a hard requirement for every consumer repo.

### Agent-doc routing

- Product / domain agent docs live in the **mounted repo that owns them**
  (prefer that repo’s `AGENTS.md` / `docs/`).
- Workbench-root docs cover **orchestration only** (mounts, Compose, scripts,
  verify matrix pointers).
- Do not write product guidance only at the workbench root when a mount owns
  the domain.

Concrete mount tables and verify commands stay in the **consuming** workbench
`AGENTS.md`.

## Skills

| Trigger | Skill |
| --- | --- |
| Creating or maintaining a multi-repo workbench env (push script, `.mnt/` mounts, Compose, agent-doc routing) | [workbench-env](./workbench-env/SKILL.md) |
