create database olympics;
use olympics;

create table if not exists olympics_history
(
    id varchar(255),
	name VARCHAR(255),
    sex VARCHAR(255),
    age VARCHAR(255),
    height VARCHAR(255),
    weight VARCHAR(255),
    team VARCHAR(255),
    noc VARCHAR(255),
    games VARCHAR(255),
    year varchar(255),
    season VARCHAR(255),
    city VARCHAR(255),
    sport VARCHAR(255),
    event VARCHAR(255),
    medal VARCHAR(255)
    );

create table if not exists olympics_history_noc_regions
(
    noc VARCHAR(50),
    regions varchar(100),
    notes varchar(100)
);

LOAD DATA INFILE 'athlete_events.csv'
INTO TABLE olympics_history
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, sex, age, height, weight, team, noc, games, year, season, city, sport,event,medal);


LOAD DATA INFILE 'noc_regions.csv'
INTO TABLE olympics_history_noc_regions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(noc ,regions ,notes);

select * from  olympics_history;
select * from  olympics_history_noc_regions;
-- 1. How many olympics games have been held?

select count(distinct games) as total_games from olympics_history ;

-- 2. Write a SQL query to list down all the Olympic Games held so far?
select  year ,season , city  from  olympics_history
group by year , season , city 
order by year;
-- 3.SQL query to fetch total no of countries participated in each olympic games.
select games, count(distinct noc) from olympics_history
group by games;
---------------------------- OR----------------------------------------
select games ,count(distinct regions) as total_country from olympics_history 
join olympics_history_noc_regions  
on olympics_history.noc = olympics_history_noc_regions.noc 
group by games
order by games;

-- 4 Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.
-- 4. Which year saw the highest and lowest no of countries participating in olympics
with all_countries as(
	SELECT oh.games,nr.regions from olympics_history as oh
	join olympics_history_noc_regions as nr
	on oh.noc = nr.noc
	group by games,regions
	order by games 

),

games_country_count as(
	select games,count(regions) as total_countries 
	from all_countries
	group by games
	order by games
)
select * from  games_country_count;

select
	concat(
			(select games from  games_country_count order by total_countries asc limit 1),
			'-',
			(select total_countries from games_country_count order by total_countries asc limit 1)
          )as lowest_countries,
    
concat(
		(select games from  games_country_count order by total_countries desc limit 1),
		'-',
		(select total_countries from games_country_count order by total_countries desc limit 1)
    )as higest_countries;
    
    
    
select * from  olympics_history;
select * from  olympics_history_noc_regions;

-- 5 SQL query to return the list of countries who have been part of every Olympics games.
with answer as(
select regions as countries , count( distinct games) as total_games from olympics_history 
join olympics_history_noc_regions on 
olympics_history.noc=olympics_history_noc_regions.noc
group by countries  
order by  countries 
)
select countries,total_games from  answer order by total_games desc ,  countries asc limit 4;


-- 6 SQL query to fetch the list of all sports which have been part of every olympics
with sports as(
select sport , count(distinct games) as no_of_games , count( distinct games)as total_games from olympics_history
group by sport
order by sport
)
select sport,  no_of_games,total_games from sports 
order by  no_of_games desc limit 5;

-- OR--

-- 6. Identify the sport which was played in all summer olympics.

with t1 as
    ( select count(distinct games) as total_summer_games
    from olympics_history
    where season ='summer'
    ),

 t2 as 
	( select distinct sport ,games -- because we r using (distinct) it gets grouped automatically
	  from olympics_history
	  where season ='summer'
      ),
 t3 as
	( select sport,count(games) as no_of_games
      from t2
      group by sport
      )
      
select * from t3  
join t1  
on t1.total_summer_games =   t3.no_of_games;
select * from  olympics_history;
select * from  olympics_history_noc_regions;


-- 7.Using SQL query, Identify the sport which were just played once in all of olympics.
with tab1 as(
select distinct sport ,  games
from olympics_history),
tab2 as
( select sport,count(games) as no_of_games from tab1 group by sport)
select * from tab2;
select tab2.*,games from tab1 join tab2
on tab1.sport = tab2.sport
where no_of_games=1
order by sport;




