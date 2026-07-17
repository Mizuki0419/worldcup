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
GRMT_JOIN AS ( --チームごとの試合結果を1カラムに結合
    SELECT
        HOME.team_id AS team_id,
        AWAY.team_id AS team_id_away,
        CONCAT(HOME.score, '-', AWAY.score) AS result
    FROM
        GRMT_FIL AS HOME
    INNER JOIN
        GRMT_FIL AS AWAY
        ON HOME.match_id = AWAY.match_id
        AND HOME.team_id != AWAY.team_id
    GROUP BY
        HOME.team_id
    ),
GRRANK AS ( --
    SELECT
        GROUP_RANK3.group_id
        GROUP_RANK3.rank
        GROUP_RANK3.team_id
        CASE WHEN GROUP_RANK3.rank = 1 THEN result ELSE '-' END) AS A,
        MAX(CASE WHEN team2 = 'B' THEN result ELSE '-' END) AS B,
        MAX(CASE WHEN team2 = 'C' THEN result ELSE '-' END) AS C
    FROM GROUP_RANK3
    JOIN TEAM USING (team_id)
    GROUP BY GRMT_JOIN.team_id
    ORDER BY group_id, GROUP_RANK3.rank

SELECT
    GRMT_JOIN.team_id AS team_id,
    MAX(CASE WHEN GRMT_JOIN.team_id_away = 'A' THEN GRMT_JOIN.result ELSE '-' END) AS A,
    MAX(CASE WHEN team2 = 'B' THEN result ELSE '-' END) AS B,
    MAX(CASE WHEN team2 = 'C' THEN result ELSE '-' END) AS C
FROM GRMT_JOIN
GROUP BY GRMT_JOIN.team_id
ORDER BY GRMT_JOIN.team_id







SELECT
    MAX(TEAM.group_id) AS group_id,
    MAX(GROUP_RANK3.rank) AS rank,
    GRMT_JOIN.team_id AS team_id,
    MAX(CASE WHEN team2 = 'A' THEN result ELSE '-' END) AS A,
    MAX(CASE WHEN team2 = 'B' THEN result ELSE '-' END) AS B,
    MAX(CASE WHEN team2 = 'C' THEN result ELSE '-' END) AS C
FROM GRMT_JOIN
JOIN TEAM USING (team_id)
GROUP BY GRMT_JOIN.team_id
ORDER BY group_id, GROUP_RANK3.rank
;
