# Install the rabble repo's git hooks from their tracked source in automation/hooks/.
# Author: Jeremiah Buttler
#
# .git/hooks is not version-controlled, so run this ONCE per clone (and again
# whenever the hook source changes) to (re)install. Writes the hook with LF
# endings and no BOM so Git-for-Windows' bundled sh can execute it.
#
#   pwsh automation\install-hooks.ps1

$ErrorActionPreference = 'Stop'

$Repo     = 'C:\Users\jeremy\Documents\Projects\Drupal Rabble Theme'
$HookSrc  = Join-Path $Repo 'automation\hooks'
$HookDst  = Join-Path $Repo '.git\hooks'

if (-not (Test-Path $HookDst)) { throw "No .git\hooks at $HookDst - is this a git repo?" }

Get-ChildItem -LiteralPath $HookSrc -File | ForEach-Object {
    $content = (Get-Content -Raw -LiteralPath $_.FullName) -replace "`r`n", "`n"
    $dst = Join-Path $HookDst $_.Name
    [System.IO.File]::WriteAllText($dst, $content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "Installed hook: $($_.Name) -> $dst"
}

Write-Host "Done. Hooks are active on the next git push."
