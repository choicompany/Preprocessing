# Preprocessing

CSV 데이터를 MySQL에 적재하고 pandas로 전처리하는 워크플로우입니다.

## 팀원 세팅 가이드

### 1. 저장소 클론
```bash
git clone https://github.com/choicompany/Preprocessing.git
cd Preprocessing
```

### 2. Python 라이브러리 설치
```powershell
pip install -r requirements.txt
```

### 3. MySQL 환경변수 설정
PowerShell에서 아래처럼 설정하세요(본인 환경에 맞게):
```powershell
$env:MYSQL_HOSTNAME = "127.0.0.1"
$env:MYSQL_PORT = "3306"
$env:MYSQL_USER = "admin"
$env:MYSQL_PASSWORD = "본인_비밀번호"
$env:MYSQL_DATABASE = "preprocessing"
```

### 4. 원본 CSV 적재
팀장이 공유한 CSV를 `data/raw/`에 넣고:
```powershell
./scripts/import_mysql.ps1 -CsvPath "data/raw/match_info.csv" -TableName "match_info"
./scripts/import_mysql.ps1 -CsvPath "data/raw/raw_data.csv" -TableName "raw_data"
```

### 5. SQL로 필요한 데이터만 추출
`scripts/sql/extract_mysql.sql`에 SELECT 쿼리 작성 후:
```powershell
./scripts/export_mysql.ps1 -QueryFile "scripts/sql/extract_mysql.sql" -OutputCsv "data/raw/filtered.csv"
```

### 6. 전처리 실행
```powershell
./scripts/run_preprocess.ps1 -InputPath "data/raw/filtered.csv" -OutputPath "data/processed/filtered_cleaned.csv"
```

## 폴더 구조
- `data/raw/` : 원본 CSV (Git 제외, 로컬/MySQL에만 존재)
- `data/processed/` : 전처리 결과
- `src/preprocess.py` : 전처리 로직(결측치/인코딩 등)
- `scripts/` : 실행 스크립트
- `outputs/` : 로그/리포트(Git 제외)

## 주의사항
- **비밀번호**는 절대 Git에 커밋하지 마세요(환경변수만 사용)
- 원본 CSV는 로컬에만 두고, 전처리 코드만 Git으로 공유합니다
- 전처리 규칙 변경 시 PR로 리뷰 후 머지하세요

