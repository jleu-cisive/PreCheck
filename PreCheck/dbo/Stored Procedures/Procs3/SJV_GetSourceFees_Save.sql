﻿-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 07/15/2019
-- Description:	Show source and fees for SJV submissions between two dates
-- dbo.SJV_GetSourceFees '07/01/2019','07/20/2019',0
-- =============================================
CREATE PROCEDURE [dbo].[SJV_GetSourceFees_Save] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime = 0, 
	@EndDate datetime = 0,
	@OnlyShowWithFees bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #SourceFeesbyEmployer 
	(
		Apno int,
		EmplId int,
		Employer varchar(50),
		Source varchar(20),
		SourceFee float,
		Description varchar(400),
		Amount float
	)

 BEGIN
insert into #SourceFeesbyEmployer
select distinct
	--o.Integration_VendorOrderId as Id,
	e.APNO,
	e.EmplId,	
	e.Employer,
	t1.a.value('SourceFeeText[1]','varchar(20)')  as [Source],	
	t1.a.value('SourceFee[1]','float') as Fee,
	id.Description,
	id.Amount	
from 
	dbo.Integration_VendorOrder o 
	cross apply Response.nodes('//Result[1]') as t1(a)
inner join dbo.empl e on e.OrderId = o.Request.value('(//SubjectCtyID)[1]','char(30)') 
inner join dbo.InvDetail id on id.APNO = e.APNO 
where o.VendorOperation='Completed'
and o.VendorName='SJV'  
and ((convert(date,o.CreatedDate) >= @StartDate) and (convert(date,o.CreatedDate) <= @EndDate)) 
and id.Type in (1,6)
--and id.Description like 'Employment:%'--and e.APNO = 4657837
order by Apno,Emplid 
END

 if (@OnlyShowWithFees = 0)
	 select * from #SourceFeesbyEmployer t
	where t.Source = RTRIM(LTRIM(REPLACE(t.Description,'Employment:','')))
else
	select * from #SourceFeesbyEmployer t
	where t.Source = RTRIM(LTRIM(REPLACE(t.Description,'Employment:','')))  
	and (IsNull(Source,'') <> '' and IsNull(SourceFee,'') <> '')

drop table #SourceFeesbyEmployer
END
