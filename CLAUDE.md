# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ActionbarPlus-Masque is a small companion WoW addon that adds optional [Masque](https://www.curseforge.com/wow/addons/masque) skin support to [ActionbarPlus](https://www.curseforge.com/wow/addons/actionbarplus) buttons. It is a separate CurseForge/GitHub project from ActionbarPlus itself, released independently.

It only loads when both `ActionbarPlus-Core` and `Masque` are present (`RequiredDeps` in the TOC), so the code has no defensive nil-checks for either dependency — if this file is running, both exist.

## Repo layout

```
ActionbarPlus-Masque/
  ActionbarPlus-Masque.lua           # entire addon implementation (~100 lines)
  ActionbarPlus-Masque.toc           # single multi-interface TOC, Classic Era through Retail
dev/
  deployer-config.lua   # w-deployer targets (classic-era, classic, classic-anniversary, retail)
  annotations/ActionbarPlus-Masque-Annotations.lua  # EmmyLua @meta types for ns (ABP_MASQUE_NS)
  release.sh, release-clean.sh, release-with-upload.sh, sha256.sh, setup.yml
pkgmeta.yaml            # BigWigsMods packager config (CurseForge/GitHub release packaging)
.github/workflows/      # release-build.yml (tag push -> CurseForge/GitHub release; manual run for branch builds)
```

The whole addon is one namespace object `ns` (typed as `Namespace_ABP_Masque_2_0`, global `ABP_MASQUE_NS`) exposing:

- `ns:IsEnabled()` — whether the Masque group exists
- `ns:AddButton(btn)` / `ns:RemoveButton(btn)` — register/unregister a button with the Masque skin group
- `ns:ReSkin(btn?)` — re-apply skin to one button or all
- `ns:OpenMasqueSettings()` — opens Masque's options dialog to the ActionbarPlus skin group

`btn` is `Button_ABP_2_0_X`, a type defined externally in ActionbarPlus-Core — this repo only consumes it.

### Sibling dependency repos

This addon depends on two separate repos, both checked out locally as siblings of this one:

- **ActionbarPlus** — `/Users/tony/sandbox/github/kapresoft/wow/ActionbarPlus`
  Owns `ActionbarPlus-Core` (the namespace/types this addon consumes, e.g. `Button_ABP_2_0_X`) and `ActionbarPlus-BarsUI`. `.emmyrc.json` in this repo points its `workspace.library` at `../ActionbarPlus/ActionbarPlus-BarsUI` for IDE type resolution.
- **Masque** — `/Users/tony/sandbox/github/kapresoft/wow/Masque`
  Owns the `Masque` API (`LibStub('Masque')`, `Masque:Group()`, `group:AddButton/RemoveButton/ReSkin`) that `ActionbarPlus-Masque.lua` calls directly. Not currently listed in `.emmyrc.json`'s `workspace.library` — check this repo's source directly (`Masque.lua`, `Core/`) for the authoritative API when in doubt, since there's no local annotation/type coverage for it yet.

When changing this addon's public API or button-field usage, check the relevant sibling repo for authoritative definitions rather than guessing.

## Build & Deploy

### Deploy to local WoW installs (dev loop)

```shell
w-deployer -c ./dev/deployer-config.lua        # one-time
w-deployer -c ./dev/deployer-config.lua -qw     # quiet + watch mode
```

### Package a release build locally

```shell
./dev/release-clean.sh          # clean .release/ then run the BigWigsMods packager
./dev/release.sh -dz            # package without upload/zip (what release-clean.sh calls)
```

### Release process

1. Merge changes to `main` via PR.
2. Push a semver tag (`N.N.N`) — `release-build.yml` runs the BigWigsMods packager, creates a CurseForge build, and drafts a GitHub release.
3. Verify the CurseForge build is green, then publish the GitHub draft release.

There are no automated tests. Validation is done in-game.

## Key conventions

- **No unit test framework** — test in-game against a real ActionbarPlus + Masque install via the deployer.
- **EmmyLua annotations** — public API on `ns` is typed via `dev/annotations/ActionbarPlus-Masque-Annotations.lua` (a `@meta` file, not loaded at runtime). Update it whenever `ns`'s public functions change.
- **No defensive Masque/Core nil-checks** — `RequiredDeps` in the TOC guarantees load order and presence; don't add nil-guards for them.
- **One TOC file** — `ActionbarPlus-Masque.toc` covers every client (Classic Era through Retail) via its comma-separated `## Interface` list. There is no separate per-client TOC.
- **`pkgmeta.yaml` `move-folders`** — must exactly match `<repo-folder>/<addon-folder>: <addon-name>` or CurseForge packaging silently fails (see comment in the file). Don't change this mapping casually.
