--- easy start
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values (9, 'Spa', 20, 30, 100000, 800);          

--- multiple rows
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values 
	(9, 'Spa', 20, 30, 100000, 800),
	(10,'Squash Court 2', 3.5, 17.5, 5000, 80);          
-- values generates a table much like select, bit more ergonomic than seelct for multiple rows

--- incrementing the index
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values ((select max(facid) from cd.facilities)+1 , 'Spa', 20, 30, 100000, 800);  
-- in reality use serial column as it autoincrements without having to worry about concurrency

--- update syntax
update cd.facilities 
set initialoutlay=10000
where facid=1

--- update multiple matches
update cd.facilities
set membercost =  6, guestcost = 30
where name LIKE '%Tennis Court%'

--- more updating malarkey
update cd.facilities
set membercost = (select membercost from cd.facilities where facid=0) * 1.1, guestcost = (select guestcost * 1.1 from cd.facilities where facid=0)
where facid = 1
-- ways to update and store the facid = 0 logic using UPDATE...FROM
update cd.facilities facs
    set
        membercost = facs2.membercost * 1.1,
        guestcost = facs2.guestcost * 1.1
    from (select * from cd.facilities where facid = 0) facs2
    where facs.facid = 1;

--- delete all content
truncate table cd.bookings
-- more safe to use 
delete from cd.bookings

--- delete syntax
delete from cd.members 
where memid=37

--- more delete
delete from cd.members
where memid not in (select distinct memid from cd.bookings)
-- alternatively can run a smaller subquery against every row
-- this pattern in general is called a coorelated subquery
delete from cd.members mems where not exists (select 1 from cd.bookings where memid = mems.memid);

