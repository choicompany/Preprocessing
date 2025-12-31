param(
  [Parameter(Mandatory=$true)]
  [string]$CsvPath,

  [Parameter(Mandatory=$true)]
  [string]$TableName,

  [string]$Database = $env:MYSQL_DATABASE,
  [string]$Host = $env:MYSQL_HOST,
  [int]$Port = $(if ($env:MYSQL_PORT) { [int]$env:MYSQL_PORT } else { 3306 }),
  [string]$User = $env:MYSQL_USER,
  [string]$Password = $env:MYSQL_PASSWORD,

  [string]$Encoding = "utf-8",
  [string]$LinesTerminatedBy = "\n",

  [string]$SqlOut = "outputs/load_${TableName}.sql"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $CsvPath)) { throw "CsvPath not found: $CsvPath" }
if (-not $Host) { throw "MYSQL_HOST is required (or -Host)" }
if (-not $User) { throw "MYSQL_USER is required (or -User)" }
if (-not $Database) { throw "MYSQL_DATABASE is required (or -Database)" }

# 비밀번호는 커맨드라인에 남기지 않도록 환경변수로만 전달
if ($Password) {
  $env:MYSQL_PWD = $Password
}

$python = "python"
& $python "scripts/generate_mysql_load_sql.py" --csv $CsvPath --table $TableName --database $Database --out $SqlOut --encoding $Encoding --lines-terminated-by $LinesTerminatedBy

$mysqlArgs = @(
  "--host=$Host",
  "--port=$Port",
  "--user=$User",
  "--database=$Database",
  "--default-character-set=utf8mb4",
  "--local-infile=1"
)

Get-Content -Raw -Path $SqlOut | mysql @mysqlArgs

Write-Host "Loaded CSV into $Database.$TableName"
Write-Host "SQL used: $SqlOut"
