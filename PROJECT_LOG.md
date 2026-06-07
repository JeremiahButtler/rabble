# Project Log — Drupal Rabble Theme

A living record of changes plus a current **Resume Brief** so any machine can pick
this project up from its present state. Newest entries first.

---

## Resume Brief (current state)

**What this is:** The source-of-truth git repository for **Rabble**, a Drupal
front-end theme (machine name `rabble`, Drupal 10/11/12). Authored by Jeremiah
Buttler, owned by AideaMaker LLC.

**Repository:** https://github.com/JeremiahButtler/rabble (**public**) ·
Composer package `drupal/rabble` (type `drupal-theme`) · current tag **1.0.0**.

**Source of truth:** The theme content was pulled from the **AideaMaker** server
copy at `/var/www/html/aideamaker/web/themes/contrib/rabble`, which is the
authoritative version. The Bearly Defense copy
(`/var/www/html/bearlydefense/web/themes/contrib/rabble`) was byte-identical at
import time.

**Consumers:** AideaMaker (`aideamaker.com`) and Bearly Defense — both Drupal
sites on the same Linux server (`ubuntu@35.164.190.138`). Both use the
Composer-artifact model, so `web/themes/contrib/` is already gitignored in each
site's repo; Rabble is therefore already excluded from both sites' repos and is to
be installed via Composer from this repo.

**SSH scope (strict):** This project may use SSH **only** to touch
`/var/www/html/aideamaker/web/themes/contrib/rabble` on the AideaMaker server.
Everything else on that server is managed by other projects.

**How the sites consume it (Composer wiring — handoff to each site's project):**
each site adds a VCS repository pointing at this repo and requires
`drupal/rabble`, mirroring the existing `drupal/ai_token_counter` pattern already
used on AideaMaker. See `docs/site-composer-wiring.md`.

**Next steps / open items:**
- **BOTH SITES COMPLETE — rabble installed via Composer, live, and canonical.**
  - **AideaMaker:** server, origin `aideamaker.git`, and local copy all at commit
    `5848332`. rabble Enabled (11.x), default theme; healthy composer.lock restored.
  - **Bearly Defense:** server, origin `bearly-defense.git`, and local copy all at
    commit `7e7a503`. rabble Enabled (11.x), default theme.
- **Local repos both correctly wired:** `Projects\AideaMaker` → `aideamaker.git`,
  `Projects\Bearly Defense` → `bearly-defense.git`. (Earlier `Projects\AideaMaker`
  was wrongly tracking `bearly-defense.git`; fixed, misplaced PAT removed.)
- Reference docs `RABBLE-THEME.md` exist in both site projects, left **untracked**.
- **Future updates:** edit the theme here, commit, tag, push; then on each site run
  `composer update drupal/rabble && drush cr` (or let auto-deploy pull). The two
  sites push to their own repos via different auth: AideaMaker pushes from the LOCAL
  copy (GCM https), Bearly's server pushes directly (SSH host-alias `github.com-bearly`).

---

## Change history

### 2026-06-06 — Reconciled Bearly Defense: rabble now canonical in bearly-defense.git
- **What changed:** The Bearly Defense server was already wired (rabble required via
  Composer, Enabled 11.x, default theme, at commit `7e7a503`) but its origin
  `bearly-defense.git` lagged. Pushed the server's commit to origin via the server's
  SSH host-alias remote, then fast-forwarded the local copy. Server, origin, and the
  local `Projects\Bearly Defense` copy are now the identical commit `7e7a503`.
- **Why:** User directed (emphatically) to use the authorized SSH access and finish
  the second site, closing the canonical-durability gap the same way AideaMaker's was.
- **Details:** SSH'd to the server, confirmed HEAD `7e7a503` with rabble Enabled
  (11.x) + default and a single `drupal/rabble` require in `composer.json`. Bearly's
  server remote is the SSH alias `git@github.com-bearly:JeremiahButtler/bearly-defense.git`
  (its own deploy key has write), so the push ran server-side as a clean fast-forward
  `b572a84..7e7a503` — no local credential needed (this differs from AideaMaker, which
  pushes from the LOCAL copy via GCM). Then `git merge --ff-only origin/main` on the
  local copy advanced it to `7e7a503`; verified local HEAD = origin/main = `7e7a503`.
- **Files touched (server + remotes, not this repo):** bearlydefense server git HEAD
  (already at `7e7a503`); `bearly-defense.git` origin (fast-forwarded); local
  `Projects\Bearly Defense` (fast-forwarded). This theme repo unchanged.

### 2026-06-06 — Reconciled AideaMaker: rabble now canonical in aideamaker.git
- **What changed:** Pushed the AideaMaker server's 3 commits (config drift + rabble
  `5848332`) to the canonical `aideamaker.git` origin, and reset the local copy to
  match. Server, origin, and local are now the identical commit `5848332`.
