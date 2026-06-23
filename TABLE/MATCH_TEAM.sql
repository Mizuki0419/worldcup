DROP TABLE MATCH_TEAM ;

CREATE TABLE MATCH_TEAM(
	match_id, 
	team_id, 
	score, 
	conduct_score, 
    PRIMARY KEY (match_id, team_id)
);

CREATE INDEX MATCH_TEAM_IDX ON MATCH_TEAM (
	match_id
);

INSERT INTO MATCH_TEAM (match_id, team_id, score, conduct_score) VALUES 
	('010', 'NED', 2, -3), 
	('010', 'JPN', 2, 0), 
	('012', 'SWE', 5, 0), 
	('012', 'TUN', 1, -1), 
	('033', 'NED', 5, 0), 
	('033', 'SWE', 1, -3), 
	('036', 'TUN', 0, 0), 
	('036', 'JPN', 4, 0)
;
