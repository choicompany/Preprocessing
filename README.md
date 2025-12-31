# Preprocessing

이 저장소는 CSV 기반 데이터 전처리 작업을 재현 가능하게 관리하기 위한 최소 구조입니다.

## 폴더 구조
- `data/raw/` : 원본 CSV
- `data/processed/` : 전처리 결과 CSV
- `src/` : 전처리 코드
- `scripts/` : 실행 스크립트
- `outputs/` : 로그/리포트 등 산출물(기본 `.gitignore`로 제외)

## 빠른 시작
1. 원본 CSV를 `data/raw/`에 넣습니다.
2. PowerShell에서 아래 실행:

```powershell
./scripts/run_preprocess.ps1 -InputPath "data/raw/your.csv" -OutputPath "data/processed/your_processed.csv"
```

## MySQL에서 뽑아서 시작하기(권장)
1. `scripts/sql/extract_mysql.sql`에 필요한 SELECT 쿼리 작성
2. 환경변수 설정 후 추출:

```powershell
$env:MYSQL_HOST = "127.0.0.1"
$env:MYSQL_USER = "root"
$env:MYSQL_PASSWORD = "your_password"
$env:MYSQL_DATABASE = "your_db"
./scripts/export_mysql.ps1 -QueryFile "scripts/sql/extract_mysql.sql" -OutputCsv "data/raw/from_mysql.csv"
```

3. 추출된 CSV를 전처리:

```powershell
./scripts/run_preprocess.ps1 -InputPath "data/raw/from_mysql.csv" -OutputPath "data/processed/from_mysql_processed.csv"
```

## 전처리 정책
현재는 **안전한 기본값(컬럼명 정리, 공백 trim, 간단 요약 리포트 저장)**만 수행합니다.
도메인 규칙(결측치 대체/이상치 처리/인코딩 등)은 데이터 확인 후 `src/preprocess.py`의 `apply_transforms()`에 추가합니다.
