use portfolio;
create table deaths (
id int not null,
continent varchar(255) not null,
location varchar(255),
date_var varchar(10),
population int,
total_cases int,
new_cases int,
total_deaths int,
new_deaths int,
total_cases_per_million int,
new_cases_per_million int,
total_deaths_per_million int,
new_deaths_per_million int,
primary key(id)
);


LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_deaths.csv' INTO TABLE portfolio.deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, continent, location, date_var, population, total_cases, new_cases, total_deaths, new_deaths, total_cases_per_million, new_cases_per_million, total_deaths_per_million, new_deaths_per_million);

UPDATE portfolio.deaths SET  date_var = STR_TO_DATE(REPLACE(date_var,'/','.'),GET_FORMAT(DATE,'EUR'));
ALTER TABLE portfolio.deaths MODIFY date_var DATE; #this was somehow necessary because setting it as date from the start returned only null

select * from deaths;

#Share of total deaths by total cases and by population in the UK over time
select location, population, date_var, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_per_cases, (total_deaths/population)*100 as death_per_population  from deaths
where location like '%kingdom%'
order by date_var asc;

#highest death per population rates in 2022
select location, population, date_var, (total_deaths/population)*100 as death_per_population from deaths
where date_var between '2022-01-01' and '2022-08-17'
order by death_per_population desc, date_var desc;

delete from deaths where continent=''; #is just blank so "not null" did not work. Blank continent has continent for location

#highest death counts per country ever
Create view Death_Count_Country as
select location, max(total_deaths) as total_deaths from deaths
group by location
order by total_deaths desc;

#highest death counts per continent ever, not included for tableau visualisation because redundant with country, just here as summary
select continent, max(total_deaths) as total_deaths from deaths
group by continent
order by total_deaths desc;

#Global numbers, view for tableau
Create view Death_Rate_Timeline as 
select date_var, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate from deaths
group by date_var;

