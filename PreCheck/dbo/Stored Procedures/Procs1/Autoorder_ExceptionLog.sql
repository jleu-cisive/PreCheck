

--EXEC Precheck.[dbo].[Autoorder_ExceptionLog] '08/26/2014','08/26/2014'

-- =============================================
-- Author:		Kiran Miryala
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Autoorder_ExceptionLog]
	-- Add the parameters for the stored procedure here	
	@StartDate DateTime,
	@EndDate Datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
select  exLog.Apno, c.CLNO, c.Name, a.EnteredVia, a.EnteredBy, src.Source,rules.[Description],exlog.LogDate from ApplCountiesExceptionLog exLog
 inner join BRSources src on exLog.SourceID = src.SourceID 
 inner join BRAutoOrderRules rules on exLog.RuleID = rules.RuleID
 inner join Appl a on exLog.Apno = a.apno
 inner join Client c on a.CLNO = c.CLNO
 where --apno=@Apno
 (LogDate between @StartDate and (dateadd(s,-1,dateadd(d,1,@EndDate))))

 End