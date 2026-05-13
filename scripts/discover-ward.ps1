<#
.SYNOPSIS
  Discover the layout of a CTH ward for FEV work.

.DESCRIPTION
  Walks the standard CTH override layers under $WardRoot and reports which contain
  cdns/fev_conformal and snps/fev_formality. Also enumerates any existing
  $WardRoot/runs/<block>/<tech>/<flow>/<task> run-areas.

  Output is a JSON document on stdout that the FEV agent can read.

.PARAMETER WardRoot
  Absolute path to the ward root (i.e. the value of $ward).

.EXAMPLE
  pwsh -File discover-ward.ps1 -WardRoot /nfs/site/disks/users/me/myward
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $WardRoot
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $WardRoot)) {
    throw "Ward root not found: $WardRoot"
}

$layers = @('user','project','addon','tech','global')
$flows  = @{
    fev_conformal = 'cdns/fev_conformal'
    fev_formality = 'snps/fev_formality'
}

$sourceMap = foreach ($layer in $layers) {
    foreach ($flow in $flows.Keys) {
        $rel = "$layer/$($flows[$flow])"
        $abs = Join-Path $WardRoot $rel
        [pscustomobject]@{
            layer  = $layer
            flow   = $flow
            path   = $abs
            exists = Test-Path -LiteralPath $abs
        }
    }
}

$runRoot = Join-Path $WardRoot 'runs'
$runAreas = @()
if (Test-Path -LiteralPath $runRoot) {
    # Pattern: $ward/runs/$block/$tech/$flow/$task
    Get-ChildItem -LiteralPath $runRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $block = $_
        Get-ChildItem $block.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $tech = $_
            Get-ChildItem $tech.FullName -Directory -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -in $flows.Keys
            } | ForEach-Object {
                $flow = $_
                Get-ChildItem $flow.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    $runAreas += [pscustomobject]@{
                        block = $block.Name
                        tech  = $tech.Name
                        flow  = $flow.Name
                        task  = $_.Name
                        path  = $_.FullName
                    }
                }
            }
        }
    }
}

[pscustomobject]@{
    ward_root  = $WardRoot
    source_map = $sourceMap
    run_areas  = $runAreas
} | ConvertTo-Json -Depth 6
