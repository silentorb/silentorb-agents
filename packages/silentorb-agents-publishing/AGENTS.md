# silentorb-agents-publishing

How agent changes are saved and published. **Installing this package enables its skills.**

## Skills

| Trigger | Skill |
| --- | --- |
| Creating or updating a plan | [plan-commit](./plan-commit/SKILL.md) — include Commit strategy; add verify + commit-await todos |
| Plan implementation complete | [plan-commit](./plan-commit/SKILL.md) — full-suite verify, then await commit |
| User says **commit** / **commit per the plan** | [plan-commit](./plan-commit/SKILL.md) — commit execution only |

## Project concretes

Verify matrix and CI details live in the **consuming project** `AGENTS.md` (typically § Plan verification). Do not duplicate them here.
