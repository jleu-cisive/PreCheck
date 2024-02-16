﻿-- =============================================
-- Author: Radhika Dereddy
-- Create date: unknown
-- Modified Date: 06/19/2018
-- Description:	Add a new column called Vendor to the stored Procedure. Changing an inline query to a stored procedure.
-- Exec Crim_Pending_Counts_byStatus_byDelivery
-- =============================================
CREATE PROCEDURE [dbo].[Crim_Pending_Counts_byStatus_byDelivery] 
	-- Add the parameters for the stored procedure here
	@Deliverymethod varchar(50) =''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select a.apno,a.apdate,a.apstatus,a.last,a.first,c.county,ir.R_Name as 'Vendor', case when c.clear = 'O' then 'Ordered'
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
inner join Iris_Researchers ir with(nolock) on c.vendorid = ir.R_Id
where isnull(a.apstatus,'P') in ('P','W')
and isnull(c.clear,'') not in ('F','T','P') and c.Clear IS NOT NULL
and c.ishidden = 0
and isnull(c.deliverymethod,'') like ('%' + @Deliverymethod + '%')
order by crimid asc


END
