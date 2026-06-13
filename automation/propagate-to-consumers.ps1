# Propagate the current rabble release to its Composer consumers.
# Author: Jeremiah Buttler
#
# rabble is a Composer VCS package (drupal/rabble) pinned by exact commit in each
# consumer site's composer.lock. A GitHub tag push alone changes NOTHING on the
# live sites, because their deploy runs `composer install`, which installs exactly
# the reference the lock names. This script moves that pin:
#
#   1. Resolve rabble's latest tag + commit, and confirm the tag is published on
#      origin (so we never point a consumer at a ref GitHub doesn't have yet).
#   2. For each consumer: rebase on origin/main, rewrite ONLY the drupal/rabble
#      block in composer.lock (version + the 3 commit references), commit, push.
#   3. Each consumer's existing systemd 60s pull-timer (deploy-pull.sh -> deploy.sh:
#      git pull + composer install + drush) then deploys the new theme to
#      production automatically, within ~60s of the push.
#
# This is the Composer-correct analogue of the Colosseum push-to-deploy: Colosseum
# is a non-Composer custom theme so it pushes files straight into the theme folder;
# rabble is Composer-managed so we move the lock pin and let composer install do the
# delivery, keeping Composer's metadata consistent.
#
#   pwsh automation\propagate-to-consumers.ps1            # propagate latest tag
#   pwsh automation\propagate-to-consumers.ps1 -WhatIf    # show what would change, do nothing
#
# Assumes the latest tag satisfies each consumer's version constraint (today: all
# tags are 1.0.x and every consumer requires "^1.0"). A future MAJOR bump that the
# consumers do NOT yet allow would need per-consumer constraint resolution added
# here (what `composer update drupal/rabble` would do) before bumping them past it.

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$RabbleRepo = 'C:\Users\jeremy\Documents\Projects\Drupal Rabble Theme'
)

$ErrorActionPreference = 'Stop'

# Consumer site repos that install drupal/rabble via Composer. Each is a clean
# checkout on main with push rights to its own origin; pushing auto-deploys.
$Consumers = @(
    @{ Name = 'AideaMaker';     Path = 'C:\Users\jeremy\Documents\Projects\AideaMaker' }
    @{ Name = 'Bearly Defense'; Path = 'C:\Users\jeremy\Documents\Projects\Bearly Defense' }
)

