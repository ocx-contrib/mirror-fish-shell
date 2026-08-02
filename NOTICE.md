# NOTICE

This repository packages and redistributes upstream software published by the
[fish-shell project](https://github.com/fish-shell). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `fish` | `ghcr.io/ocx-contrib/fish-shell/fish` | `GPL-2.0-only` |

---

## `fish`

Upstream: <https://github.com/fish-shell/fish-shell>
Published to `ghcr.io/ocx-contrib/fish-shell/fish`.

| Component | SPDX | Holder |
|---|---|---|
| fish (`fish`, `fish_indent`, `fish_key_reader`) | **GPL-2.0-only** | Copyright © 2005-2009 Axel Liljencrantz, 2009- fish-shell contributors |

Upstream's `doc_src/license.rst` states: "``fish`` is released under the GNU
General Public License, version 2." There is no "or (at your option) any later
version" clause, so the id is `GPL-2.0-only` rather than `GPL-2.0-or-later`.
GitHub's licence API answers `NOASSERTION` because the tree also vendors code
under the Python Software Foundation License 2.0, the MIT license and the GNU
Library General Public License 2 — those terms are permissive or weak-copyleft
and impose no further condition on redistributing the compiled binaries.

The fish logo (the friendly-fish terminal mark) is a trademark of the
fish-shell project and its contributors, used here for catalog identification
under nominative fair use.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.

### Corresponding Source (GPLv2 §3)

The fish binaries redistributed here are licensed GPL-2.0-only. The complete
Corresponding Source (including build scripts) for every mirrored version is
the upstream tagged tree:

- Version `X.Y.Z` → tag `X.Y.Z` →
  <https://github.com/fish-shell/fish-shell/releases/tag/X.Y.Z>
- Or clone and check out the exact tag:

  ```bash
  git clone https://github.com/fish-shell/fish-shell
  git -C fish-shell checkout X.Y.Z   # X.Y.Z = the ocx.sh/fish-shell/fish version
  ```

GPL-2.0 has no "same place" network-access clause, so as required by GPLv2
§3(b) the maintainers of this mirror additionally offer, valid for three years
from the distribution of any given version, to provide the complete
Corresponding Source for that version to any third party on request — open an
issue at <https://github.com/ocx-contrib/mirror-fish-shell>. No additional
restrictions are imposed beyond GPL-2.0.
