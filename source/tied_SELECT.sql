WITH
GRMT_FIL AS ( --グループステージの結果を抽出
    SELECT MATCHES.match_id, MATCH_TEAM.team_id, MATCH_TEAM.score, MATCH_TEAM.conduct_score
    FROM MATCHES
    JOIN MATCH_TEAM USING (match_id)
    WHERE MATCHES.match_kbn = '1'
    AND MATCH_TEAM.team_id IN({tiedin})
    ),
GRMT_SUM AS ( --チームごとの試合結果等を集計
    SELECT
        HOME.team_id AS team_id,
        COUNT(HOME.team_id) AS played,
        SUM(CASE WHEN HOME.score > AWAY.score THEN 1 ELSE 0 END) AS win,
        SUM(CASE WHEN HOME.score = AWAY.score THEN 1 ELSE 0 END) AS draw,
        SUM(CASE WHEN HOME.score < AWAY.score THEN 1 ELSE 0 END) AS loss,
        SUM(HOME.score) AS goal_scored,
        SUM(AWAY.score) AS goal_allowed,
        MAX(HOME.score) AS max_scored
    FROM
        GRMT_FIL AS HOME
    INNER JOIN
        GRMT_FIL AS AWAY
        ON HOME.match_id = AWAY.match_id
        AND HOME.team_id != AWAY.team_id
    GROUP BY
        HOME.team_id
    ),
GRMT_CAL AS ( --チームごとの成績を算出
    SELECT
        GRMT_SUM.team_id AS team_id,
        (GRMT_SUM.win * 3) + (GRMT_SUM.draw * 1) AS points,
        GRMT_SUM.goal_scored - GRMT_SUM.goal_allowed AS goal_difference,
        GRMT_SUM.max_scored AS max_scored
    FROM GRMT_SUM
    ),
GRMT AS (
    SELECT
        GRMT_CAL.team_id AS team_id,
        GRMT_CAL.points AS points,
        GRMT_CAL.goal_difference AS goal_difference,
        GRMT_CAL.max_scored AS max_scored
    FROM GRMT_CAL
    )
SELECT
    RANK() OVER (ORDER BY GRMT.points DESC,GRMT.goal_difference DESC,GRMT.max_scored DESC) AS rank,
    GRMT.team_id AS team_id
FROM GRMT
;
