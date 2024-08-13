--- exercise 1
select count(*) from cd.facilities;          
-- count(*) number of rows
-- count(addresses) counts number of non null addresses
-- count(distinct addresses)

--- exercise 2
select count(*) from cd.facilities where guestcost >= 10;
-- my solution
select count(*) from (select distinct name from cd.facilities fac
where fac.guestcost > 10) subq

--- exercise 3
select recommendedby, count(recommendedby) from cd.members
where recommendedby is not null
group by recommendedby
order by recommendedby


--- exercise 4
select facid, sum(slots) as "total slots"
from cd.bookings
group by facid
order by facid

--- exercise 5 
-- order of operations: from, join, where, group by and agg, select, 
--- from join where group by and agg having select distinct order by top 
select facid, sum(slots) as "total slots"
from cd.bookings
where date_part('month', starttime) = 9
group by facid
order by "total slots"

--- exercise 6 
-- my solution
select facid, month, sum(slots) as "Total Slots"
from (select facid, date_part('month', starttime) as month, slots
from cd.bookings where extract(year from starttime) = 2012) subq
group by month, facid
order by facid, month
-- can do it without a subquery ! 
-- can group by an a newly created field
select facid, date_part('month', starttime) as month, sum(slots)
from cd.bookings 
where extract(year from starttime) = 2012
group by month, facid
order by facid, month
-- also good to note for a lot of databases you can just add more indexes in
-- e.g.  the `where extract(year from starttime) = 2012` might be expensive on large tables
-- normal index won't work
-- can create an index like the query you use, in this case using the extract function


--- exercise 7
-- my solution
select count(memid) as count from (select mbs.memid, count(mbs.memid) as count_mbs
from cd.members mbs
left join cd.bookings bks
on mbs.memid = bks.memid
group by mbs.memid
) subq
where count_mbs > 1
-- much more elegant solution in the form of 
select count(distinct memid) from cd.bookings          
--- you can use distinct WITH count !


--- exercise 8
-- so this won't work
select facid, count(slots) as "Total Slots" 
from cd.bookings
group by facid, slots
having "Total Slots" > 1000
-- but this will work! 
select facid, sum(slots) as "Total Slots" 
from cd.bookings
group by facid
having sum(slots) > 1000
order by facid
-- don't need to group by a field you're aggregating 
-- need to make sure you use sum and not count
-- put the expression in having, NOT the alias


--- exercise 9
-- you can put a case into an function you aggregate with ! 
select name, sum(slots * 
case
when memid = 0 then guestcost
else membercost
end) 
as "revenue"
from cd.bookings bks

left join cd.facilities fls
on fls.facid = bks.facid

group by fls.name
order by revenue

-- exercise 10
-- cannot use having for newly aggregated column name, have to use the calculation itself
-- this is computationally costly
-- why not use the subquery 
select name, revenue from (select name, sum(slots * 
case
when memid = 0 then guestcost
else membercost
end) 
as "revenue"
from cd.bookings bks

left join cd.facilities fls
on fls.facid = bks.facid
group by fls.name
order by revenue) subq
where revenue < 1000

--- exercise 11
select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid
order by "Total Slots" desc
limit 1 
--- problem with this is that if you have two facilities joint top, you only get back a single value
-- also can't use max, as it would require you to aggregate on facid and then you just get a list of the max total slots per fac id 
-- as there is only one total slots value per fac id , this is dumn
-- use a CTE instead!
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);


--- exercise 12
-- grouping sets - really cool!
-- lets us see totals by facid and the total totals too in one result
-- ROLLUP(facid, month) outputs aggregations on (facid, month), (facid), and ()
-- CUBE aggregates on (facid, month), (month), (facid), and ().
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;          

-- exercise 13
-- got it except the really annoying 2 decimal places part
-- dividing by 2.0 makes sure things are in float
-- to_char and the horrible format string gets you to 2 dp
-- trim gets rid of left space padding
select facs.facid, facs.name,
	trim(to_char(sum(bks.slots)/2.0, '9999999999999999D99')) as "Total Hours"

	from cd.bookings bks
	inner join cd.facilities facs
		on facs.facid = bks.facid
	group by facs.facid, facs.name
order by facs.facid;    

--- exercise 14
--- easy peasy
select mem.surname, mem.firstname, mem.memid, min(starttime) 
from cd.members mem 
left join cd.bookings bks
on mem.memid = bks.memid
where bks.starttime > '2012-09-01'
group by mem.surname, mem.firstname, mem.memid
order by memid
