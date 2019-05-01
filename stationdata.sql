CREATE TABLE public.station_data_prv
(
    stationname character varying(50) COLLATE pg_catalog."default",
    latitude numeric(10,2),
    longitude numeric(10,2)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;