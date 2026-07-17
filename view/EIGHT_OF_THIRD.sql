/**********************************
 各グループ3位の中の順位付け
 全グループステージで獲得した勝点
 全試合での得失点差
 全試合での総得点
 規律ポイント
 FIFAランク
**********************************/

DROP VIEW IF EXISTS EIGHT_OF_THIRD;

CREATE VIEW EIGHT_OF_THIRD AS
SELECT
    GROUP_RANK3.group_id AS group_id,
    RANK() OVER (
        ORDER BY
            GROUP_RANK3.points DESC,
            GROUP_RANK3.goal_difference DESC,
            GROUP_RANK3.goal_scored DESC,
            GROUP_RANK3.conduct_score DESC,
            GROUP_RANK3.fifarank ASC) AS rank,
    GROUP_RANK3.team_id AS team_id,
    GROUP_RANK3.played AS played,
    GROUP_RANK3.win AS win,
    GROUP_RANK3.draw AS draw,
    GROUP_RANK3.loss AS loss,
    GROUP_RANK3.goal_scored AS goal_scored,
    GROUP_RANK3.goal_allowed AS goal_allowed,
    GROUP_RANK3.goal_difference AS goal_difference,
    GROUP_RANK3.conduct_score AS conduct_score,
    GROUP_RANK3.points AS points,
    GROUP_RANK3.fifarank AS fifarank
FROM GROUP_RANK3
WHERE GROUP_RANK3.rank = 3
;
