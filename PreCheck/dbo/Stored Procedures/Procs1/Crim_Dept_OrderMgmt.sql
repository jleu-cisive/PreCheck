



-- =============================================
-- Author:		Prasanna
-- Create date: 02/23/2015
-- Description:	Report to show the time that a criminal search was input into the order management queue
-- =============================================
--[dbo].[Crim_Dept_OrderMgmt] '5/14/2015','5/15/2015'

CREATE  PROCEDURE [dbo].[Crim_Dept_OrderMgmt] 
	@StartDate DateTime, 
	@EndDate DateTime 

as
BEGIN

	select c.apno,c.County, convert(varchar, c.Ordered, 107) as Ordered from Crim c with(NOLOCK) 
	inner join Crim_Review cr with(NOLOCK)  on c.CrimID = cr.CrimID
	Inner join dbo.Appl a on c.APNO = a.APNO 	
	where c.Clear not in('T','F') and (convert(varchar, c.Ordered, 107) >= @StartDate and convert(varchar, c.Ordered, 107) <= @EndDate)	
	and CLNO not in (2134,3468) 
	group by c.apno,convert(varchar, c.Ordered, 107),c.County
	order by c.Apno

END
