-- MySQL 추출 템플릿
-- 목적: 필요한 컬럼/행만 뽑아서 로컬에서 CSV로 쓰기 위한 쿼리

-- 예시 1) 전체
-- SELECT * FROM your_table;

-- 예시 2) 기간 필터
-- SELECT
--   col1,
--   col2,
--   created_at
-- FROM your_table
-- WHERE created_at >= '2025-01-01'
--   AND created_at <  '2026-01-01';

-- 예시 3) 조인
-- SELECT a.*, b.some_feature
-- FROM table_a a
-- JOIN table_b b ON b.id = a.b_id;
