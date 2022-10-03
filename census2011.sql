use sqlproject;
-- viewing the data
select * from data1;
select * from data2;

-- number of rows in the dataset
select count(*) from data1;
select count(*) from data2;

-- dataset for particular states
select * from data1 where state in ('Uttar Pradesh','Delhi');
select * from data2 where state in ('Uttar Pradesh','Delhi');

-- total population of India
select sum(Population) population from data2;

-- average population growth of India
select round(avg(growth_perc)*100,2) avg_growth from data1;

-- average population growth of states of India
select state, round(avg(growth_perc)*100,2) avg_growth from data1 group by state order by state;

-- average sex ratio of states of India
select state, round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by state;

-- state with highest sex ratio
select state, round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by avg_sex_ratio desc limit 1;

-- states with literacyrate > 90
select state, round(avg(Literacy),0) avg_literacy_rate from data1 group by state having avg_literacy_rate>90 order by state;

-- top 3 states showing highest average growth 
select state, round(avg(growth_perc)*100,2) avg_growth from data1 group by state order by avg_growth desc limit 3;

-- bottom 3 states showing lowest sex ratio 
select state, round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by avg_sex_ratio limit 3;

-- states starting with letter A
select distinct state from data2 where left(lower(state),1)='a';

-- states starting with letter A and ending with M
select distinct state from data2 where lower(state) like 'a%m' ;

-- joinig both tables
-- males and females in each district taking the sex ratio as female/male
select d1.district,d1.state,round(d2.population/((d1.sex_ratio/1000)+1),0) males,round(d2.population - (d2.population/((d1.sex_ratio/1000)+1)),0) females from data1 d1, data2 d2 where d1.district=d2.district;
        -- OR
select c.district, round(c.population/(c.sex_ratio+1),0) as males, round(c.population - c.population/(c.sex_ratio+1),0) as females from (select d1.district, d1.state,d1.sex_ratio/1000 sex_ratio,d2.population from data1 d1,data2 d2 where d1.district=d2.district) c;

-- males and females in each state taking the sex ratio as female/male
select d.state, sum(d.males) males,sum(d.females)males from(select c.district,c.state, round(c.population/(c.sex_ratio+1),0) as males, round(c.population - c.population/(c.sex_ratio+1),0) as females from (select d1.district, d1.state,d1.sex_ratio/1000 sex_ratio,d2.population from data1 d1,data2 d2 where d1.district=d2.district) c ) d group by d.state;

-- total literate and illetrate people by each state
select d.state, sum(d.literate_people) literate_people, sum(d.illeterate_people) illeterate_people from (select c.district,c.state, round(c.literacy*c.population,0) as literate_people, round(c.population - c.literacy*c.population,0) as illeterate_people from (select d1.district, d1.state,d1.literacy/100 literacy,d2.population from data1 d1,data2 d2 where d1.district=d2.district) c) d group by d.state;

-- population in previous census statewise
select d.state, sum(d.previous_census_population)previous_census_population,sum(d.present_census_population)present_census_population from(select c.district, c.state,round(c.population/(1+c.growth_perc),0) previous_census_population, c.population present_census_population from (select d1.district,d1.state, d2.population, d1.growth_perc from data1 d1, data2 d2 where d1.district=d2.district) c)d group by d.state;

-- population in previous census
select sum(e.previous_census_population)previous_census_population,sum(e.present_census_population)present_census_population from (select d.state, sum(d.previous_census_population)previous_census_population,sum(d.present_census_population)present_census_population from(select c.district, c.state,round(c.population/(1+c.growth_perc),0) previous_census_population, c.population present_census_population from (select d1.district,d1.state, d2.population, d1.growth_perc from data1 d1, data2 d2 where d1.district=d2.district) c)d group by d.state) e;

-- population v/s area 
select round(g.tot_area/f.previous_census_population,4) area_per_prev, round(g.tot_area/f.present_census_population,4) area_per_pres from 
(select '1' as xyz, sum(e.previous_census_population)previous_census_population,sum(e.present_census_population)present_census_population from (select d.state, sum(d.previous_census_population)previous_census_population,sum(d.present_census_population)present_census_population from(select c.district, c.state,round(c.population/(1+c.growth_perc),0) previous_census_population, c.population present_census_population from (select d1.district,d1.state, d2.population, d1.growth_perc from data1 d1, data2 d2 where d1.district=d2.district) c)d group by d.state) e)f, 
(select '1' as xyz, sum(area_km2) tot_area from data2)g 
where f.xyz=g.xyz;

-- literacy status of districts of each state
select district,state,literacy,
CASE
    when literacy > 80 then 'excellent'
    when literacy<=80 and literacy>60 then 'good'
    else 'poor'
    end
    as literacy_status
from data1;

-- top and bottom 3 states in literacy rate

drop temporary table if exists topstates;
create temporary table topstates(state varchar(100), topstate float);
insert into topstates (select state, round(avg(literacy),0) avg_literacy_ratio  from data1 group by state order by avg_literacy_ratio desc);
select * from topstates  limit 3;

drop temporary table if exists bottomstates;
create temporary table bottomstates(state varchar(100), topstate float);
insert into bottomstates(select state, round(avg(literacy),0) avg_literacy_ratio  from data1 group by state order by avg_literacy_ratio);
select * from bottomstates limit 3;

-- union operator
(select * from topstates  limit 3) union (select * from bottomstates limit 3); 





