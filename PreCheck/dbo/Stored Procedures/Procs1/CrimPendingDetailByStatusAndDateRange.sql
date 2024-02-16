
---[dbo].[CrimPendingDetailByStatusAndDateRange] 'V', '02/20/2017', '02/28/2017'
CREATE PROCEDURE [dbo].[CrimPendingDetailByStatusAndDateRange] 
	-- Add the parameters for the stored procedure here

@CrimStatus varchar(50) = '',
@StartDate DateTime,
@EndDate DateTime
AS
BEGIN
	
select a.apno,a.UserID CAM,a.apdate,a.apstatus,a.last,a.first,'"' +c.county + '"' county, 
		case when c.clear = 'O' then 'Ordered'
			when c.clear = 'R' then 'Pending'
			when c.clear = 'W' then 'Waiting'
			when c.clear = 'X' then 'Error Getting Results'
			when c.clear = 'E' then 'Error Sending Order'
			when c.clear = 'M' then 'Ordering'
			when c.clear = 'V' then 'Vendor Reviewed'
			when c.clear = 'I' then 'Transferred Record'
			when c.clear = 'N' then 'Alias Name Ordered'
			when c.Clear = 'D' then 'Review Reportability'
			when c.Clear = 'Z' then 'Needs Research'
			when c.Clear = 'Q' then 'Needs QA'
			else c.clear end as 'crimstatus',
	c.Crimenteredtime as CrimEnteredTime,
	c.Ordered as CrimOrderedDateTime,
	c.deliverymethod, 
	case when c.deliverymethod <> 'web service' then max(cv.EnteredDate)
	else 
		case when  max(i.updated_on) is null then max(c.Crimenteredtime)
		else DATEADD(hh, -7,  max(i.updated_on) ) -- utc time conversion to cst
		end
	end as 'Vendor entered',
	case when c.IsHidden = 0 then 'false' else 'true' end as 'Is Hidden',
	case when c.Clear <> null then 'true' else 'false' end as  'Is On Report'
from appl a with (nolock)
inner join crim c with (nolock) on a.apno = c.apno
left outer join iris_ws_screening i  with (nolock) on c.CrimID = i.crim_id
left outer join CriminalVendor_Log cv on c.apno = cv.apno and c.cnty_no = cv.CNTY_NO
where isnull(a.apstatus,'P') in ('P','W')
and isnull(c.clear,'') not in ('F','T','P')
and c.ishidden = 0
and isnull(c.clear,'') like ('%' + @CrimStatus + '%')
and c.Last_Updated > @StartDate and c.Last_Updated < DateAdd(day, 1, @EndDate)
group by  a.apno,a.UserID,a.apdate,a.apstatus,a.SSN,a.last,a.first,c.county,c.clear, c.deliverymethod, c.crimid, a.dob, c.IrisOrdered, c.Crimenteredtime, c.Ordered, c.IsHidden, c.Clear
order by c.crimid asc





END

