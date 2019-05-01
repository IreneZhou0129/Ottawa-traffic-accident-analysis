
CREATE TABLE collision_data_prv
(
    location1 character varying(100) COLLATE pg_catalog."default",
	location2 character varying(100) COLLATE pg_catalog."default",
	location3 character varying(100) COLLATE pg_catalog."default",
    longitude numeric(15,5),
	latitude numeric(15,5),
	year_ integer,
    month_ integer,
	day_ integer,
    time_ time without time zone,
	hour_ integer,
    Environment1 character varying(50),
    Road_Surface1 character varying(50),
    Traffic_Control1 character varying(50),
    Collision1 character varying(50),
	Light1 character varying(50),
    Collision_Classification1 character varying(50),
	Impact_type1 character varying(50)
)
WITH (
    OIDS = FALSE
)