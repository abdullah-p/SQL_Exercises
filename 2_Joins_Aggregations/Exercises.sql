--- left join syntax, use on
select bookings.starttime as starttime from cd.bookings as bookings
left join cd.members as members ON
bookings.memid = members.memid
where firstname = 'David' and surname = 'Farrell'
--- joins happen before wheres!
-- from, join, where, group by and aggregation, having, select, distinct, order by, top/limit


--- second task
--- couldve used in ('Tennis Court 2', 'Tennis Court 1')
select bookings.starttime as start, fac.name 
from cd.bookings as bookings
left join  cd.facilities as fac on
bookings.facid = fac.facid
where cast(bookings.starttime as date) = '2012-09-21' 
and fac.name LIKE '%Tennis Court%'
order by bookings.starttime asc


--self joins!
select distinct members.firstname, members.surname from cd.members as members
inner join cd.members as join_members
on members.memid = join_members.recommendedby
order by members.surname asc, members.firstname asc

--- more self join magic
select mem.firstname as memfname, mem.surname as memsname, ref.firstname as recfname, ref.surname as recsname from cd.members as mem
left join cd.members ref
on mem.recommendedby = ref.memid
order by memsname asc, memfname asc
-- left join and left outer join are equivalent


--- multiple joins
select distinct concat(mbs.firstname,' ',mbs.surname) as member, fls.name as facility from cd.members as mbs
inner join cd.bookings as bks
on mbs.memid = bks.memid
left join cd.facilities fls
on bks.facid = fls.facid
where fls.name in ('Tennis Court 1','Tennis Court 2')
order by member asc, facility asc
-- also an option mems.firstname || ' ' || mems.surname as member, for concatenating

--- big headache
--- you can put two where conditions in their own bracket if there's an or between them
--- range conditions can improve query performance
select concat(mbs.firstname, ' ',mbs.surname) as member, fls.name as facility,
case
	when mbs.memid=0 then fls.guestcost*bks.slots
	else fls.membercost*bks.slots
end cost
from cd.bookings as bks
inner join cd.facilities as fls 
on bks.facid = fls.facid
inner join cd.members as mbs
on bks.memid = mbs.memid
where ((bks.memid != 0 and bks.slots*fls.membercost > 30)
	   or (bks.memid=0 and bks.slots*fls.guestcost > 30 ))
and DATE(bks.starttime) = '2012-09-14'
order by cost desc

--- subqueries
-- a correlated query is one that uses a subquery that runs a a query for every row in the set
select distinct concat(mbs.firstname, ' ', mbs.surname) as member ,
case 
	when mbs.recommendedby is not null then (select concat(mbs_sub.firstname, ' ', mbs_sub.surname) from cd.members as mbs_sub where mbs_sub.memid=mbs.recommendedby)
	else null
end recommender
from cd.members as mbs
order by member asc


--- the bit to use a subquery was the filter for price which we didnt need twice
select member, facility, cost from (
	select 
		mems.firstname || ' ' || mems.surname as member,
		facs.name as facility,
		case
			when mems.memid = 0 then
				bks.slots*facs.guestcost
			else
				bks.slots*facs.membercost
		end as cost
		from
			cd.members mems
			inner join cd.bookings bks
				on mems.memid = bks.memid
			inner join cd.facilities facs
				on bks.facid = facs.facid
		where
			bks.starttime >= '2012-09-14' and
			bks.starttime < '2012-09-15'
	) as bookings
	where cost > 30
order by cost desc;          
-- my solution to this 
select member, facility, cost from (select concat(mbs.firstname, ' ',mbs.surname) as member, fls.name as facility,
case
	when mbs.memid=0 then fls.guestcost*bks.slots
	else fls.membercost*bks.slots
end cost
from cd.bookings as bks
inner join cd.facilities as fls 
on bks.facid = fls.facid
inner join cd.members as mbs
on bks.memid = mbs.memid
where DATE(bks.starttime) = '2012-09-14'
order by cost desc) as bookings
where cost > 30