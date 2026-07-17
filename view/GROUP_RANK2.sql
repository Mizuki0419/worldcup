/**********************************
 グループステージの順位付け　STEP2
 グループ内の得失点差
 グループ内の最高得点
 規律ポイント
 ※繰り返さない
**********************************/

DROP VIEW IF EXISTS GROUP_RANK2;

CREATE VIEW GROUP_RANK2 AS
WITH
GRMT_FIL AS ( --グループステージの結果を抽出
    SELECT MATCHES.match_id, MATCH_TEAM.team_id, MATCH_TEAM.score
    FROM MATCHES
    JOIN MATCH_TEAM USING (match_id)
    WHERE MATCHES.match_kbn = '1'
    ),
GRMT_SUM AS ( --チームごとの試合結果等を集計
    SELECT
        HOME.team_id AS team_id,
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
GRMT_CAL AS ( --GROUP_RANK1から情報採取
    SELECT
    	GROUP_RANK1.group_id,
        GROUP_RANK1.rank,
        GROUP_RANK1.team_id,
        GROUP_RANK1.played,
        GROUP_RANK1.win,
        GROUP_RANK1.draw,
        GROUP_RANK1.loss,
        GROUP_RANK1.goal_scored,
        GROUP_RANK1.goal_allowed,
        GROUP_RANK1.goal_difference,
        GROUP_RANK1.conduct_score,
        GROUP_RANK1.points,
        GROUP_RANK1.fifarank,
        GRMT_SUM.max_scored AS max_scored
    FROM GROUP_RANK1
    JOIN GRMT_SUM USING (team_id)
    ),
GRMT AS (
    SELECT
        *
    FROM GRMT_CAL
    )
SELECT
    GRMT.group_id AS group_id,
    RANK() OVER (
        PARTITION BY GRMT.group_id
        ORDER BY
            GRMT.rank ASC,
            GRMT.goal_difference DESC,
            GRMT.max_scored DESC,
            GRMT.conduct_score DESC) AS rank,
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
