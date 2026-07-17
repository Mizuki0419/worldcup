/**********************************
 グループステージの順位付け　STEP2
 グループ内の得失点差
 グループ内の最高得点
 規律ポイント
 ※繰り返さない
**********************************/

DROP VIEW GROUP_RANK2;

CREATE VIEW GROUP_RANK2 AS 
WITH
GRMT_FIL AS ( --グループステージの結果を抽出
    SELECT MATCHES.match_id, MATCH_TEAM.team_id, MATCH_TEAM.score, MATCH_TEAM.conduct_score
    FROM MATCHES
    JOIN MATCH_TEAM USING (match_id)
    WHERE MATCHES.match_kbn = '1'
/**********************************
    --GROUP_RANK1でグループ内のrankがかぶってる奴だけの条件かく
**********************************/
    ),
GRMT_SUM AS ( --チームごとの試合結果等を集計
    SELECT
        HOME.team_id AS team_id,
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
        GRMT_SUM.goal_scored - GRMT_SUM.goal_allowed AS goal_difference,
        GRMT_SUM.max_scored AS max_scored
    FROM GRMT_SUM
    ),
GRMT AS (
    SELECT
        GRMT_CAL.team_id AS team_id,
        GRMT_CAL.goal_difference AS goal_difference,
        GRMT_CAL.max_scored AS max_scored
    FROM GRMT_CAL
    )
SELECT
    RANK() OVER (ORDER BY GRMT.goal_difference DESC,GRMT.max_scored DESC) AS rank,
    GRMT.team_id AS team_id
FROM GRMT

UNION ALL

;
