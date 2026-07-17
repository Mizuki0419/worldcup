DROP TABLE GROUPSTAGE;

CREATE TABLE GROUPSTAGE(
	group_id TEXT,
	group_name TEXT,
	PRIMARY KEY (group_id)
);

CREATE INDEX GROUPSTAGE_IDX ON GROUPSTAGE (
	group_id
);

INSERT INTO GROUPSTAGE (group_id, group_name) VALUES
	('01', 'A'),
	('02', 'B'),
	('03', 'C'),
	('04', 'D'),
	('05', 'E'),
	('06', 'F'),
	('07', 'G'),
	('08', 'H'),
	('09', 'I'),
	('10', 'J'),
	('11', 'K'),
	('12', 'L')
;
