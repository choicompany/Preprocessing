param(
  [Parameter(Mandatory=$true)]
  [string]$QueryFile,

  [Parameter(Mandatory=$true)]
  [string]$OutputCsv,

  [string]$TempTsv = "outputs/mysql_export.tsv",

  # 환경변수로 주는 걸 권장하지만, 필요하면 파라미터로도 받을 수 있게 둡니다.
  [string]$Host = $env:MYSQL_HOST,
  [int]$Port = $(if ($env:MYSQL_PORT) { [int]$env:MYSQL_PORT } else { 3306 }),
  [string]$User = $env:MYSQL_USER,
  [string]$Password = $env:MYSQL_PASSWORD,
  [string]$Database = $env:MYSQL_DATABASE,

  [string]$Charset = "utf8mb4"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $QueryFile)) {
  throw "QueryFile not found: $QueryFile"
}
if (-not $Host) { throw "MYSQL_HOST is required (or -Host)" }
if (-not $User) { throw "MYSQL_USER is required (or -User)" }
if (-not $Database) { throw "MYSQL_DATABASE is required (or -Database)" }

# 출력 경로 준비
$tsvPath = [System.IO.Path]::GetFullPath($TempTsv)
$csvPath = [System.IO.Path]::GetFullPath($OutputCsv)
New-Item -ItemType Directory -Force -Path ([System.IO.Path]::GetDirectoryName($tsvPath)) | Out-Null
New-Item -ItemType Directory -Force -Path ([System.IO.Path]::GetDirectoryName($csvPath)) | Out-Null

# mysql CLI는 MYSQL_PWD를 인식합니다(커맨드라인에 비번을 남기지 않기 위함)
if ($Password) {
  $env:MYSQL_PWD = $Password
}

$mysqlArgs = @(
  "--host=$Host",
  "--port=$Port",
  "--user=$User",
  "--database=$Database",
  "--default-character-set=$Charset",
  "--batch",
  "--raw",
  "--silent"
)

# QueryFile을 표준입력으로 넘기면 결과가 TSV(탭 구분)로 출력됩니다.
# (첫 줄에 컬럼명이 포함됩니다)
Get-Content -Raw -Path $QueryFile | mysql @mysqlArgs | Set-Content -Path $tsvPath -Encoding utf8

# TSV -> CSV 변환(로컬에서 pandas 사용)
$python = "python"
& $python "scripts/tsv_to_csv.py" --input $tsvPath --output $csvPath

Write-Host "Exported: $csvPath"
