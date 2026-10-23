# MurlokExport

Read [CONTRIBUTING.md](CONTRIBUTING.md) first: it explains the layout, the data format, and the other addons that depend on it.

- **Ask before committing, pushing a branch, opening a PR, or changing repo settings.** Show the diff and ask before every commit. Approving a plan is not approval to push.
- **Only `MurlokExport/` ships.** Never put `*.py`, `AGENTS.md` or `CLAUDE.md` files inside it: the build refuses a release that contains them.
- **`MurlokExport/Data/` is generated** by the separate data build. Never commit it here.
- **Don't edit `MurlokExport/Libs/`.**
- `README.md` is the CurseForge description and `Changelog.md` is sent to CurseForge as release notes: both are user-facing copy.
