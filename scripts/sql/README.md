# scripts/sql

여기는 SQL에서 데이터를 추출/적재할 때 쓰는 쿼리 템플릿을 두는 곳입니다.

## 추출 흐름(권장)
1. 필요한 컬럼/필터를 `extract_mysql.sql`에 작성
2. PowerShell로 로컬 CSV 추출(아래 예시)
3. 추출된 CSV를 `data/raw/`에 저장(로컬)
4. `scripts/run_preprocess.ps1`로 전처리 실행

## 적재 흐름(옵션): 로컬 MySQL에 CSV 넣기
큰 CSV를 Git에 두기 싫으면, 로컬/서버 MySQL에 적재해두고 필요할 때 SQL로 뽑는 방식도 많이 씁니다.

```powershell
$env:MYSQL_HOST = "127.0.0.1"
$env:MYSQL_USER = "admin"  # 예시
$env:MYSQL_PASSWORD = "***" # 환경변수로만 두세요(커밋/스크립트에 하드코딩 금지)
$env:MYSQL_DATABASE = "preprocessing"

./scripts/import_mysql.ps1 -CsvPath "data/raw/match_info.csv" -TableName "match_info"
./scripts/import_mysql.ps1 -CsvPath "data/raw/raw_data.csv"  -TableName "raw_data" -LinesTerminatedBy "\r\n"
```

### MySQL 로컬 CSV 추출 예시

1) 환경변수 세팅(비밀번호는 커맨드 히스토리에 남지 않게 환경변수 권장)

```powershell
$env:MYSQL_HOST = "127.0.0.1"
$env:MYSQL_PORT = "3306"
$env:MYSQL_USER = "root"
$env:MYSQL_PASSWORD = "your_password"
$env:MYSQL_DATABASE = "your_db"
```

2) 쿼리 실행 → TSV 추출 → CSV 변환

```powershell
./scripts/export_mysql.ps1 -QueryFile "scripts/sql/extract_mysql.sql" -OutputCsv "data/raw/from_mysql.csv"
```

## 어떤 DB인지 알려주면 더 딱 맞게 만들어드릴 수 있어요
- PostgreSQL: `\copy (...) to 'file.csv' csv header`
- SQL Server: `sqlcmd` + 쿼리 출력 / 또는 `bcp`
- MySQL: `SELECT ... INTO OUTFILE ...`

원하시면 현재 쓰는 DB 종류(Postgres/MSSQL/MySQL/SQLite)와 접속 방식(로컬/클라우드)을 알려주시면
바로 실행 가능한 export 스크립트(PS1)까지 맞춰드릴게요.
