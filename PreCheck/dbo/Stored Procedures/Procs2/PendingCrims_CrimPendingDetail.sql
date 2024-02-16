CREATE PROCEDURE [dbo].[PendingCrims_CrimPendingDetail]

	-- Add the parameters for the stored procedure here

AS

BEGIN

	

select a.apno,a.apdate,a.SSN,a.last,a.first,c.county, cs.crimdescription 'crimstatus',

c.deliverymethod, cl.clno, cl.name, c.CrimID, a.DOB, c.IrisOrdered as 'OrderedDate',c.admittedrecord , a.inuse,

case when c.deliverymethod <> 'web service' then max(cv.EnteredDate)

else 

	case when max(i.updated_on) is null then max(c.Crimenteredtime)

	else DATEADD(hh, -7,  max(i.updated_on) ) -- utc time conversion to cst

	end

end

as 'Vendor entered',count(case when c.[clear] = 'i' then 1 else 0 end) TransferredRecordCount

from appl a with (nolock)

inner join crim c with (nolock) on a.apno = c.apno

inner join client cl on a.clno = cl.clno

left outer join iris_ws_screening i  with (nolock) on c.CrimID = i.crim_id

left outer join CriminalVendor_Log cv on c.apno = cv.apno and c.cnty_no = cv.CNTY_NO

left outer join dbo.crimsectstat cs on c.clear = cs.crimsect



where isnull(a.apstatus,'P') in ('P','W')

--and (a.inuse is null or a.inuse = '')

--and isnull(c.clear,'') not in ('F','T','P')

and c.ishidden = 0

and isnull(c.clear,'') in ('v', 'z', 'D', 'P')





group by  a.apno,a.apdate,a.SSN,a.last,a.first,c.county, cs.crimdescription, c.deliverymethod, cl.clno, cl.name, c.crimid, a.dob, c.IrisOrdered, c.admittedrecord, a.inuse

order by IrisOrdered asc

END
