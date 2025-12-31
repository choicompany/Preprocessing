from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MySQL 쿼리를 실행해서 CSV로 저장")
    parser.add_argument("--query-file", required=True, help="실행할 .sql 파일 경로")
    parser.add_argument("--output", required=True, help="출력 CSV 경로")
    parser.add_argument("--hostname", required=True, help="MySQL 호스트")
    parser.add_argument("--port", type=int, default=3306, help="MySQL 포트")
    parser.add_argument("--user", required=True, help="MySQL 사용자")
    parser.add_argument("--password", required=True, help="MySQL 비밀번호")
    parser.add_argument("--database", required=True, help="대상 DB명")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    query_path = Path(args.query_file)
    output_path = Path(args.output)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    # SQLAlchemy 엔진
    conn_str = f"mysql+pymysql://{args.user}:{args.password}@{args.hostname}:{args.port}/{args.database}?charset=utf8mb4"
    engine = create_engine(conn_str)

    # 쿼리 실행
    query = query_path.read_text(encoding="utf-8")
    df = pd.read_sql(text(query), con=engine)

    # CSV 저장
    df.to_csv(output_path, index=False)
    print(f"✓ {len(df)} rows exported to {output_path}")


if __name__ == "__main__":
    main()
