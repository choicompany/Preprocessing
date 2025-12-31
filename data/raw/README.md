# data/raw

이 폴더에는 원본 데이터를 둡니다.

- 데이터가 크거나 민감하면 Git에 커밋하지 않는 것을 권장합니다.
- 대신 SQL(DB)이나 스토리지에 올려두고, `scripts/sql/*.sql` 같은 쿼리로 필요할 때 CSV로 추출하는 흐름을 씁니다.

현재 저장소는 `.gitignore`로 `data/raw/*`를 기본 제외합니다.
원본이 작아서 Git에 올리고 싶다면 `.gitignore`의 data/raw 규칙을 조정하세요.
