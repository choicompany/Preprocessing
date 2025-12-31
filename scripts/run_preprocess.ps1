param(
  [Parameter(Mandatory=$true)]
  [string]$InputPath,

  [Parameter(Mandatory=$true)]
  [string]$OutputPath,

  [string]$ReportPath = "outputs/report.json",
  [string]$Encoding = ""
)

$ErrorActionPreference = "Stop"

$python = "python"

$argList = @(
  "src/preprocess.py",
  "--input", $InputPath,
  "--output", $OutputPath,
  "--report", $ReportPath
)

if ($Encoding -and $Encoding.Trim().Length -gt 0) {
  $argList += @("--encoding", $Encoding)
}

& $python @argList
