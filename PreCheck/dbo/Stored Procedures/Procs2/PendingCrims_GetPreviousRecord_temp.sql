create PROCEDURE [dbo].[PendingCrims_GetPreviousRecord_temp]
	@county varchar (200),
	@ssn varchar(11),
	@apno int = null
AS
BEGIN
	
--select a.apno,c.IrisOrdered apdate,c.crimid, a.inuse, c.county, c.offense,c.caseNo
--from dbo.appl a with (nolock)
--inner join dbo.crim c with (nolock) on a.apno = c.apno
----inner join dbo.client cl on a.clno = cl.clno
----left outer join dbo.iris_ws_screening i  with (nolock) on c.CrimID = i.crim_id
----left outer join dbo.CriminalVendor_Log cv on c.apno = cv.apno and c.cnty_no = cv.CNTY_NO

--where isnull(a.apstatus,'P') in ('P','W')
----and (a.inuse is null or a.inuse = '')
----and isnull(c.clear,'') not in ('F','T','P')
--and c.ishidden = 0
--and isnull(c.clear,'') = 'i'
--and ( c.county = @county and a.SSN = @ssn)


----group by  a.apno,a.apdate,a.SSN,a.last,a.first,c.county,c.clear, c.deliverymethod, cl.clno, cl.name, c.crimid, a.dob, c.IrisOrdered, c.admittedrecord, a.inuse, c.offense
--order by a.apno 

--Transferred Records
select a.apno,c.IrisOrdered apdate,c.crimid, a.inuse, c.county, c.offense,c.caseNo,'T' RecordType
from dbo.appl a with (nolock)
inner join dbo.crim c with (nolock) on a.apno = c.apno
where isnull(a.apstatus,'P') in ('P','W')
and c.ishidden = 0
and isnull(c.clear,'') = 'i'
and ( c.county = @county and a.SSN = @ssn ) --and a.apno=@apno)
UNION ALL
--Previous Records
select a.apno,c.IrisOrdered apdate,c.crimid, a.inuse, c.county, c.offense,c.caseNo,'P' RecordType
from dbo.appl a with (nolock)
inner join dbo.crim c with (nolock) on a.apno = c.apno
where --c.ishidden = 0 and
 isnull(c.clear,'') in ('F','T','P')
and ( c.county = @county and a.SSN = @ssn and a.apno<>isnull(@apno,0))

END