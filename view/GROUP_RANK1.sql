/**********************************
 グループステージの順位付け　STEP2
 当該チーム間の試合の勝点
 当該チーム間の試合の得失点差
 当該チーム間の試合の最高得点
 ※順位がつかなくなるまで繰り返し
**********************************/

DROP TABLE GROUP_RANK1 ;

CREATE TABLE GROUP_RANK1(
	group_id, 
	rank, 
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
);