- **Why:** User said "do it" — close the canonical-durability gap so the rabble
  require lives in the GitHub repo, not just on the server.
- **Details:** The local GCM credential had write access to `aideamaker.git` (the
  earlier 403 was the bearly-scoped PAT used from the server). Since the local copy
  lacked the server's commits, fetched the server's `main` over SSH into a temp ref,
  verified `origin/main` (`aec413b`) was a clean ancestor (fast-forward safe), and
  pushed `srv/main:main` → `aec413b..5848332`. Then `git reset --hard origin/main`
  on the local copy (discarding the 3 disposable auto-save commits — cosmetic URL
  tidy + corrupt lock + docs), preserving `RABBLE-THEME.md` as an untracked
  reference doc. Server already at `5848332` (push source) so no server change
  needed; rabble confirmed Enabled (11.x). The server's own `git fetch` in an
  ad-hoc SSH shell fails for lack of an interactive credential, but that's the
  deploy's separate concern — HEAD already equals origin, so deploys are no-ops.
- **Files touched:** `Projects\AideaMaker` git history (reset to origin);
  `aideamaker.git` origin (fast-forwarded to `5848332`).

### 2026-06-06 — Diagnosed AideaMaker divergence: server complete, local commits disposable
- **What changed:** Investigation only (no source changes). Determined exactly what
  the AideaMaker server is missing relative to the local copy's 3 divergent commits.
- **Why:** User confirmed the server is authoritative and asked what's missing from
  it, to decide how to reconcile.
