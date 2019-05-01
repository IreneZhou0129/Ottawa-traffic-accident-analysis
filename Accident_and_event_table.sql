CREATE TABLE Accident(
	accident_key SERIAL PRIMARY KEY,
	accident_time TIME,
	environment VARCHAR,
	road_surface VARCHAR,
	traffic_controlt VARCHAR,
	visibility VARCHAR,
	impact_type VARCHAR
);
CREATE TABLE event(
	event_key SERIAL PRIMARY KEY,
	event_name VARCHAR,
	event_start_date DATE,
	event_end_date DATE
);


