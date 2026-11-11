# Installing silentorb-agents packages into containers

This document describes a **suggested** package-agnostic recipe for installing
any silentorb-agents package into a **Dev Container–based** consumer and wiring
it so coding agents can discover skills and package guides. It is written so
humans or agents can follow it from a remote Git URL.

It is **not** a definitive or exclusive install contract. Other layouts may
work; this is one shared pattern for a common use case. Apply the same steps
for each package you add.

## Artifact type

Packages on GHCR are **ORAS OCI artifacts**, not container images.

- Install with: `oras pull ghcr.io/silentorb/<package>:<version>`
- Do **not** use `docker pull` — it fails (wrong artifact shape).

Each pull unpacks the package tree (including `AGENTS.md`, `package.json`, and
skill directories with `SKILL.md`).

## Dev Container bind-mount constraint

In a Dev Container, the workspace directory is bind-mounted over the image
filesystem. Anything written under the workspace path during **Dockerfile
build** is hidden at runtime.

Therefore, for this recipe:

- Do **not** `oras pull` into the workspace during image build.
- Install packages under a path **outside** the mount. A suggested path is:

  `/opt/silentorb-agents/<package>/`

## Image bake (Dockerfile)

For each package to install:

1. Ensure `oras` is on the image (for example, copying it from
   `ghcr.io/oras-project/oras` and leaving it installed for later bumps).
2. Pin the version with a build `ARG`.
3. `mkdir` the install dir, `cd` into it, then
   `oras pull ghcr.io/silentorb/<package>:${VERSION}`.
4. Set ownership so the container user can read the tree.

Repeat the pull for every package. Rebuild the consumer image to change
versions.

## Agent skill discovery (required workaround)

Coding agents auto-discover skills only from fixed skill roots (project:
`.agents/skills/`; also user-level equivalents). A package tree under `/opt` is
**not** discovered by itself.

For **each skill directory** inside an installed package (a folder containing
`SKILL.md`):

- Create a committed absolute symlink:

  `.agents/skills/<skill>` → `/opt/silentorb-agents/<package>/<skill>`

Without these symlinks, agents will not see the skills in their skill
registries (for example `/`, Agent Decides, description-based use), even if
the package is present on disk.

This is a host/tooling limitation of the SKILL.md discovery model, not
something the package can fix from inside `/opt`.

## Package AGENTS.md enablement

Coding agents auto-load the consumer’s **root** `AGENTS.md`. They do **not**
auto-load `/opt/silentorb-agents/<package>/AGENTS.md`.

The consumer root `AGENTS.md` must **directly reference each installed
package’s `AGENTS.md` file path** (the full path to the file, not only the
package directory). Soft “see the package folder” pointers are insufficient.

Example table shape (fill in real package names/paths per consumer):

| Package | AGENTS.md |
| --- | --- |
| `<package>` | `/opt/silentorb-agents/<package>/AGENTS.md` |

Agents should follow those package guides for skill triggers and
package-specific rules.

## Consumer concretes

When a package’s `AGENTS.md` requires project-specific details (for example a
verify / Plan verification matrix), put those in the **consumer** `AGENTS.md`.
Do not copy package skill bodies into the consumer guide.

## Uninstallation

SKILL.md discovery has no contained install/uninstall lifecycle for modular
packages, so removal is the reverse of the manual wiring above. Doing that
deliberately keeps this recipe slightly more contained: what you add, you can
take out without hunting for leftovers.

For **each package** to remove:

1. Delete every committed skill symlink under `.agents/skills/` that points at
   that package’s tree (e.g. `.agents/skills/<skill>` →
   `/opt/silentorb-agents/<package>/<skill>`). Leave unrelated skills alone.
2. Remove that package’s row (or other direct file-path reference) from the
   consumer root `AGENTS.md`.
3. Drop any **consumer-owned** concretes that existed only for that package
   (for example verify-matrix rows or standing defaults you added solely
   because it was installed). Keep shared project guidance.
4. Stop baking the package into the image: remove its `ARG`, `oras pull`, and
   related Dockerfile lines, then rebuild so `/opt/silentorb-agents/<package>/`
   is no longer present.

After uninstall, agents should no longer list those skills or follow that
package’s `AGENTS.md`. A leftover symlink or root `AGENTS.md` link is enough
to keep the package partially “installed” from the agent’s point of view.
