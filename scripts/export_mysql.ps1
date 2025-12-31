param(
  [Parameter(Mandatory=$true)]
  [string]$QueryFile,

  [Parameter(Mandatory=$true)]
  [string]$OutputCsv,

  [string]$Hostname = $env:MYSQL_HOSTNAME,
  [int]$Port = $(if ($env:MYSQL_PORT) { [int]$env:MYSQL_PORT } else { 3306 }),
  [string]$User = $env:MYSQL_USER,
  [string]$Password = $env:MYSQL_PASSWORD,
  [string]$Database = $env:MYSQL_DATABASE
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $QueryFile)) { throw "QueryFile not found: $QueryFile" }
if (-not $Hostname) { throw "MYSQL_HOSTNAME is required (or -Hostname)" }
if (-not $User) { throw "MYSQL_USER is required (or -User)" }
if (-not $Database) { throw "MYSQL_DATABASE is required (or -Database)" }

$python = "py"
$args = @(
  "scripts/export_mysql_pandas.py",
  "--query-file", $QueryFile,
  "--output", $OutputCsv,
  "--hostname", $Hostname,
  "--port", $Port,
  "--user", $User,
  "--password", $Password,
  "--database", $Database
)

& $python @args

Write-Host "Exported: $OutputCsv"
