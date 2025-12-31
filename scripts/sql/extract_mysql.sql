-- 실제 사용 예시: raw_data + match_info 조인
-- raw_data에서 match 정보를 붙여서 분석용 데이터 생성

SELECT 
  r.*,
  m.season_name,
  m.competition_name,
  m.game_date,
  m.home_team_name_ko,
  m.away_team_name_ko,
  m.home_score,
  m.away_score
FROM raw_data r
LEFT JOIN match_info m ON r.game_id = m.game_id
WHERE 1=1
  -- 필요하면 필터 추가 (예: 특정 시즌, 특정 팀만)
  -- AND m.season_name = '2024'
  -- AND r.team_name_ko = '울산 HD FC'
  -- AND r.type_name IN ('패스', '슛')
LIMIT 100000;  -- 테스트용 제한, 실제론 제거하거나 늘리기