select * from  olympics_history;
select * from  olympics_history_noc_regions;

-- 8.Write SQL query to fetch the total no of sports played in each olympics.
select games , count(distinct sport) as no_of_sport
from olympics_history
group by games
order by  no_of_sport desc, games ;


select * from  olympics_history;
select * from  olympics_history_noc_regions;

-- 9.SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics. Fetch oldest athletes to win a gold medal

with temp as(
    select id, name ,sex,
    case 
    when age="NA" then 0
    else cast(age as unsigned)
    end as age,
	height,weight,team,noc,games,year,season,city,sport,event,medal
    from olympics_history
    ),
rnk as(
    select *,rank() over(order by age desc) as rkk from temp
	where medal like'%Gold%'
    )
select * from rnk
where rkk=1;


-- 10. Find the Ratio of male and female athletes participated in all olympic games

with m1 as (
    select count(*) as male_count
    from olympics_history
    where sex = 'M'
),
f2 as (
    select count(*) as female_count
    from olympics_history
    where sex = 'F'
)
select
    concat('1 : ',round(m1.male_count *1.0 /f2.female_count,2))as ratio
from m1, f2;

-- 11. Fetch the top 5 athletes who have won the most gold medals.

select name,team,count(medal) as total_gold_medals
from olympics_history
where medal like '%Gold%'
group by name,team
order by total_gold_medals desc limit 5;


-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select name,team,count(medal) as total_medals
from olympics_history
where medal like '%Gold%'
   or medal like '%Silver%'
   or medal like '%Bronze%'
group by name,team
order by total_medals desc limit 5;



-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select 
    nr.regions,
    count(medal) as total_medals,
    rank() over (order by count(medal) desc) as rnk
from olympics_history as oh
join olympics_history_noc_regions as nr
    on oh.noc = nr.noc
where medal like '%Gold%'
   or medal like '%Silver%'
   or medal like '%Bronze%'
group by nr.regions
order by total_medals desc
limit 5;


-- 14. List down total gold, silver and bronze medals won by each country.

with t1 as(
select oh.medal , nr.regions
from olympics_history as oh join olympics_history_noc_regions as nr 
on oh.noc =nr.noc 
)

select  regions as country,
    count(case when medal like '%Gold%' then 1 end) as gold,
    count(case when medal like '%Silver%' then 1 end) as silver,
    count(case when medal like '%Bronze%' then 1 end) as bronze
from t1
group by regions
order by gold desc;



-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

with t1 as(
select  oh.games,oh.medal , nr.regions
from olympics_history as oh join olympics_history_noc_regions as nr 
on oh.noc =nr.noc 
)

select  games ,regions as country,
    count(case when medal like '%Gold%' then 1 end) as gold,
    count(case when medal like '%Silver%' then 1 end) as silver,
    count(case when medal like '%Bronze%' then 1 end) as bronze
from t1
group by games,regions
order by games;

-- 18. Which countries have never won gold medal but have won silver/bronze medals?

with t1 as(
	select nr.regions as country,
	sum(case when medal like '%Gold%' then 1 else 0 end) as Gold,
	sum(case when medal like '%Silver%' then 1 else 0 end) as Silver,
	sum(case when medal like '%Bronze%' then 1 else 0 end) as Bronze
	from olympics_history as oh
	join olympics_history_noc_regions as nr
	on oh.noc = nr.noc
	where medal like '%Gold%' or
		  medal like '%Silver%' or
		  medal like '%Bronze%'
	 group by country     
)

select *
from t1
where Gold = 0 
  AND (silver > 0 OR bronze > 0)
  order by Gold desc,Silver desc,Bronze desc;



-- 19. In which Sport/event, India has won highest medals.

select * from olympics_history;
select * from olympics_history_noc_regions;

select  sport ,count(medal) as total_medals
from olympics_history
where medal != 'NA'
and team = 'India'
group by sport
order by total_medals desc limit 1;


-- 20. Break down all olympic games where India won medal for Hockey 
--     and how many medals in each olympic games

    select team, sport, games, count(medal) as total_medals
    from olympics_history
    where medal != 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;

select * from olympics_history;
select * from olympics_history_noc_regions;