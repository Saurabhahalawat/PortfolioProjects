--Introduction
--This data analysis about the Indian states
--we have two tables 
--1.State Measures Table having information regarding diffrent measures 
--of state like Growth ,sex_ratio Litreracy 
--2. State demography table have area and population of states.

-- Its an EDA [ exploratory data analysis]
-- in this we populate some questions and find them does they 
--they are statistically significant

---look into data
use Portfolio

select top (10) * from stateMeasures
order by district

select top (10) * from statedemography

-- checking length of data set for data integrity
select COUNT(*) from StateMeasures
select COUNT(*) from StateDemography

--let's check data type of datasets
-- with the help of sp_help stored procedure 
--it will provide whole metadata about our columns

 exec sp_help StateMeasures 
 exec sp_help stateDemography

 --let's create a temp table so we can easily 
 --gathered insight from our both tables

 drop table if exists #statecombines
 create table #stateCombines
	(District nvarchar(255),
	State Nvarchar(255),
	Growth float,
	Sex_ratio float,
	Literacy float,
	Area_km2 float,
	Population float)

insert into #stateCombines
select 
	sm.District,
	sm.State,
	sm.Growth,
	sm.Sex_Ratio,
	sm.Literacy,
	sd.Area_km2,
	sd.Population
from StateMeasures sm
 full join StateDemography sd
on sm.State = sd.State and sm.District = sd.District

select count(*) from #stateCombines
select * from #stateCombines

-----------------------------------------------------------------------------------
--On how much state and district are participating in analysis

select count(distinct(state)) from #stateCombines -- 35 (28 states and remaining territories)
select count(distinct(District)) from #stateCombines--634 districts
-------------------------------------------------------------------------
--as i am from uttar pradesh let's look for values in uttar pradesh
select * from #stateCombines
where state like 'U%'

select distinct(District) from #stateCombines
where state like 'U%'

select count(distinct(District)) from #stateCombines
where state like 'U%'

select round(avg(Literacy),2) 
from StateMeasures
where state = 'Uttar pradesh'

select district,Literacy 
from StateMeasures
where state = 'Uttar pradesh' and Literacy between 80 and 100 
------------------------------------------------------------------------------

--statistics--

--top 5 populates states
select top(5) state,sum(Population) population
from #stateCombines
group by state
order by 2 desc

--top 5 populated districts in india
select top(5) District,sum(Population) population
from #stateCombines
where District is not null
group by District
order by 2 desc

--top 5 huge states
select top(5) state,sum(Area_km2) AreaKm2
from #stateCombines
group by state
order by 2 desc

--top 5 huge district 
select top(5) District,sum(Area_km2) AreaKm2
from #stateCombines
where District is not null
group by District
order by 2 desc

--average literacy rate of Indian states

select state ,Round(avg(Literacy),2) avgLitrecy
from #stateCombines
--where state = 'Uttar Pradesh'
group by state
order by avgLitrecy desc

select state ,Round(avg(Growth),2) avgGrowth
from #stateCombines
--where state = 'Uttar Pradesh'
group by state
order by avgGrowth desc

--------------------------------------------------------------

--let,s analyse 
--Q. which factors affect growth rate

with growth as
(
select 
	state,sum(Population) population,
	round(sum(Literacy)/100,1) litrecy,
	round(sum(Growth),1) growth,
	count(district) Districtcount
from #stateCombines
group by state
having round(sum(Growth),2) > 4
--order by 4 desc
)
select * from growth
order by 4 desc



--results showing mix insight that both litracy rate and population are 
--contributers to effect growth rate 
