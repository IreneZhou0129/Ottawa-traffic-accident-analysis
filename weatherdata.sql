-- Table: public.station_data_prv

-- DROP TABLE public.station_data_prv;



/*upload the data to station_data_prv before running the whole thing*/

Alter table weather_data add longitude numeric(10,5);
Alter table weather_data add latitude numeric(10,5);

Delete from station_data_prv where stationname ='OTTAWA CDA RCS';
Delete from station_data_prv where stationname ='OTTAWA MACDONALD-CARTIER INT''L A';
Delete from station_data_prv where stationname ='OTTAWA LA SALLE ACAD';
Delete from station_data_prv where stationname ='OTTAWA NEPEAN';
Delete from station_data_prv where stationname ='OTTAWA GATINEAU A'; /*qc data*/
Delete from station_data_prv where stationname ='WEST VANCOUVER OTTAWA'; /*BC data*/

Update weather_data
	set station = 'OTTAWA CDA'
	where station = 'OTTAWA CDA RCS';
	
Update weather_data
	set station = 'OTTAWA INTL A'
	where station = 'OTTAWA MACDONALD-CARTIER INT''L A';
	
Update weather_data
	set station = 'OTTAWA CITY HALL'
	where station = 'OTTAWA LA SALLE ACAD';	
	
Update weather_data
	set station = 'OTTAWA ALTA VISTA'
	where station = 'OTTAWA NEPEANS';
	
update weather_data
	set longitude = station_data_prv.longitude , latitude = station_data_prv.latitude
	from station_data_prv
	where station_data_prv.stationname = weather_data.station
	;

alter table collision_data_prv add fatal_measure integer;

update collision_data_prv
	set fatal_measure = 1
	where collision_classification1 like '%01%';
	
update collision_data_prv
	set fatal_measure = 0
	where fatal_measure is null;
	
alter table collision_data_prv add intersection_measure integer;

update collision_data_prv
	set intersection_measure = 1
	where collision1 like '%03%';
	
update collision_data_prv
	set intersection_measure = 0
	where intersection_measure is null;
	
update weather_data
	set longitude = station_data_prv.longitude , latitude = station_data_prv.latitude
	from station_data_prv
	where station_data_prv.stationname = weather_data.station
	;
	
/*https://www.postgresql.org/message-id/AANLkTimvprPanJ48_uzuWoHJfGsX8ihXO7bLStFfjWf8@mail.gmail.com*/

create or replace function gc_dist(_lat1 float8, _lon1 float8, _lat2
float8, _lon2 float8) returns float8 as
$$
select ACOS(SIN($1)*SIN($3)+COS($1)*COS($3)*COS($4-$2))*6371;
$$ language sql immutable;
												
Alter Table weather_data
Add Idkey SERIAL NOT NULL;
												
create table tmp3 as (select collision_data_prv.year_, collision_data_prv.month_,
					  collision_data_prv.day_, collision_data_prv.hour_,collision_data_prv.longitude,
					  collision_data_prv.latitude, gc_dist(station_data_prv.latitude,station_data_prv.longitude,collision_data_prv.latitude,collision_data_prv.longitude) as distance,
					  station_data_prv.stationname
					   from collision_data_prv, station_data_prv
					  group by collision_data_prv.year_, collision_data_prv.month_, collision_data_prv.day_, collision_data_prv.hour_, collision_data_prv.longitude, collision_data_prv.latitude, distance, stationname)	;
create table weather_data_tmp as (select * from weather_data where
								  weather_data.tempc is not null /*and (weather_data.humidity is not null or weather_data.windspeed is not null or visibilitykm is not null or conditions is not null)*/);
create table test4 as (select min(distance) as distance, tmp3.longitude, tmp3.latitude, tmp3.year_, tmp3.month_, tmp3.day_, tmp3.hour_ from tmp3, weather_data_tmp 
					   where tmp3.year_ = weather_data_tmp.year_ and tmp3.month_ = weather_data_tmp.month_ and tmp3.day_ = weather_data_tmp.day_ and tmp3.hour_ = extract(hour from weather_data_tmp.time_) and tmp3.stationname = weather_data_tmp.station
					   group by tmp3.longitude, tmp3.latitude, tmp3.year_, tmp3.month_, tmp3.day_, tmp3.hour_
					   );
	
create table test5 as 
				(select tmp3.* from tmp3 NATURAL JOIN test4 )	;
/*DELETE FROM test5 where longitude = -75.70500 and latitude = 45.41876 and stationname = 'OTTAWA LEMIEUX ISLAND';
												where test4.distance = tmp3.distance and tmp3.longitude = test4.longitude and tmp3.latitude = test4.latitude*/
				
create table test6 as (select distinct(test5.stationname), collision_data_prv.*
				from test5 NATURAL JOIN collision_data_prv);	
													
										
create table weather_dimension as (select Idkey as weatherKey, station as stationName, longitude, latitude, tempc as temperature, visibilitykm as visibility,
								   windspeed as windSpeed, winddir as windDirection, windchill as windChill, pressure, hmdx as humidex, year_,month_,day_,extract(hour from time_) as time_, conditions
								   from weather_data_tmp);
alter table weather_dimension add												
			CONSTRAINT weatherKey PRIMARY KEY (weatherKey);									
												
alter table test6 add 
			weatherKey int;
alter table test6 add 
			constraint weatherDimKey FOREIGN KEY (weatherKey) REFERENCES weather_dimension;

update test6 
		set weatherkey = weather_dimension.weatherKey
		from weather_dimension
		where weather_dimension.stationname = test6.stationName and weather_dimension.year_ = test6.year_ and weather_dimension.month_ = test6.month_ and weather_dimension.day_ = test6.day_
			and weather_dimension.time_ = test6.hour_
			;

create table collision_fact as (select * from test6);
												
alter table collision_fact add 
			constraint weatherDimKey FOREIGN KEY (weatherKey) REFERENCES weather_dimension;
												
alter table collision_fact drop stationname;
alter table weather_dimension drop year_;
alter table weather_dimension drop month_;
alter table weather_dimension drop day_;
alter table weather_dimension drop time_;
												
drop table tmp3;
drop table test4;
drop table test5;
drop table weather_data_tmp;


drop table test6;
drop table station_data_prv;
drop table collision_data_prv;
												
												