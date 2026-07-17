DROP VIEW IF EXISTS RESULTS_STATS;

CREATE VIEW RESULTS_STATS AS
WITH
MTA AS (
    SELECT match_id, score
    FROM (
        SELECT match_id, score, ROW_NUMBER() OVER (PARTITION BY match_id ORDER BY team_id) AS rn
        FROM MATCH_TEAM
        ) 
    WHERE rn = 1
    ),
MTB AS (
    SELECT match_id, score
    FROM (
        SELECT match_id, score, ROW_NUMBER() OVER (PARTITION BY match_id ORDER BY team_id) AS rn
        FROM MATCH_TEAM
        ) 
    WHERE rn = 2
    ),
ALM AS (
    SELECT COUNT(*) AS con
    FROM MATCHES
    )
SELECT
    PS.point_spread AS point_spread,
    COUNT(*) AS point_spread_number,
    ROUND((COUNT(*) * 1.0 / ALM.con) * 100, 2) AS per
FROM
    (
    SELECT ABS(MTA.score - MTB.score) AS point_spread
    FROM MTA
    JOIN MTB USING (match_id)
    ) PS
JOIN ALM
GROUP BY PS.point_spread
ORDER BY PS.point_spread
;