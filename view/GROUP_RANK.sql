/**********************************
 グループステージの順位付け
**********************************/

DROP VIEW IF EXISTS GROUP_RANK;

CREATE VIEW GROUP_RANK AS
SELECT
    GROUPSTAGE.group_name AS グループ,
    GROUP_RANK3.rank AS 順位,
    CASE
        WHEN GROUP_RANK3.rank < 3 THEN '突破'
        WHEN EIGHT_OF_THIRD.rank < 9 THEN '突破'
        ELSE '敗退'
    END AS 結果,
    TEAM.team_name AS 'チーム',
    GROUP_RANK3.played AS '試合数',
    GROUP_RANK3.win AS '勝',
    GROUP_RANK3.draw AS '分',
    GROUP_RANK3.loss AS '負',
    GROUP_RANK3.goal_scored AS '総得点',
    GROUP_RANK3.goal_allowed AS '総失点',
    GROUP_RANK3.goal_difference AS '得失点差',
    GROUP_RANK3.conduct_score AS 'TCS',
    GROUP_RANK3.points AS '勝ち点',
    GROUP_RANK3.fifarank AS 'FIFAランク',
    EIGHT_OF_THIRD.rank AS '3位チーム順位'
FROM GROUP_RANK3
LEFT OUTER JOIN GROUPSTAGE USING (group_id)
LEFT OUTER JOIN EIGHT_OF_THIRD USING (team_id)
LEFT OUTER JOIN TEAM USING (team_id)
;
