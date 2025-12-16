[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(25, 100)]
    [int]$Speed,

    [Parameter(Mandatory = $false)]
    [string]$Match = 'Aquacomputer D5 Legacy'
)

$repo = Resolve-Path -LiteralPath $PSScriptRoot
$venvPython = Join-Path -Path $repo -ChildPath '.venv\Scripts\python.exe'

if (-not (Test-Path -LiteralPath $venvPython)) {
    Write-Error "Venv python not found at '$venvPython'. Create it with: py -3 -m venv .venv"
    $global:LASTEXITCODE = 4
    return 4
}

Write-Host "Setting '$Match' pump speed to $Speed%..."

Push-Location -LiteralPath $repo
try {
    & $venvPython -m liquidctl --match $Match set pump speed $Speed
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

$global:LASTEXITCODE = $exitCode
return $exitCode
