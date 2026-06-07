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
- Wire AideaMaker's `composer.json` to require `drupal/rabble` (done through the
  AideaMaker project, not from here — a reference was added there).
- Wire Bearly Defense's `composer.json` likewise (through the Bearly Defense
  project).
- Future theme edits: edit here, commit, tag, push; sites update via Composer.

---

## Change history

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
