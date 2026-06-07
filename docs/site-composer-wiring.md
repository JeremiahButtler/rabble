# Wiring AideaMaker & Bearly Defense to install Rabble via Composer

Both sites use the **Composer-artifact model**: `/web/themes/contrib/` is already
gitignored, so the existing on-server copy of Rabble is **not** tracked in either
site's repo. To bring Rabble under Composer management, each site declares this
repo as a VCS repository and requires `drupal/rabble`. This mirrors the existing
`drupal/ai_token_counter` setup already in AideaMaker's `composer.json`.

> **Ownership boundary:** the edits below belong to each **site's own project**
> (the AideaMaker project and the Bearly Defense project). The Drupal Rabble Theme
> project does not edit the sites' `composer.json` directly, and (per its SSH
> scope) only ever touches the `…/themes/contrib/rabble` folder on the server.
> Both sites auto-deploy on push, so apply these through each site's normal
> deploy workflow.

## Package facts

- **Name:** `drupal/rabble`  ·  **Type:** `drupal-theme`
- **Repo (public):** https://github.com/JeremiahButtler/rabble
- **Installs to:** `web/themes/contrib/rabble` (via `composer/installers`, already
  configured in both sites' `installer-paths`)
- **Versions:** tag `1.0.0` (use `^1.0`), or track `main` with `dev-main`.

## 1. Add the VCS repository

Add this object to the `repositories` array in the site's `composer.json`
(AideaMaker already has an analogous entry for `ai_token_counter`; Bearly Defense
needs the `repositories` array extended):

```json
{
    "type": "vcs",
    "url": "https://github.com/JeremiahButtler/rabble.git",
    "no-api": true
}
```

## 2. Require the package

Pin to the tagged release (recommended for controlled updates):

```
composer require drupal/rabble:^1.0
```

…or track the branch (always latest `main`, matching the `ai_token_counter`
`dev-main` style):

```
composer require drupal/rabble:dev-main
```

## 3. First install over the existing folder

The server already has a plain (untracked) copy at
`web/themes/contrib/rabble`. Composer will refuse to overwrite a non-Composer
directory. Before the first `composer require`/`composer install` that introduces
the package, remove the existing folder so Composer can lay down the managed copy
(the contents are identical to this repo's source of truth, so nothing is lost):

```
rm -rf web/themes/contrib/rabble
composer require drupal/rabble:^1.0
```

After this, `web/themes/contrib/rabble` is Composer-managed and updates with:

```
composer update drupal/rabble
```

## 4. Updating Rabble going forward

1. Make theme changes in the Drupal Rabble Theme repo, commit, and push.
2. Tag a new release (e.g. `1.0.1`) and push the tag — or rely on `dev-main`.
3. On each site: `composer update drupal/rabble` (runs automatically on deploy if
   the constraint resolves to a newer version), then `drush cache:rebuild`.
