# Launched (detached) by the rabble repo's pre-push hook after a tag push.
# Author: Jeremiah Buttler
#
# Git has no post-push hook, and Composer consumers can't be pointed at a tag
# until that tag is actually on origin. So the pre-push hook spawns THIS script
# detached; it waits until the latest local tag is visible on origin, then runs
# propagate-to-consumers.ps1 (which itself re-verifies the tag is on origin and
# no-ops any consumer already at the target - so this is safe even if the push
# ultimately failed: the tag never appears and we abort without touching anyone).
#
# Can also be run by hand at any time; it just propagates the latest tag.

$ErrorActionPreference = 'Stop'

$Repo   = 'C:\Users\jeremy\Documents\Projects\Drupal Rabble Theme'
$LogDir = Join-Path $Repo 'automation\logs'
$Log    = Join-Path $LogDir 'propagate.log'

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
function Log([string]$m) {
    "$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))  $m" | Add-Content -Encoding utf8 -Path $Log
}

try {
    $tag = (& git -C $Repo tag --sort=-v:refname | Where-Object { $_ } | Select-Object -First 1)
    if (-not $tag) { Log 'No tags in rabble repo; nothing to propagate.'; return }
    $tag = $tag.Trim()
    Log "Pre-push trigger: waiting for $tag to land on origin..."

    # The push runs concurrently with us; poll origin for the tag (~90s max).
    $onOrigin = $false
    for ($i = 0; $i -lt 30; $i++) {
        $r = (& git -C $Repo ls-remote origin "refs/tags/$tag") 2>$null
        if (-not [string]::IsNullOrWhiteSpace($r)) { $onOrigin = $true; break }
        Start-Sleep -Seconds 3
    }
    if (-not $onOrigin) { Log "Tag $tag never appeared on origin after ~90s; aborting (push may have failed)."; return }

    Log "Tag $tag is on origin; propagating to consumers."
    & (Join-Path $Repo 'automation\propagate-to-consumers.ps1') *>> $Log
    Log "Propagation finished for $tag."
}
catch {
    Log "ERROR: $($_.Exception.Message)"
}
