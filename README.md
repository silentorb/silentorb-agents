# silentorb-agents

Installable agent skill packages for Silent Orb projects.

Packages use `package.json` (name + semver) as lightweight metadata and publish
as **OCI artifacts** to GHCR. Installing a package into a project enables its
skills — follow that package’s `AGENTS.md`.

## Packages

| Package | Concern |
| --- | --- |
| [`silentorb-agents-publishing`](./packages/silentorb-agents-publishing/) | How agent changes are saved and published |
| [`silentorb-agents-planning`](./packages/silentorb-agents-planning/) | How agents author plans for human review (dual audience, objective analysis) |
| [`silentorb-agents-workbench`](./packages/silentorb-agents-workbench/) | Multi-repo workbench patterns (Compose mounts, push scripts, agent-doc routing) |

## Install (consumer)

Pull a versioned package into a project-local path of your choosing:

```bash
mkdir -p vendor
cd vendor
oras pull ghcr.io/silentorb/silentorb-agents-publishing:0.1.0
oras pull ghcr.io/silentorb/silentorb-agents-planning:0.1.0
oras pull ghcr.io/silentorb/silentorb-agents-workbench:0.1.0
```

Expose each package’s skill directories on the consumer’s agent skill path (for
Cursor: symlink into `.agents/skills`). Follow each package’s `AGENTS.md`.

**Silent Orb workbench:** consumes via the `.mnt/silentorb-agents` bind mount —
symlink `.agents/skills/<skill>` straight at
`packages/<package>/<skill>` (no vendor/oras install required for local
library development).

## Publish (maintainers)

On a `v*` git tag, CI pushes each `packages/*` artifact to
`ghcr.io/silentorb/<package-name>:<version>` using ORAS.

Local dry-run (no registry push; needs `jq`):

```bash
DRY_RUN=1 bash pack/pack.sh
```

Pre-CI packer **container** smoke (builds `pack/Dockerfile`, runs one ephemeral
container, removes it). Default `DRY_RUN=1`. Needs Docker and a **host-visible**
repo path for the bind mount (GitHub Actions and a normal host checkout are fine).
From a docker-outside-of-docker workbench shell, set `HOST_REPO_PATH` (or
`SILENTORB_AGENTS_REPO`) to the host path of this repo, or use bare `pack.sh`
above instead:

```bash
bash pack/docker-pack.sh
```

Local push (needs `oras`, `jq`, and GHCR auth):

```bash
echo "$GITHUB_TOKEN" | oras login ghcr.io -u USERNAME --password-stdin
DRY_RUN=0 bash pack/pack.sh
```

## License

MIT — see [LICENSE](./LICENSE).
