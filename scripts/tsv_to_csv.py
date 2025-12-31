from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="TSV를 CSV로 변환")
    parser.add_argument("--input", required=True, help="입력 TSV 경로")
    parser.add_argument("--output", required=True, help="출력 CSV 경로")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(input_path, sep="\t")
    df.to_csv(output_path, index=False)


if __name__ == "__main__":
    main()
