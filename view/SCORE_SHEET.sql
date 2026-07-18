/**********************************
 星取表
**********************************/

DROP VIEW IF EXISTS SCORE_SHEET;

CREATE VIEW SCORE_SHEET AS
WITH
GRMT_FIL AS ( --グループステージの結果を抽出
    SELECT MATCHES.match_id, MATCH_TEAM.team_id, MATCH_TEAM.score
    FROM MATCHES
    JOIN MATCH_TEAM USING (match_id)
    WHERE MATCHES.match_kbn = '1'
    ),
GRMT_JOIN AS ( --チームごとの試合結果を抽出（縦持ちかつ双方向）
    SELECT
        HOME.team_id AS team_id,
        AWAY.team_id AS team_id_away,
        HOME.score || '-' || AWAY.score AS result
    FROM
        GRMT_FIL AS HOME
    INNER JOIN
        GRMT_FIL AS AWAY
        ON HOME.match_id = AWAY.match_id
        AND HOME.team_id != AWAY.team_id
    GROUP BY
        HOME.match_id, HOME.team_id
    ),
GRRANK AS ( --グループごとの順位を抽出
    SELECT
        GROUP_RANK3.group_id,
        GROUP_RANK3.rank,
        GROUP_RANK3.team_id
    FROM GROUP_RANK3
    ),
FIELD AS ( --グループごとの横軸を設定
    SELECT
        GRRANK.group_id AS group_id,
        NULL AS rank,
        NULL AS team_id,
        MAX(CASE WHEN GRRANK.rank = 1 THEN GRR1.team_id ELSE 0 END) AS r1,
        MAX(CASE WHEN GRRANK.rank = 2 THEN GRR2.team_id ELSE 0 END) AS r2,
        MAX(CASE WHEN GRRANK.rank = 3 THEN GRR3.team_id ELSE 0 END) AS r3,
        MAX(CASE WHEN GRRANK.rank = 4 THEN GRR4.team_id ELSE 0 END) AS r4,
        '1' AS rkbn
    FROM GRRANK
    JOIN (SELECT * FROM GRRANK WHERE rank = 1) GRR1 USING (group_id)
    JOIN (SELECT * FROM GRRANK WHERE rank = 2) GRR2 USING (group_id)
    JOIN (SELECT * FROM GRRANK WHERE rank = 3) GRR3 USING (group_id)
    JOIN (SELECT * FROM GRRANK WHERE rank = 4) GRR4 USING (group_id)
    GROUP BY GRRANK.group_id
    )
SELECT * FROM FIELD
UNION ALL
SELECT
    GRRANK.group_id AS group_id,
    GRRANK.rank,
    GRRANK.team_id AS team_id,
    MAX(CASE WHEN GRMT_JOIN.team_id_away = FIELD.r1 THEN GRMT_JOIN.result ELSE '-' END) AS r1,
    MAX(CASE WHEN GRMT_JOIN.team_id_away = FIELD.r2 THEN GRMT_JOIN.result ELSE '-' END) AS r2,
    MAX(CASE WHEN GRMT_JOIN.team_id_away = FIELD.r3 THEN GRMT_JOIN.result ELSE '-' END) AS r3,
    MAX(CASE WHEN GRMT_JOIN.team_id_away = FIELD.r4 THEN GRMT_JOIN.result ELSE '-' END) AS r4,
    '2' AS rkbn
FROM GRRANK
JOIN FIELD USING (group_id)
LEFT OUTER JOIN GRMT_JOIN USING (team_id)
GROUP BY GRRANK.team_id
;