- **Details:** Answer — functionally **nothing** is missing from the server. The
  local 3 commits contain: (1) a cosmetic `ai_token_counter` VCS URL change
  `stexcomputers→jeremiahbuttler` (both `ls-remote` to the SAME commit `892ff1b`, so
  GitHub redirects; server's URL still works); (2) a corrupt `composer.lock` that
  removed ~21 frontend asset packages (codemirror, jquery/*, popperjs, tippyjs,
  etc.) — adopting it would break the site, so the server is correct to keep them
  (verified intact on server); (3) local-only docs (`RABBLE-THEME.md`,
  `PROJECT_LOG.md`, `project-log.html`). Conclusion: discard the local 3 commits;
  the only real gap is origin `aideamaker.git` lagging the server by 3 commits.
- **Files touched:** none (read-only diagnosis); log files updated.

### 2026-06-06 — Fixed AideaMaker local repo wiring (was pointing at bearly-defense)
- **What changed:** Repointed `Projects\AideaMaker`'s git remote from
  `JeremiahButtler/bearly-defense.git` to its correct `JeremiahButtler/aideamaker.git`
  (clean URL; removed the misplaced bearly-defense PAT that was embedded in it) and
  set upstream tracking to `origin/main`. Confirmed `Projects\Bearly Defense`
  already correctly tracks `bearly-defense.git` and is in sync.
- **Why:** User reported the AideaMaker project was pointing at the Bearly Defense
  repo and asked to make each site use its own repo. The mis-wiring meant
  AideaMaker's pushes (and any composer-file push for the rabble rollout) targeted
  the wrong repo.
- **Details:** Verified by content before changing remotes — AideaMaker folder is
  the `aideamaker.com` site (UUID `790db6bd-37cb-4a62-8721-b0624e0b0775`), Bearly
  folder is `bearlynature.com`; no content was swapped. The local AideaMaker history
  descends from `aideamaker.git` (shared base `aec413b`), so it was only ever
  pushing to the wrong remote; against its real repo it is just ahead 3. The bogus
  "ahead 89 / behind 15" was the wrong-repo comparison. Did NOT push the 3 local
  commits — the live server has its own 3 divergent commits (incl. rabble) on the
  same base; reconciliation is a separate, user-gated decision.
- **Files touched:** `Projects\AideaMaker\.git\config` (remote URL + upstream).

### 2026-06-06 — AideaMaker wired + live via Composer; Bearly Defense pending
- **What changed:** On the AideaMaker server, ran `composer require
  drupal/rabble:^1.0` (with the corrected JSON-form VCS repo config including
  `no-api:true`), rebuilt cache, and committed `composer.json`+`composer.lock`
  (commit `5848332`). rabble is now installed via Composer, **Enabled (11.x)**, and
  the default theme.
- **Why:** User authorized "do whatever it takes and fix it" to complete the
  AideaMaker composer wiring after the in-PuTTY `git push` prompted for credentials.
- **Details:** The user's `composer config repositories.rabble.no-api true` had
  failed (sub-key needs the JSON form); fixed with `composer config
  repositories.rabble '{"type":"vcs",...,"no-api":true}'`. Server push to GitHub
  origin failed 403 — the available PAT only has write to `bearly-defense`, not
  `aideamaker`; the change stays committed locally on the server (durable across
  deploys). Discovered the local `Projects\AideaMaker` repo's remote wrongly points
  to `bearly-defense.git` (so did NOT push from there). Bearly Defense wiring
  blocked by the SSH auto-mode classifier (out-of-boundary server) — awaiting
  explicit go-ahead.
- **Files touched (on AideaMaker server, committed there):** `composer.json`,
  `composer.lock`. Local: PROJECT_LOG.md, project-log.html.

### 2026-06-06 — Composer-wiring attempt; reference docs placed; prod left untouched
- **What changed:** Placed `RABBLE-THEME.md` reference docs in the AideaMaker and
  Bearly Defense projects (left untracked per user choice). Attempted to wire both
  sites' `composer.json` to require `drupal/rabble`; reverted the partial
  AideaMaker edit so both production repos are left unmodified.
- **Why:** User chose "apply to both sites now," but the wiring cannot be safely
  completed from this environment, and pushing an unverifiable `composer.lock` to a
  site whose active theme is `rabble` risks downtime.
- **Details:** Avast's supply-chain shield blocks `php.exe`/composer from modifying
  `composer.json`/`composer.lock` locally, so no valid lock could be generated; the
  strict SSH scope (rabble folder only) prevents server-side composer/log access.
  Presented the user two paths (whitelist php locally, or server-side require +
  commit the lock back to each repo) and awaited their choice. Cleaned up scratch
  tooling (`_tools/composer.phar`).
- **Files touched:** `AideaMaker/RABBLE-THEME.md` (untracked),
  `Bearly Defense/RABBLE-THEME.md` (untracked); AideaMaker `composer.json` edited
  then reverted (net no change).

### 2026-06-06 — Project created; theme extracted to its own public repo
- **What changed:** Created the `Drupal Rabble Theme` project. Pulled the Rabble
  theme from the AideaMaker server (source of truth) into the project root, added
  a Composer package manifest (`composer.json`, `drupal/rabble`, type
  `drupal-theme`), `.gitignore`, and `.gitattributes` (LF normalization).
- **Why:** To manage the Rabble theme from a single dedicated git repository so
  both AideaMaker and Bearly Defense can install/update it via Composer instead of
  each carrying an untracked copy.
- **Details:** Initialized git on `main`, created the **public** GitHub repo
  `JeremiahButtler/rabble`, pushed, and tagged **1.0.0**. Applied the default
  skill bundle to match the DrupalAITokenCounterModule skill set. Added a
  reference in the AideaMaker project noting that Rabble is managed externally and
  excluded from AideaMaker's repo.
- **Files touched:** entire theme tree (imported), `composer.json`, `.gitignore`,
  `.gitattributes`, `CREDITS.md`, `FEATURES.md`, `TERMS.md`, `PROJECT_LOG.md`,
  `project-log.html`, `docs/site-composer-wiring.md`,
  `.claude-project-skills.json`.
