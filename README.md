# Sluurp

A whole backend in one binary: a database, sign-in, files, email, jobs, a REST and realtime API, server components, sync, AI, and an admin to run it all.

> **Alpha.** Sluurp is young: things change between versions, and some will break. Try it, build with it, and tell us what you find.

This repository holds Sluurp's releases, its issues and the showcase of apps built with it. Sluurp is distributed as binaries; its source is not published.

## Install

macOS and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/SluurpHQ/releases/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/SluurpHQ/releases/main/install.ps1 | iex
```

Or download a binary from [Releases](https://github.com/SluurpHQ/releases/releases). Set `SLUURP_VERSION` to a release's tag to pick a version.

Then:

```sh
sluurp serve --public app
```

The docs are at [sluurp.org](https://sluurp.org/docs).

## Licence

Free for non-commercial use: personal projects, study, schools, clubs and charities. Commercial use needs a licence, one per server; see [Business licence](https://sluurp.org/business). The full terms are in [LICENSE](LICENSE).

## Issues

Found a bug, or missing something? [Open an issue](https://github.com/SluurpHQ/releases/issues/new/choose).

## Showcase

Apps and sites built with Sluurp are listed on the [Showcase](https://github.com/SluurpHQ/releases/wiki/Showcase) page of the wiki. To add yours, [open a showcase issue](https://github.com/SluurpHQ/releases/issues/new?template=showcase.yml).
