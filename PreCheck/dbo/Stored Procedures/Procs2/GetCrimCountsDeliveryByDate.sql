-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.GetCrimCountsDeliveryByDate
	-- Add the parameters for the stored procedure here
	@StartDate Date,
	@EndDate Date
	
AS
BEGIN


select a.apno,a.apdate, c.IrisOrdered as 'Ordered Date', a.apstatus,a.last,a.first,c.county,case when c.clear = 'O' then 'Ordered'
when c.clear = 'R' then 'Pending'
when c.clear  = 'W' then 'Waiting'
when c.clear = 'X' then 'Error Getting Results'
when c.clear = 'E' then 'Error Sending Order'
when c.clear = 'M' then 'Ordering'
when c.clear = 'V' then 'Vendor Reviewed'
when c.clear = 'I' then 'Needs Research'
when c.clear = 'N' then 'Alias Name Ordered'
else c.clear end as 'crimstatus',
c.deliverymethod
from appl a with (nolock)
inner join crim c with (nolock) on a.apno = c.apno
where c.ishidden = 0
and    ((Convert(date, c.IrisOrdered)>= CONVERT(date, @StartDate)) 
  AND (Convert(date, c.IrisOrdered) <= CONVERT(date, @EndDate)))
order by crimid asc
END
