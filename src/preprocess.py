from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import pandas as pd


@dataclass
class PreprocessReport:
    input_path: str
    output_path: str
    rows_in: int
    cols_in: int
    rows_out: int
    cols_out: int
    columns: list[str]
    dtypes: dict[str, str]
    missing_by_col: dict[str, int]
    created_at: str


def normalize_column_names(columns: list[str]) -> list[str]:
    # 최소한의 정규화: 양끝 공백 제거 + 내부 공백을 '_'로
    normalized: list[str] = []
    for col in columns:
        col2 = str(col).strip().replace(" ", "_")
        normalized.append(col2)
    return normalized


def apply_transforms(df: pd.DataFrame) -> pd.DataFrame:
    """도메인 전처리는 여기에 추가.

    현재는 안전한 기본 처리만 수행:
    - 문자열 컬럼 양끝 공백 제거
    """
    out = df.copy()

    # object/string 컬럼 trim
    for col in out.columns:
        if pd.api.types.is_object_dtype(out[col]) or pd.api.types.is_string_dtype(out[col]):
            out[col] = out[col].astype("string").str.strip()

    return out


def build_report(input_path: Path, output_path: Path, before: pd.DataFrame, after: pd.DataFrame) -> PreprocessReport:
    missing = {c: int(after[c].isna().sum()) for c in after.columns}
    dtypes = {c: str(after[c].dtype) for c in after.columns}
    return PreprocessReport(
        input_path=str(input_path.as_posix()),
        output_path=str(output_path.as_posix()),
        rows_in=int(before.shape[0]),
        cols_in=int(before.shape[1]),
        rows_out=int(after.shape[0]),
        cols_out=int(after.shape[1]),
        columns=[str(c) for c in after.columns.tolist()],
        dtypes=dtypes,
        missing_by_col=missing,
        created_at=datetime.now().isoformat(timespec="seconds"),
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="CSV 전처리(최소 템플릿)")
    parser.add_argument("--input", required=True, help="입력 CSV 경로")
    parser.add_argument("--output", required=True, help="출력 CSV 경로")
    parser.add_argument("--encoding", default=None, help="CSV 인코딩(예: utf-8, cp949). 미지정 시 pandas 기본")
    parser.add_argument("--report", default="outputs/report.json", help="리포트 JSON 경로")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)
    report_path = Path(args.report)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.parent.mkdir(parents=True, exist_ok=True)

    before = pd.read_csv(input_path, encoding=args.encoding)

    # 컬럼명 정리
    before.columns = normalize_column_names([str(c) for c in before.columns.tolist()])

    after = apply_transforms(before)

    after.to_csv(output_path, index=False)

    report = build_report(input_path, output_path, before, after)
    report_path.write_text(json.dumps(asdict(report), ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
