<?php

/**
 * @file
 * Post update functions for rabble.
 */

/**
 * Implements hook_removed_post_updates().
 */
function rabble_removed_post_updates() {
  return [
    'rabble_post_update_add_rabble_primary_color' => '11.0.0',
  ];
}
