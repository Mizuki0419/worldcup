DROP TABLE MATCHES ;

CREATE TABLE MATCHES(
	match_id, 
	match_date, 
	venue, 
    PRIMARY KEY (match_id)
);

CREATE INDEX MATCHES_IDX ON MATCHES (
	match_id
);

INSERT INTO MATCHES (match_id, match_date, venue) VALUES 
	('010', '202606150500', 'ダラス'), 
	('012', '202606151100', 'モンテレイ'), 
	('033', '202606210200', 'ヒューストン'), 
	('036', '202606211300', 'モンテレイ')
;
