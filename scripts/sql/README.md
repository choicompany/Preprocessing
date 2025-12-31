# SQL 스크립트

## 적재: CSV → MySQL
원본 CSV를 로컬 MySQL에 넣기:
```powershell
$env:MYSQL_HOSTNAME = "127.0.0.1"
$env:MYSQL_USER = "admin"
$env:MYSQL_PASSWORD = "본인_비밀번호"
$env:MYSQL_DATABASE = "preprocessing"

./scripts/import_mysql.ps1 -CsvPath "data/raw/match_info.csv" -TableName "match_info"
./scripts/import_mysql.ps1 -CsvPath "data/raw/raw_data.csv" -TableName "raw_data"
```

## 추출: MySQL → CSV
`extract_mysql.sql`에 필요한 SELECT 쿼리를 작성한 뒤:
```powershell
./scripts/export_mysql.ps1 -QueryFile "scripts/sql/extract_mysql.sql" -OutputCsv "data/raw/filtered.csv"
```

## 쿼리 템플릿 예시
[extract_mysql.sql](extract_mysql.sql) 참고

