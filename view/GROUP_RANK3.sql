/**********************************
 グループステージの順位付け　STEP3
 FIFAランク
**********************************/

DROP VIEW IF EXISTS GROUP_RANK3;

CREATE VIEW GROUP_RANK3 AS
WITH
GRMT AS ( --GROUP_RANK2から情報採取
    SELECT *
    FROM GROUP_RANK2
    )
SELECT
    GRMT.group_id AS group_id,
    RANK() OVER (
        PARTITION BY GRMT.group_id
        ORDER BY
            GRMT.rank ASC,
            GRMT.fifarank ASC) AS rank,
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
