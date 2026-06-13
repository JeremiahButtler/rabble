# rabble automation — auto-deploy to Composer consumers

The **rabble** theme is published as a Composer package (`drupal/rabble`, a `vcs`
repository pointing at this GitHub repo) and consumed by two production sites —
**AideaMaker** and **Bearly Defense**. Each site installs rabble by an exact
commit pinned in its own `composer.lock`, and each already auto-deploys: a
systemd 60-second poll timer runs `git pull` + `composer install` + `drush cr`
whenever its site repo's `origin/main` advances.

Because consumers pin an exact commit, **pushing a new rabble tag to GitHub does
nothing on the live sites by itself** — the lock pin has to move first. This
folder automates moving it.

> This is the Composer-correct analogue of the d10 Colosseum theme's
> push-to-deploy. Colosseum is a *custom, non-Composer* theme, so it pushes files
> straight into the site's theme folder via a server-side `post-receive` hook.
> rabble is *Composer-managed*, so instead we move the lock pin and let each
> site's existing `composer install` deliver it — which keeps Composer's metadata
> consistent (a direct file push would leave `installed.json` lying about the
> version and get reverted by the next `composer update`).

## How a release reaches production

1. Tag a release in this repo and push the tag (the git-repo skill's version bump
   produces `v1.x` tags) — e.g. `git push origin 1.0.2`.
2. The **`pre-push` hook** (see below) detects the tag push and launches
   `propagate-after-push.ps1` detached.
3. That helper waits until the tag is visible on `origin`, then runs
   `propagate-to-consumers.ps1`.
4. `propagate-to-consumers.ps1` rebases each consumer repo on its origin, rewrites
   **only** the `drupal/rabble` block in that site's `composer.lock` to the new
   tag + commit, commits, and pushes.
5. Each site's existing 60s timer pulls and `composer install`s the new theme —
   live within ~a minute.

## Scripts

| File | Purpose |
|---|---|
| `propagate-to-consumers.ps1` | The core. Bumps every consumer's `composer.lock` to rabble's latest tag, commits, pushes. Has `-WhatIf`. Verifies the tag is on origin first; no-ops consumers already current. |
| `propagate-after-push.ps1` | Waits for the just-pushed tag to land on origin, then runs the above. Logs to `automation/logs/propagate.log`. |
| `hooks/pre-push` | Tracked source of the git hook that fires propagation on a tag push. |
| `install-hooks.ps1` | Installs `hooks/*` into `.git/hooks` (not version-controlled — run once per clone). |

## Manual use

Preview what would change without touching anything:

```
pwsh automation\propagate-to-consumers.ps1 -WhatIf
```

Propagate the latest tag now:

```
pwsh automation\propagate-to-consumers.ps1
```

## One-time setup on a fresh clone

```
pwsh automation\install-hooks.ps1
```

## Consumers

Edit the `$Consumers` list at the top of `propagate-to-consumers.ps1` to add or
remove sites. Each must be a local checkout on `main` with push rights to its own
origin, installing `drupal/rabble` via the GitHub `vcs` repository.

> **Note on constraints:** propagation bumps consumers to rabble's *latest tag*.
> This assumes that tag satisfies each consumer's constraint (today every tag is
> `1.0.x` and every consumer requires `^1.0`). A future MAJOR release the
> consumers don't yet allow would need per-consumer constraint resolution added
> to `propagate-to-consumers.ps1` first.
