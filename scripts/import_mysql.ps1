param(
  [Parameter(Mandatory=$true)]
  [string]$CsvPath,

  [Parameter(Mandatory=$true)]
  [string]$TableName,

  [string]$Database = $env:MYSQL_DATABASE,
  [string]$Hostname = $env:MYSQL_HOSTNAME,
  [int]$Port = $(if ($env:MYSQL_PORT) { [int]$env:MYSQL_PORT } else { 3306 }),
  [string]$User = $env:MYSQL_USER,
  [string]$Password = $env:MYSQL_PASSWORD,

  [string]$Encoding = "utf-8",
  [string]$LinesTerminatedBy = "\n",

  [string]$SqlOut = "outputs/load_${TableName}.sql"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $CsvPath)) { throw "CsvPath not found: $CsvPath" }
if (-not $Hostname) { throw "MYSQL_HOSTNAME is required (or -Hostname)" }
if (-not $User) { throw "MYSQL_USER is required (or -User)" }
if (-not $Database) { throw "MYSQL_DATABASE is required (or -Database)" }

$python = "py"
$args = @(
  "scripts/import_mysql_pandas.py",
  "--csv", $CsvPath,
  "--table", $TableName,
  "--database", $Database,
  "--hostname", $Hostname,
  "--port", $Port,
  "--user", $User,
  "--password", $Password,
  "--encoding", $Encoding
)

if ($LinesTerminatedBy) {
  # pandas 방식에서는 LinesTerminatedBy 불필요 (자동 처리)
}

& $python @args

Write-Host "Loaded CSV into $Database.$TableName"
