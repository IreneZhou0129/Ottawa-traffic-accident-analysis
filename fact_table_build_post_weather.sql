alter table collision_fact add accident_key integer;
alter table collision_fact add 
			constraint accident_key FOREIGN KEY (accident_key) REFERENCES accident;

update collision_fact
	set accident_key = accident.accident_key
	from accident
	where cast(accident.time as time) = collision_fact.time_ and accident.environment = environment1
		and road_surface = collision_fact.road_surface1 and traffic_controlt = traffic_control1 and light = light1
		and collision_classification = collision_classification1 and impact_type = impact_type1
	;
	
alter table collision_fact drop environment1;
alter table collision_fact drop road_surface1;
alter table collision_fact drop traffic_control1;
alter table collision_fact drop collision1;
alter table collision_fact drop light1;
alter table collision_fact drop collision_classification1;
alter table collision_fact drop impact_type1;


alter table collision_fact add hour_key integer;
alter table collision_fact add 
			constraint hour_key FOREIGN KEY (hour_key) REFERENCES hours;

update collision_fact
	set hour_key = hours.hour_key
	from hours
	where cast(hours.time as time) = time_ and month_ = cast(hours.month as integer) and cast(hours.year as integer) = year_ and cast(hours.date as integer) = day_
	;
alter table collision_fact drop year_;
alter table collision_fact drop month_;
alter table collision_fact drop day_;
alter table collision_fact drop time_;
alter table collision_fact drop hour_;

alter table collision_fact add location_key integer;
alter table collision_fact add 
			constraint location_key FOREIGN KEY (location_key) REFERENCES locations;



update collision_fact
	set location_key = locations.location_key
	from locations
	where trim(BOTH from location1) = trim(BOTH FROM locations.street_name) 
	and trim(BOTH FROM location2) = trim(BOTH FROM intersection_1)
	and trim(BOTH FROM location3) = trim( BOTH FROM intersection_2)
	and collision_fact.longitude = cast(locations.longitude as numeric(15,5)) and collision_fact.latitude = cast(locations.latitude as numeric(15,5))
																																			   ;
																																			   
update collision_fact
	set location_key = locations.location_key
	from locations
	where trim(BOTH from location1) = trim(BOTH FROM locations.street_name) 
	and trim(BOTH FROM location2) = trim(BOTH FROM intersection_1)
	and location3 is null and intersection_2 is null
	and collision_fact.longitude = cast(locations.longitude as numeric(15,5)) and collision_fact.latitude = cast(locations.latitude as numeric(15,5))
																																			   ;
update collision_fact
	set location_key = locations.location_key
	from locations
	where trim(BOTH from location1) = trim(BOTH FROM locations.street_name) 
	and location2 is null and intersection_1 is null
	and location3 is null and intersection_2 is null
	and collision_fact.longitude = cast(locations.longitude as numeric(15,5)) and collision_fact.latitude = cast(locations.latitude as numeric(15,5))
																																			   ;
update collision_fact
	set location_key = locations.location_key
	from locations
	where 
	 collision_fact.longitude = cast(locations.longitude as numeric(15,5)) and collision_fact.latitude = cast(locations.latitude as numeric(15,5)) and collision_fact.location_key is null
																																			   ;
alter table collision_fact drop location1;
alter table collision_fact drop location2;
alter table collision_fact drop location3;
alter table collision_fact drop latitude;
alter table collision_fact drop longitude;


GRANT ALL PRIVILEGES ON TABLE collision_fact TO public;
GRANT ALL PRIVILEGES ON TABLE weather_dimension TO public;