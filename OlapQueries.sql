/*Roll up*/
SELECT
SUM(F.FATAL_MEASURE), h.year, h.month
FROM
collision_fact F, hours H, accident A
WHERE
A.accident_key = F.accident_key AND
F.hour_key = H.hour_key AND A.environment like '%Snow'
group by
    rollup(h.year, h.month);
/*Roll up*/
SELECT
SUM(F.FATAL_MEASURE), h.year, h.month, a.road_surface
FROM
collision_fact F, hours H, accident A
WHERE
A.accident_key = F.accident_key AND
F.hour_key = H.hour_key AND H.hour_start > 10
group by
    rollup(h.year, h.month, a.road_surface);
/*drill down*/
SELECT 
SUM(F.FATAL_MEASURE)
FROM 
collision_fact F, hours H
WHERE 
F.hour_key = H.hour_key
;
/*Drill down*/
SELECT 
SUM(F.FATAL_MEASURE)
FROM 
collision_fact F, hours H
WHERE 
F.hour_key = H.hour_key AND H.year = 2015 
;
/*slice and dice*/
SELECT 
SUM(F.FATAL_MEASURE)
FROM 
collision_fact F, hours H, accident A
WHERE 
F.hour_key = H.hour_key AND H.year = 2014 AND A.accident_key = F.accident_key AND A.environment like '%Snow'
;
/*slice and dice*/
SELECT 
SUM(F.FATAL_MEASURE)
FROM 
collision_fact F, hours H, accident A
WHERE 
F.hour_key = H.hour_key AND A.accident_key = F.accident_key AND
H.year = 2014 AND H.month = '12' AND A.environment like '%Snow' 
;
/*slice and dice*/
SELECT 
SUM(F.FATAL_MEASURE)
FROM 
collision_fact F, hours H, accident A
WHERE 
F.hour_key = H.hour_key AND A.accident_key = F.accident_key AND
H.year = 2014 AND H.month = '12' AND A.environment like '%Snow' 
;

SELECT 
SUM(F.FATAL_MEASURE)
FROM 
collision_fact F, hours H, accident A , locations L
WHERE 
F.hour_key = H.hour_key AND L.location_key = F.location_key AND A.accident_key = F.accident_key AND H.year = 2014 AND H.month = '12' AND A.environment like '%Snow' AND L.neighbourhood = 'centertown' 
;
select 
    count(*) filter (where h_dim.day_of_week = 'Monday') as Monday_accidents,
    count(*) filter (where h_dim.day_of_week = 'Friday') as Friday_accidents
from collision_fact cf, accident a_dim, hours h_dim
where cf.accident_key = a_dim.accident_key
and cf.hour_key = h_dim.hour_key;

select 
    count(*) filter (where h_dim.day_of_week = 'Monday') as Monday_fatals,
    count(*) filter (where h_dim.day_of_week = 'Friday') as Friday_fatals
from collision_fact cf, accident a_dim, hours h_dim
where cf.accident_key = a_dim.accident_key
and cf.hour_key = h_dim.hour_key
and cf.fatal_measure = 1;

select 
     count(*) filter (where cf.intersection_measure = 1) as at_intersection,
    count(*) filter (where cf.intersection_measure = 0) as not_at_intersection
from collision_fact cf;

select 
      count(*) filter (where cf.intersection_measure = 1) as fatals_at_intersection,
     count(*) filter (where cf.intersection_measure = 0) as fatals_not_at_intersection
from collision_fact cf
where cf.fatal_measure = 1;

select 
     count(*) filter (where h.month = '6' OR h.month = '7' OR h.month = '8' OR h.month = '9') as summer,
    count(*) filter (where h.month = '10' OR h.month = '11' OR h.month = '12' AND cf.fatal_measure = 1) as fall
from collision_fact cf, hours h, accident a
where cf.hour_key = h.hour_key and cf.accident_key = a.accident_key
;
select 
     a.road_surface, count(*) as number_accident
from collision_fact cf, accident a
where cf.accident_key = a.accident_key
group by a.road_surface
;

select 
     w.conditions, count(*) as number_accident 
from collision_fact cf, weather_dimension w
where cf.weatherkey = w.weatherkey and w.conditions like('%Heavy Rain%')
GROUP BY w.conditions
;

select 
     count(*) filter (where h.month = '6' OR h.month = '7' OR h.month = '8' OR h.month = '9' and l.neighbourhood like ('%Orleans%')) AS summer,
    count(*) filter (where h.month = '10' OR h.month = '11' OR h.month = '12' AND cf.fatal_measure = 1 and l.neighbourhood like 'Nepean%') as fall
from collision_fact cf, hours h, accident a, locations l
where cf.hour_key = h.hour_key and cf.accident_key = a.accident_key
;

/*top N*/
 select l_dim.intersection_1 as intersection_1, count(*) as counts_1 
 from locations as l_dim
 group by intersection_1 
 order by counts_1 desc
 limit 1;

/*bottom n*/
select l_dim.neighbourhood as neighbourhood,
        h_dim.hour_start,
        h_dim.hour_end,
        count(*) as counts 
from locations as l_dim, collision_fact as cf, hours as h_dim
where 
    cf.location_key = l_dim.location_key
    and cf.hour_key = h_dim.hour_key
    and (h_dim.hour_start between 16 and 19)
    and (h_dim.hour_end between 16 and 19)
group by neighbourhood,    h_dim.hour_start,
        h_dim.hour_end
order by counts
limit 1;

/*bottom n*/
select l_dim.intersection_1 as intersection_1,
        h_dim.hour_start,
        h_dim.hour_end,
        h_dim.month,
        count(*) as counts 
from locations as l_dim, collision_fact as cf, hours as h_dim
where 
    cf.location_key = l_dim.location_key
    and cf.hour_key = h_dim.hour_key
    and (h_dim.hour_start between 16 and 19)
    and (h_dim.hour_end between 16 and 19)
    and (h_dim.month = 'September' or h_dim.month = 'October' or h_dim.month = 'November')
group by intersection_1,h_dim.hour_start,
        h_dim.hour_end,h_dim.month
order by counts
limit 1;

/*top n*/
select l_dim.street_name, l_dim.intersection_1,l_dim.intersection_2,
        w_dim.visibilitykm, count(*)
from collision_fact as cf, locations as l_dim, weather_data as w_dim
where cf.location_key = l_dim.location_key
    and cf.weatherkey = w_dim.idkey
    and visibilitykm <20.00 -- assumed
group by (l_dim.street_name, l_dim.intersection_1,l_dim.intersection_2,
        w_dim.visibilitykm)
order by count desc
limit 1;

SELECT 
SUM(F.FATAL_MEASURE) as NBR_Accident
FROM 
collision_fact f, hours h, locations l
WHERE 
l.neighbourhood like('Centertown') and f.location_key = l.location_key and h.hour_key = f.hour_key 
;

SELECT
h.year , h.month, w.conditions,
SUM(F.FATAL_MEASURE) as NBR_Accident
FROM 
collision_fact f, hours h, weather_dimension w
WHERE 
h.hour_key = f.hour_key and w.weatherkey=f.weatherkey 
group by w.conditions, h.year, h.month
ORDER by h.year, h.month ASC
;