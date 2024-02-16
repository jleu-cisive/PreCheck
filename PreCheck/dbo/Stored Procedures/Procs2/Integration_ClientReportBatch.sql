


--[Integration_ClientReportBatch] 1814,1,'2013-05-23 12:38:44.337'

--
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Integration_ClientReportBatch] 
	-- Add the parameters for the stored procedure here
	@CLNO int, @SPMode int, @DATEREF datetime
AS
BEGIN

DECLARE @DATESTART datetime;
SET @DATEREF =   DATEADD(mi,-10,@DATEREF);
SET @DATESTART = DATEADD(mi,-60,@DATEREF);


--set @DATESTART = '2013-05-15 18:38:44.337'
--set @DATEREF = '2013-05-23 16:38:44.337'

IF(@SPMODE = 1)
BEGIN
SELECT  a.clientAPNO,b.backgroundreport FROM appl a (NOLOCK) 
left outer join [ala-sql-05].backgroundreports.dbo.backgroundreport
b (NOLOCK) on b.apno = a.apno
where a.apstatus = 'F' and a.clno = @CLNO and 
ISNULL(clientapno,'') <> '' and a.compdate >= @DATESTART and a.compdate < @DATEREF 
--((ISNULL(clientapno,'') <> ''  and a.compdate >= @DATESTART and a.compdate < @DATEREF )
--or  ISNULL(clientapno,'') in ('25297','23052','12554','19292','23482'))
and b.createdate in (select max(b.createdate) from [ala-sql-05].backgroundreports.dbo.backgroundreport b  
inner join appl a
on b.apno = a.apno where a.apstatus = 'F' and a.clno = @CLNO and 
isnull(clientapno,'') <> '' 
--(ISNULL(clientapno,'') <> '' or  ISNULL(clientapno,'') = '18453')
group by b.Apno )
order by b.createdate desc

END


END






