# scripts/sql

여기는 SQL에서 데이터를 추출/적재할 때 쓰는 쿼리 템플릿을 두는 곳입니다.

## 추출 흐름(권장)
1. 필요한 컬럼/필터를 `extract.sql`에 작성
2. DB 클라이언트로 CSV로 export
3. export한 CSV를 `data/raw/`에 저장(로컬)
4. `scripts/run_preprocess.ps1`로 전처리 실행

## 어떤 DB인지 알려주면 더 딱 맞게 만들어드릴 수 있어요
- PostgreSQL: `\copy (...) to 'file.csv' csv header`
- SQL Server: `sqlcmd` + 쿼리 출력 / 또는 `bcp`
- MySQL: `SELECT ... INTO OUTFILE ...`

원하시면 현재 쓰는 DB 종류(Postgres/MSSQL/MySQL/SQLite)와 접속 방식(로컬/클라우드)을 알려주시면
바로 실행 가능한 export 스크립트(PS1)까지 맞춰드릴게요.
