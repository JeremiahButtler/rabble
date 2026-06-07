# Rabble — Features

Rabble is a clean, accessible, and flexible Drupal front-end theme targeting
Drupal **10, 11, and 12** (`core_version_requirement: ^10 || ^11 || ^12`). It is
distributed as a Composer package (`drupal/rabble`) from a public git repository
and consumed by sites via Composer.

An in-Drupal, discoverable view of the theme's capabilities is available at the
theme's settings page: **Appearance › Rabble › Settings**.

## Core features

- **Responsive, mobile-first layout** — fluid grid with documented breakpoints
  (`rabble.breakpoints.yml`).
- **Colorable / themeable** — color and type controls surfaced through
  `theme-settings.php` and `config/install/rabble.settings.yml`.
- **Accessibility-first markup** — skip links, ARIA-friendly navigation, and
  accessible form/message components.
- **Extensive region set** — 50+ named regions including multi-column main
  content, featured slots, hero/slideshow, sidebars, footer zones, and dedicated
  user-account / user-profile regions (see `rabble.info.yml`).
- **Single-Directory Components (SDC)** — reusable components under `components/`
  (e.g. `teaser`).
- **Layout Builder integration** — overrides and styling for two/three/four-column
  Layout Builder sections and Layout Discovery sections.
- **Library overrides & extends** — refines core CSS/JS (ajax progress,
  autocomplete, dropbutton, vertical tabs, messages, dialogs, progress, tabledrag,
  content moderation, node preview) for a cohesive look.
- **Twig template library** — comprehensive template overrides under `templates/`
  (content, fields, forms, navigation, user, views, datetime, filter).
- **Self-hosted fonts & assets** — fonts, icons, and SVG imagery shipped with the
  theme (`fonts/`, `images/`, `logo.svg`, `favicon.ico`).

## Distribution

- **Composer package:** `drupal/rabble` (type `drupal-theme`) → installs to
  `web/themes/contrib/rabble`.
- **Source of truth:** the AideaMaker copy of the theme, mirrored into this repo.
- **Consumers:** AideaMaker (`aideamaker.com`) and Bearly Defense, both of which
  pull the theme from this repo via Composer.
