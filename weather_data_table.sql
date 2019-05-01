drop table weather_data_prv;
CREATE TABLE weather_data_prv
(
    xdatetime character varying(50) COLLATE pg_catalog."default",
    year_ integer,
    month_ integer,
	day_ integer,
    time_ time without time zone,
    tempc numeric(10,2),
    tempflag character varying(50),
    dewtempc numeric(10,2),
    dewtempflag character varying(50),
    humidity numeric(10,2),
    humidityflag character varying(50),
    winddir numeric(10,2),
    winddirflag character varying(50),
    windspeed numeric(10,2),
	windspeedflag character varying(50),
    visibilitykm numeric(10,2),
    visibilityflag character varying(50),
    pressure numeric(10,2),
	pressureflag character varying(50),
    hmdx numeric(10,2),
    hmdxflag character varying(50),
    windchill numeric(10,2),
    windchillflag character varying(50),
    conditions character varying(50) COLLATE pg_catalog."default",
    station character varying(50) COLLATE pg_catalog."default",
    province character varying(50) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)