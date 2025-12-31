from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="CSV를 MySQL에 pandas로 적재")
    parser.add_argument("--csv", required=True, help="입력 CSV 경로")
    parser.add_argument("--table", required=True, help="대상 테이블명")
    parser.add_argument("--database", required=True, help="대상 DB명")
    parser.add_argument("--hostname", required=True, help="MySQL 호스트")
    parser.add_argument("--port", type=int, default=3306, help="MySQL 포트")
    parser.add_argument("--user", required=True, help="MySQL 사용자")
    parser.add_argument("--password", required=True, help="MySQL 비밀번호")
    parser.add_argument("--encoding", default="utf-8", help="CSV 인코딩")
    parser.add_argument("--if-exists", default="replace", choices=["fail", "replace", "append"], help="테이블이 이미 있을 때 동작")
    parser.add_argument("--chunksize", type=int, default=10000, help="한 번에 넣을 행 수(메모리 절약)")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    csv_path = Path(args.csv)

    # SQLAlchemy 엔진 생성
    conn_str = f"mysql+pymysql://{args.user}:{args.password}@{args.hostname}:{args.port}/{args.database}?charset=utf8mb4"
    engine = create_engine(conn_str)

    # DB 생성(없으면)
    with engine.connect() as conn:
        conn.execute(text(f"CREATE DATABASE IF NOT EXISTS `{args.database}` DEFAULT CHARACTER SET utf8mb4"))
        conn.execute(text(f"USE `{args.database}`"))
        conn.commit()

    # CSV 읽기 + 적재
    df = pd.read_csv(csv_path, encoding=args.encoding)
    df.to_sql(args.table, con=engine, if_exists=args.if_exists, index=False, chunksize=args.chunksize)

    print(f"✓ {len(df)} rows loaded into {args.database}.{args.table}")


if __name__ == "__main__":
    main()
