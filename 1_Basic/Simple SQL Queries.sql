--- substring search
select * from cd.facilities
where name LIKE '%Tennis%'

--- good for large searches of values from a list
select * from cd.facilities 
where facid in (1,5)

--- case syntax
select name, 
case 
  WHEN f.monthlymaintenance < 100 THEN 'cheap'
  WHEN f.monthlymaintenance >100 THEN 'expensive'
  
end cost
from cd.facilities as f

--- date filter 
select memid, surname, firstname, joindate 
from cd.members
where joindate >= '2012-09-01'

--- postgres limit
select distinct surname from cd.members
order by surname asc
limit 10

--- union
--- union all does not remove duplicate rows
--- union removes duplicate rows
--- column names for first select are used as column names for result set
select surname 
	from cd.members
union
select name
	from cd.facilities;     

--- aggregating dae
---select joindate from cd.members order by joindate desc limit 1;
select max(joindate) from cd.members

--- getting other data with an aggregate
select firstname, surname, joindate from cd.members
where joindate = (select max(joindate) from cd.members)