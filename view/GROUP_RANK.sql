/**********************************
 グループステージの順位付け
**********************************/

DROP VIEW IF EXISTS GROUP_RANK;

CREATE VIEW GROUP_RANK AS
SELECT
    "グループ",
    "順位",
    "結果",
    "チーム",
    "結果１",
    "結果２",
    "結果３",
    "結果４",
    "試合数",
    " 勝 ",
    " 分 ",
    " 負 ",
    "総得点",
    "総失点",
    "得失点差",
    "TCS",
    "勝ち点",
    "FIFAランク",
    "3位内順位"
FROM (
    SELECT
        GROUPSTAGE.group_name AS "グループ",
        '順位' AS "順位",
        '結果' AS "結果",
        'チーム' AS "チーム",
        SCORE_SHEET.r1 AS "結果１",
        SCORE_SHEET.r2 AS "結果２",
        SCORE_SHEET.r3 AS "結果３",
        SCORE_SHEET.r4 AS "結果４",
        '試合数' AS "試合数",
        '勝' AS " 勝 ",
        '分' AS " 分 ",
        '負' AS " 負 ",
        '総得点' AS "総得点",
        '総失点' AS "総失点",
        '得失点差' AS "得失点差",
        'TCS' AS "TCS",
        '勝ち点' AS "勝ち点",
        'FIFAランク' AS "FIFAランク",
        '3位内順位' AS "3位内順位",
        SCORE_SHEET.rkbn AS "rkbn"
    FROM SCORE_SHEET
    LEFT OUTER JOIN GROUPSTAGE USING (group_id)
    WHERE SCORE_SHEET.rkbn = '1'
    UNION ALL
    SELECT
        GROUPSTAGE.group_name AS "グループ",
        GROUP_RANK3.rank AS "順位",
        CASE
            WHEN GROUP_RANK3.rank < 3 THEN '突破'
            WHEN EIGHT_OF_THIRD.rank < 9 THEN '突破'
            ELSE '敗退'
        END AS "結果",
        TEAM.team_name AS "チーム",
        SCORE_SHEET.r1 AS "結果１",
        SCORE_SHEET.r2 AS "結果２",
        SCORE_SHEET.r3 AS "結果３",
        SCORE_SHEET.r4 AS "結果４",
        GROUP_RANK3.played AS "試合数",
        GROUP_RANK3.win AS " 勝 ",
        GROUP_RANK3.draw AS " 分 ",
        GROUP_RANK3.loss AS " 負 ",
        GROUP_RANK3.goal_scored AS "総得点",
        GROUP_RANK3.goal_allowed AS "総失点",
        GROUP_RANK3.goal_difference AS "得失点差",
        GROUP_RANK3.conduct_score AS "TCS",
        GROUP_RANK3.points AS "勝ち点",
        GROUP_RANK3.fifarank AS "FIFAランク",
        CASE WHEN GROUP_RANK3.rank = 3 THEN EIGHT_OF_THIRD.rank ELSE '-' END AS "3位内順位",
        SCORE_SHEET.rkbn AS "rkbn"
    FROM GROUP_RANK3
    LEFT OUTER JOIN GROUPSTAGE USING (group_id)
    LEFT OUTER JOIN EIGHT_OF_THIRD USING (team_id)
    LEFT OUTER JOIN TEAM USING (team_id)
    LEFT OUTER JOIN SCORE_SHEET USING (team_id)
    WHERE SCORE_SHEET.rkbn = '2'
)
ORDER BY グループ, rkbn, 順位
;
