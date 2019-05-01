select * from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey and a.environment like '%Clear%' and w.conditions like '%Rain%'
and a.road_surface like '%Dry%';
/*312 rows*/
select * from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey
and (a.environment like '%Clear%')
and (w.conditions not like '%Clear%')
/*and (a.road_surface like '%Clear%')*/;
/*3548 rows, this does not mean much. */
select road_surface, environment, w.* from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey
/*and (a.environment like '%Clear%')*/
and (w.conditions  like '%Clear%')
and (a.road_surface not like '%Clear%' and a.road_surface not like '%Dry%')
and w.temperature > 0;
/*49 rows*/
select road_surface, environment, w.* from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey
and (a.environment not like '%Clear%')
and (w.conditions  like '%Clear%')
/*and (a.road_surface not like '%Clear%' and a.road_surface not like '%Dry%')*/
;
/*79 rows this gives a few exemples where the officer claims rain or other things but the weather station does not.*/
select road_surface, environment, w.* from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey
and (a.environment like '%fog%' or a.environment like '%Fog%')
and (w.conditions  like '%Clear%')
and (a.road_surface not like '%Clear%' and a.road_surface not like '%Dry%')
;
/*1 row*/
select road_surface, environment, w.* from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey
and (a.environment like '%fog%' or a.environment like '%Fog%')
and (w.conditions  like '%Clear%')
/*and (a.road_surface not like '%Clear%' and a.road_surface not like '%Dry%')*/
;
/*5 rows*/
select road_surface, environment, w.* from collision_fact as c, accident as a, weather_dimension as w 
where a.accident_key = c.accident_key and w.weatherkey = c.weatherkey
and (a.environment like '%Clear%')
and (w.conditions  like '%fog%' or w.conditions like '%Fog%')
/*and (a.road_surface not like '%Clear%' and a.road_surface not like '%Dry%')*/
;
/*420 rows*/
/* using these few tests, we can reach the conclusion that the accident vs weather station
are not fully synced up so either the condition on the road differed from
the weather or the police officer did not enter the correct conditions.*/