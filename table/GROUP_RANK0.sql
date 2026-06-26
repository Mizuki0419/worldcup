DROP VIEW GROUP_RANK0;

CREATE VIEW GROUP_RANK0 AS
SELECT
    GROUPSTAGE.group_id AS group_id,
    DENSE_RANK() OVER (ORDER BY RESULT_OF_TEAM1.points DESC) AS rank,
    TEAM.team_id AS team_id,
    RESULT_OF_TEAM1.played AS played,
    RESULT_OF_TEAM1.win AS win,
    RESULT_OF_TEAM1.draw AS draw,
    RESULT_OF_TEAM1.loss AS loss,
    RESULT_OF_TEAM1.goal_scored AS goal_scored,
    RESULT_OF_TEAM1.goal_allowed AS goal_allowed,
    RESULT_OF_TEAM1.goal_scored - RESULT_OF_TEAM1.goal_allowed AS goal_difference,
    RESULT_OF_TEAM1.conduct_score AS conduct_score,
    RESULT_OF_TEAM1.points AS points,
    FIFARANK.fifarank AS fifarank
FROM
    GROUPSTAGE
INNER JOIN
    TEAM
    ON GROUPSTAGE.group_id = TEAM.group_id
INNER JOIN
    MATCH_TEAM
    ON TEAM.team_id = MATCH_TEAM.team_id
LEFT OUTER JOIN
    (
        SELECT
            *,
            (RESULT_OF_TEAM0.win * 3) + (RESULT_OF_TEAM0.draw * 1) AS points
        FROM
            (
                SELECT
                    Home.team_id AS team_id,
                    COUNT(Home.team_id) AS played,
                    SUM(CASE WHEN Home.score > Away.score THEN 1 ELSE 0 END) AS win,
                    SUM(CASE WHEN Home.score = Away.score THEN 1 ELSE 0 END) AS draw,
                    SUM(CASE WHEN Home.score < Away.score THEN 1 ELSE 0 END) AS loss,
                    SUM(Home.score) AS goal_scored,
                    SUM(Away.score) AS goal_allowed,
                    SUM(Home.conduct_score) AS conduct_score
                FROM
                    MATCH_TEAM AS Home
                INNER JOIN
                    MATCH_TEAM AS Away
                    ON Home.match_id = Away.match_id
                    AND Home.team_id != Away.team_id
                GROUP BY
                    Home.team_id
            ) RESULT_OF_TEAM0
    ) RESULT_OF_TEAM1
    ON TEAM.team_id = RESULT_OF_TEAM1.team_id
LEFT OUTER JOIN
    FIFARANK
    ON TEAM.team_id = FIFARANK.team_id
;
