/**********************************
 グループステージの順位付け　STEP1
 グループ内の勝点
**********************************/

DROP VIEW GROUP_RANK0;

CREATE VIEW GROUP_RANK0 AS
WITH
GRMT_FIL AS ( --グループステージの結果を抽出
    SELECT MATCHES.match_id, MATCH_TEAM.team_id, MATCH_TEAM.score, MATCH_TEAM.conduct_score
    FROM MATCHES
    JOIN MATCH_TEAM USING (match_id)
    WHERE MATCHES.match_kbn = '1'
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
        SUM(HOME.conduct_score) AS conduct_score
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
        GRMT_SUM.played AS played,
        GRMT_SUM.win AS win,
        GRMT_SUM.draw AS draw,
        GRMT_SUM.loss AS loss,
        GRMT_SUM.goal_scored AS goal_scored,
        GRMT_SUM.goal_allowed AS goal_allowed,
        GRMT_SUM.goal_scored - GRMT_SUM.goal_allowed AS goal_difference,
        GRMT_SUM.conduct_score AS conduct_score,
        (GRMT_SUM.win * 3) + (GRMT_SUM.draw * 1) AS points
    FROM GRMT_SUM
    ),
GRMT AS (
    SELECT
        GROUPSTAGE.group_id AS group_id,
        GRMT_CAL.team_id AS team_id,
        GRMT_CAL.played AS played,
        GRMT_CAL.win AS win,
        GRMT_CAL.draw AS draw,
        GRMT_CAL.loss AS loss,
        GRMT_CAL.goal_scored AS goal_scored,
        GRMT_CAL.goal_allowed AS goal_allowed,
        GRMT_CAL.goal_scored - GRMT_CAL.goal_allowed AS goal_difference,
        GRMT_CAL.conduct_score AS conduct_score,
        GRMT_CAL.points AS points,
        FIFARANK.fifarank AS fifarank
    FROM GRMT_CAL, GROUPSTAGE, TEAM, FIFARANK
    WHERE
        GRMT_CAL.team_id = TEAM.team_id AND
        TEAM.group_id = GROUPSTAGE.group_id AND
        GRMT_CAL.team_id = FIFARANK.team_id
    )
SELECT
    GRMT.group_id AS group_id,
    RANK() OVER (PARTITION BY GRMT.group_id ORDER BY GRMT.points DESC) AS rank,
    GRMT.team_id AS team_id,
    GRMT.played AS played,
    GRMT.win AS win,
    GRMT.draw AS draw,
    GRMT.loss AS loss,
    GRMT.goal_scored AS goal_scored,
    GRMT.goal_allowed AS goal_allowed,
    GRMT.goal_difference AS goal_difference,
    GRMT.conduct_score AS conduct_score,
    GRMT.points AS points,
    GRMT.fifarank AS fifarank
FROM GRMT
;
