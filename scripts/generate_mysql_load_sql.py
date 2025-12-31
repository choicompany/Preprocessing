from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


_IDENTIFIER_RE = re.compile(r"[^0-9a-zA-Z_]")


def sanitize_identifier(name: str) -> str:
    n = name.strip()
    n = n.replace(" ", "_")
    n = _IDENTIFIER_RE.sub("_", n)
    n = re.sub(r"_+", "_", n).strip("_")
    if not n:
        n = "col"
    if n[0].isdigit():
        n = f"c_{n}"
    return n.lower()


def read_header(csv_path: Path, encoding: str) -> list[str]:
    with csv_path.open("r", encoding=encoding, newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
    return [str(h) for h in header]


def main() -> None:
    parser = argparse.ArgumentParser(description="CSV 헤더로 MySQL CREATE TABLE + LOAD DATA SQL 생성")
    parser.add_argument("--csv", required=True, help="입력 CSV 경로")
    parser.add_argument("--table", required=True, help="대상 테이블명")
    parser.add_argument("--database", required=True, help="대상 DB명")
    parser.add_argument("--out", required=True, help="생성할 .sql 파일 경로")
    parser.add_argument("--encoding", default="utf-8", help="CSV 인코딩(기본 utf-8)")
    parser.add_argument(
        "--lines-terminated-by",
        default="\\n",
        help="라인 종료 문자(기본 \\n, 윈도우 CRLF면 \\r\\n 권장)",
    )
    args = parser.parse_args()

    csv_path = Path(args.csv).resolve()
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    raw_header = read_header(csv_path, encoding=args.encoding)
    cols = [sanitize_identifier(c) for c in raw_header]

    # 중복 컬럼명 방지
    seen: dict[str, int] = {}
    unique_cols: list[str] = []
    for c in cols:
        if c not in seen:
            seen[c] = 1
            unique_cols.append(c)
        else:
            seen[c] += 1
            unique_cols.append(f"{c}_{seen[c]}")

    col_defs = ",\n  ".join([f"`{c}` TEXT NULL" for c in unique_cols])

    # MySQL LOAD DATA LOCAL INFILE
    # - local-infile=1 옵션이 mysql 클라이언트에서 필요
    # - OPTIONALLY ENCLOSED BY '"' 로 일반 CSV 처리
    # - ESCAPED BY '\\' 는 기본값이긴 하나 명시
    lines_term = args.lines_terminated_by

    sql = f"""-- Auto-generated. Do not edit by hand.
-- Source CSV: {csv_path.as_posix()}

CREATE DATABASE IF NOT EXISTS `{args.database}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `{args.database}`;

CREATE TABLE IF NOT EXISTS `{args.table}` (
  {col_defs}
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE '{csv_path.as_posix()}'
INTO TABLE `{args.table}`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\\\'
LINES TERMINATED BY '{lines_term}'
IGNORE 1 LINES;
"""

    out_path.write_text(sql, encoding="utf-8")


if __name__ == "__main__":
    main()
