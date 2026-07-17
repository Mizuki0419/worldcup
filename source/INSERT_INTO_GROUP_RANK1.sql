INSERT INTO GROUP_RANK1
SELECT
    group_id,
    ? AS rank,
    team_id,
    played,
    win,
    draw,
    loss,
    goal_scored,
    goal_allowed,
    goal_difference,
    conduct_score,
    points,
    fifarank
FROM GROUP_RANK0
WHERE team_id = ?;
