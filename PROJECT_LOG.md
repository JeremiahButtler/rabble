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
- **Composer wiring of both live sites is pending** — blocked locally by Avast's
  supply-chain shield (it prevents `php.exe`/composer from modifying
  `composer.json`/`composer.lock`, so a valid lock can't be generated here), and
  the strict SSH scope prevents running composer on the servers. To finish, either
  (A) whitelist `C:\PHP for Windows\php.exe` in Avast and run `composer require`
  in each site project locally, then commit + push, or (B) run `composer require`
  on each server and commit the resulting `composer.json`+`composer.lock` back to
  that site's repo (required because AideaMaker's deploy discards server lock
  drift via `git checkout -- composer.lock`). Steps: `docs/site-composer-wiring.md`.
- Reference docs `RABBLE-THEME.md` were placed in both site projects and left
  **untracked** (per user choice) — not committed to either site repo.
- Future theme edits: edit here, commit, tag, push; sites update via Composer.

---

## Change history

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
