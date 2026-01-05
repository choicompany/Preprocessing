/* ============================================================================
   데이터 추출 쿼리 템플릿
   목적: MySQL에 적재된 원본 데이터에서 필요한 부분만 추출하여 CSV로 저장
   사용법: export_mysql.ps1 실행 시 이 SQL이 사용됨

   실행 명령어 예시:
   ./scripts/export_mysql.ps1 -QueryFile "scripts/sql/extract_mysql.sql" -OutputCsv "data/processed/결과파일.csv"
   ============================================================================
*/

/* ============================================================================
   [현재 예시] raw_data(이벤트 상세) + match_info(경기 정보) 조인
   raw_data: 각 경기의 모든 플레이 이벤트 (패스, 슛, 태클 등)
   match_info: 경기 메타 정보 (날짜, 팀명, 스코어 등)
   ============================================================================
*/

SELECT 
  /* raw_data의 모든 컬럼 */
  r.*,

  /* match_info에서 가져올 컬럼들 */
  m.season_name,           
  m.competition_name,      
  m.game_date,             
  m.home_team_name_ko,     
  m.away_team_name_ko,     
  m.home_score,            
  m.away_score             

FROM raw_data r
LEFT JOIN match_info m 
  ON r.game_id = m.game_id
  /* LEFT JOIN: raw_data의 모든 행을 유지하면서 경기 정보를 결합 */

/* ============================================================================
   WHERE 조건
   필요하면 아래 주석을 해제하고 원하는 조건만 활성화
   ============================================================================
*/
WHERE 1=1

  /* 예시 1) 특정 시즌 */
  -- AND m.season_name = '2024'

  /* 예시 2) 특정 팀 */
  -- AND r.team_name_ko = '울산 HD FC'

  /* 예시 3) 특정 이벤트 타입만 (패스 + 슛) */
  -- AND r.type_name IN ('패스', '슛')

  /* 예시 4) 특정 날짜 범위 */
  -- AND m.game_date >= '2024-03-01'
  -- AND m.game_date <  '2024-04-01'

  /* 예시 5) 득점 차이 3점 이상 경기 */
  -- AND ABS(m.home_score - m.away_score) >= 3

  /* 예시 6) 복합 조건 예시 */
  -- AND m.season_name = '2024'
  -- AND r.team_name_ko = '울산 HD FC'
  -- AND r.type_name = '패스'

/* ============================================================================
   LIMIT 설정
   테스트 시 LIMIT을 작게 두고 확인한 뒤 확장 권장
   ============================================================================
*/
LIMIT 100000;

/* ============================================================================
   팁
   1. 처음엔 LIMIT 1000 정도로 작게 결과 확인
   2. WHERE 조건을 충분히 활용하면 처리 속도 ↑
   3. 필요하면 GROUP BY / HAVING / JOIN 추가 가능
   4. 쿼리 변경 시 Git 커밋으로 팀과 공유
   ============================================================================
*/
SELECT rd.player_name_ko,
       rd.type_name,
       SUM(CASE 
               WHEN (mi.home_team_id = rd.team_id AND mi.home_score > mi.away_score) 
                    OR (mi.away_team_id = rd.team_id AND mi.away_score > mi.home_score) 
               THEN 1 
               ELSE 0 
           END) AS wins,
       COUNT(*) AS total_events,
       ROUND(SUM(CASE 
                     WHEN (mi.home_team_id = rd.team_id AND mi.home_score > mi.away_score) 
                          OR (mi.away_team_id = rd.team_id AND mi.away_score > mi.home_score) 
                     THEN 1 
                     ELSE 0 
                 END) / COUNT(*) * 100, 2) AS win_rate
FROM raw_data rd
JOIN match_info mi ON rd.game_id = mi.game_id
GROUP BY rd.player_name_ko, rd.type_name;