# Run a git command in a repo; return exit code + combined output. git writes
# normal progress to stderr, so judge success by the exit code, not by stderr.
function Invoke-Git {
    param([string]$RepoPath, [string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out  = & git -C $RepoPath @GitArgs 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
    [pscustomobject]@{ Code = $code; Output = (($out | ForEach-Object { $_.ToString() }) -join "`n") }
}

# Write text as UTF-8 with NO BOM and no added trailing newline (PS5.1's
# Set-Content -Encoding utf8 prepends a BOM, which would corrupt composer.lock).
function Write-TextNoBom {
    param([string]$Path, [string]$Text)
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

# --- Resolve rabble's release target (latest tag + its commit) ---------------
$tag = (& git -C $RabbleRepo tag --sort=-v:refname | Where-Object { $_ } | Select-Object -First 1)
if (-not $tag) { throw "No tags found in rabble repo at $RabbleRepo." }
$tag = $tag.Trim()
$sha = (& git -C $RabbleRepo rev-list -n1 $tag).Trim()
$shortSha = $sha.Substring(0, 9)
Write-Host "Rabble release target: $tag ($shortSha)"

# Safety: the tag MUST already be on origin, or a consumer would point at a ref
# GitHub can't serve and that site's next composer install would fail.
$remote = (& git -C $RabbleRepo ls-remote origin "refs/tags/$tag") 2>$null
if ([string]::IsNullOrWhiteSpace($remote)) {
    throw "Tag $tag is not on origin yet. Push it first:  git -C `"$RabbleRepo`" push origin $tag"
}

$changed = 0
$skipped = 0

foreach ($c in $Consumers) {
    Write-Host "`n=== $($c.Name) ==="
    $lockPath = Join-Path $c.Path 'composer.lock'
    if (-not (Test-Path -LiteralPath $lockPath)) {
        Write-Host "  no composer.lock at $($c.Path) - skip"; $skipped++; continue
    }

    # Sync with origin first: each site's server drift-guard can auto-commit live
    # config/composer drift to origin, so we rebase to avoid a non-fast-forward push.
    Invoke-Git $c.Path @('fetch', 'origin', 'main') | Out-Null
    $rb = Invoke-Git $c.Path @('rebase', 'origin/main')
    if ($rb.Code -ne 0) {
        Invoke-Git $c.Path @('rebase', '--abort') | Out-Null
        Write-Host "  rebase on origin/main failed - SKIP. Detail: $($rb.Output)"; $skipped++; continue
    }

    $lock = Get-Content -Raw -LiteralPath $lockPath

    # Locate the current rabble pin inside its own package block.
    $blockRe = '"name":\s*"drupal/rabble",\s*"version":\s*"(?<ver>[^"]+)",\s*"source":\s*\{\s*"type":\s*"git",\s*"url":\s*"[^"]+",\s*"reference":\s*"(?<ref>[0-9a-f]{40})"'
    $m = [regex]::Match($lock, $blockRe)
    if (-not $m.Success) {
        Write-Host "  drupal/rabble block not found in composer.lock - SKIP"; $skipped++; continue
    }
    $oldVer = $m.Groups['ver'].Value
    $oldRef = $m.Groups['ref'].Value

    if ($oldRef -eq $sha) {
        Write-Host "  already at $oldVer ($shortSha) - nothing to do"; $skipped++; continue
    }
    Write-Host "  $oldVer ($($oldRef.Substring(0,9))) -> $tag ($shortSha)"

    if ($PSCmdlet.ShouldProcess($c.Name, "bump drupal/rabble $oldVer->$tag, commit, push (auto-deploys)")) {
        # Bump the version ONLY inside the rabble block, then swap the old commit
        # SHA everywhere it appears (source.reference, dist.url zipball, dist.reference
        # - all 3 are unique to the rabble block).
        $verPat = '("name":\s*"drupal/rabble",\s*"version":\s*")' + [regex]::Escape($oldVer) + '(")'
        $newLock = [regex]::Replace($lock, $verPat, "`${1}$tag`${2}")
        $newLock = $newLock.Replace($oldRef, $sha)
        if ($newLock -eq $lock) {
            Write-Host "  no change produced (unexpected) - SKIP"; $skipped++; continue
        }
        Write-TextNoBom -Path $lockPath -Text $newLock

        Invoke-Git $c.Path @('add', 'composer.lock') | Out-Null
        $cm = Invoke-Git $c.Path @('commit', '-m', "Update drupal/rabble to $tag ($shortSha)")
        if ($cm.Code -ne 0) {
            Write-Host "  commit failed: $($cm.Output)"; $skipped++; continue
        }

        $ps = Invoke-Git $c.Path @('push', 'origin', 'main')
        if ($ps.Code -ne 0 -and $ps.Output -match 'non-fast-forward|fetch first|rejected') {
            # The server pushed drift between our rebase and push; rebase and retry once.
            Invoke-Git $c.Path @('fetch', 'origin', 'main') | Out-Null
            $rb2 = Invoke-Git $c.Path @('rebase', 'origin/main')
            if ($rb2.Code -eq 0) { $ps = Invoke-Git $c.Path @('push', 'origin', 'main') }
            else { Invoke-Git $c.Path @('rebase', '--abort') | Out-Null }
        }
        if ($ps.Code -ne 0) {
            Write-Host "  PUSH FAILED: $($ps.Output)"; $skipped++; continue
        }
        Write-Host "  pushed - $($c.Name) production auto-deploys within ~60s"
        $changed++
    }
}

Write-Host "`nDone. $changed consumer(s) updated, $skipped unchanged/skipped."
if ($changed -gt 0) {
    Write-Host "Each updated site's 60s systemd pull-timer will git pull + composer install + drush cr the new theme."
}
