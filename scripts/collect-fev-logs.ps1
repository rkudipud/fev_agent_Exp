<#
.SYNOPSIS
  Collect FEV logs and reports from a specific run-area for offline analysis.

.PARAMETER WardRoot
  Absolute path to the ward root.

.PARAMETER Block
  Block / build name (sub-directory under $ward/runs/).

.PARAMETER Tech
  Tech node directory name.

.PARAMETER Flow
  fev_conformal or fev_formality.

.PARAMETER Task
  Specific FEV task name (e.g. fev_rtl2syn, fev_fm_rtl2rtl).

.PARAMETER OutDir
  Where to copy collected artifacts. Default: ./fev-bundle-<timestamp>.

.EXAMPLE
  pwsh -File collect-fev-logs.ps1 -WardRoot $ward -Block b001 -Tech p1276 -Flow fev_conformal -Task fev_rtl2syn
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $WardRoot,
    [Parameter(Mandatory)] [string] $Block,
    [Parameter(Mandatory)] [string] $Tech,
    [Parameter(Mandatory)] [ValidateSet('fev_conformal','fev_formality')] [string] $Flow,
    [Parameter(Mandatory)] [string] $Task,
    [string] $OutDir
)

$ErrorActionPreference = 'Stop'

$runDir = Join-Path $WardRoot "runs/$Block/$Tech/$Flow/$Task"
if (-not (Test-Path -LiteralPath $runDir)) {
    throw "Run area not found: $runDir"
}

if (-not $OutDir) {
    $stamp  = (Get-Date -Format 'yyyyMMdd-HHmmss')
    $OutDir = Join-Path (Get-Location) "fev-bundle-$Block-$Tech-$Flow-$Task-$stamp"
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Common artifact name candidates — keep in sync with config/ward-paths.yaml run_area.artifacts.
$patterns = @(
    'logs/lec.log',
    'logs/fm.log',
    'logs/*_lec.log.*',
    'logs/*_fm.log.*',
    'logs/*',
    'reports/*',
    'scripts/*.tcl',
    '*.log',
    '*.rpt'
)

$collected = New-Object System.Collections.Generic.List[string]
foreach ($p in $patterns) {
    Get-ChildItem -Path $runDir -Recurse -Filter $p -File -ErrorAction SilentlyContinue | ForEach-Object {
        $rel = $_.FullName.Substring($runDir.Length).TrimStart('\','/')
        $dest = Join-Path $OutDir $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        $collected.Add($rel) | Out-Null
    }
}

[pscustomobject]@{
    run_area  = $runDir
    out_dir   = $OutDir
    artifacts = $collected
} | ConvertTo-Json -Depth 4
