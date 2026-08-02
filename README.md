# mirror-fish-shell

OCX mirror for [fish](https://github.com/fish-shell/fish-shell). One
repository, one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [fish](https://github.com/fish-shell/fish-shell) | [`fish/mirror.yml`](fish/mirror.yml) | `ghcr.io/ocx-contrib/fish-shell/fish` | `ocx.sh/fish-shell/fish` | `GPL-2.0-only` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/fish`. `fish-shell/fish` is the grouped successor. The namespace keeps
> upstream's org because `fish-shell` IS the project's own brand, not a person's
> handle; the package segment is the publish-name `fish`.

## Layout

```
mirror-base.yml           repo-wide policy every spec inherits via `extends:`
fish/
├── mirror.yml            the spec — never at the repo root
├── metadata.json         bundle interface (linux)
├── metadata-darwin.json  bundle interface (macOS — different PATH and binaries)
├── CATALOG.md            → ocx package describe
├── logo.png              describe asset
└── tests/smoke.star      Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`fish` publishes four platform entries: both Linux arches and both macOS
arches. **No Windows** — upstream ships no Windows build.

Upstream builds one Linux binary per arch and both are **fully static** —
measured on 4.8.1, amd64 is `static-pie linked` and arm64 `statically linked`,
neither carrying a `PT_INTERP` or a single `DT_NEEDED`, and there are no
musl/glibc variants to choose between. `os.features` states what an artifact
requires *of the host*, so both Linux keys are **bare**: tagging them
`+libc.musl` would be a false requirement that hid them from every glibc host.
The `alpine:3.20` container leg in `mirror-base.yml` is what turns that claim
into evidence; the measurement itself is recorded above the `assets:` block in
`fish/mirror.yml`.

The two archive shapes disagree, which is why the bundle interface is split:

- **linux** — `fish-<v>-linux-{x86_64,aarch64}.tar.xz` is a single
  self-contained `fish` binary and nothing else; bundled bare at the root
  (`strip_components: 0`), `PATH = ${installPath}`.
- **darwin** — `fish-<v>.app.zip` carries ONE universal (arm64 + x86_64)
  binary, so the same asset serves both darwin arches. `strip_components: 6`
  lifts the `.app`'s `…/Contents/Resources/base/usr/local/{bin,share,etc}`
  install tree to the bundle root, dropping the shallower `Contents/MacOS/fish`
  GUI launcher and the code-signature files with it — so only the real CLI
  `bin/fish` lands on PATH (no E2BIG launcher recursion).
  `PATH = ${installPath}/bin` via `metadata-darwin.json`. That tree
  additionally ships `fish_indent` and `fish_key_reader`, which the Linux
  archive does not, so the two `binaries` claims differ.

Both darwin legs run on the Apple-Silicon `macos-14` runner (GitHub's Intel
pool is retired). The amd64 leg declares `prefix: ["arch", "-x86_64"]` to
select the x86_64 slice under Rosetta 2 — but **ocx-mirror 0.5.0 does not emit
`prefix` into any generated workflow**, so today that leg re-tests the arm64
slice. The bundle it validates is the correct one and the x86_64 slice is
well-formed per `file`; the gap is in what the test proves, not in what gets
published. The declaration stays so the leg becomes real the moment the
renderer wires it up.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `fish/mirror.yml` | hand | yes — see below |
| `fish/{metadata*.json,CATALOG.md,logo.*}` | hand | — |
| `fish/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec fish/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

`bin_scan` is **off**, and it cannot be otherwise. The scan only looks *below*
an interface PATH entry of the form `${installPath}/<dir>`, and the check runs
against the *default* metadata — which here is the Linux one, whose PATH is a
bare `${installPath}` because the executable IS the content root. `verify` is
rejected at spec load with exit 65 ("bin_scan is enabled but `metadata.json`
declares no interface-visible `${installPath}/<dir>` PATH entry"), and the
darwin override exposing `${installPath}/bin` does not rescue it. So each
metadata file hand-lists its own `binaries` — `["fish"]` on Linux,
`["fish", "fish_indent", "fish_key_reader"]` on macOS.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; the
redistributed fish binaries are **GPL-2.0-only**, and the Corresponding Source
offer that entails is recorded in [`NOTICE.md`](NOTICE.md).
