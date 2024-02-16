-- ============================================================================
-- Author:		Prasanna
-- Create date: 10/12/2018
-- Description:	For some additional tracking within the PR department
-- Exec [dbo].[AIMS_PublicRecords_Log_Summary] 2480,'09/11/2018','09/12/2018'
-- =========================================================================
CREATE PROCEDURE [dbo].[AIMS_PublicRecords_Log_Summary] 
	-- Add the parameters for the stored procedure here
	@countyid varchar(10),
	@startdate varchar(20),
	@enddate varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	--DECLARE @tmpPublicRecordsLog TABLE(Total_Request_Items int, Total_Response_Items int,Total_Records int,Total_Clears int,Total_Exceptions int,Total_Hits int)
	
	--INSERT INTO @tmpPublicRecordsLog(Total_Request_Items,Total_Response_Items,Total_Records,Total_Clears,Total_Exceptions,Total_Hits)
	SELECT * --cr.Crimenteredtime,DateLogRequest,cr.CrimID,*
		--cast(Request as xml).value('(count(//Item))[1]','int') Total_Request_Items,cast(Response as xml).value('(count(//Item))[1]','int') Total_Response_Items,
	--Total_Records, Total_Clears, Total_Exceptions, cast(Response as xml).value('count(//NoRecord[not(text())])', 'int') Total_Hits 
	From dbo.DataXtract_Logging AS l(Nolock) 
	--INNER JOIN Crim cr(nolock) ON l.SectionKeyId = cr.CNTY_NO AND cr.IsHidden = 0
	Where Section = 'Crim' 
	  and SectionKeyID = @countyid 
	  and DateLogRequest between @startdate and DateAdd(d,1,@enddate)
	  --and cr.Crimenteredtime between @startdate and DateAdd(d,1,@enddate)
	order by l.DateLogRequest ASC

	--select * from @tmpPublicRecordsLog


	--Select [DataXtract_LoggingId],l.SectionKeyId, ResponseError, ResponseStatus, DateLogRequest,DateLogResponse,LogUser,cast(Request as xml).value('(count(//Item))[1]','int') Total_Request_Items,
	--cast(Response as xml).value('(count(//Item))[1]','int') Total_Response_Items,count(cr.CrimID) AS [Total County Searches],c.County,sum(l.Total_Records) as Total_Records, sum(l.Total_Exceptions) as Total_Exceptions, sum(l.Total_Clears) as Total_Clears, cast(Response as xml).value('count(//NoRecord[not(text())])', 'int') Total_Hits
	--From dbo.DataXtract_Logging l (nolock)
	--inner join Counties c(nolock) on l.SectionKeyId = c.CNTY_NO
	--INNER JOIN Crim cr(nolock) ON cr.CNTY_NO = c.CNTY_NO
	--Where SectionKeyID in (select SectionKeyId from Dataxtract_RequestMapping where Section ='Crim') 
	--and DateLogRequest between @datefrom and DateAdd(d,1, @dateto)
	--group by [DataXtract_LoggingId],l.SectionKeyId, c.County,SectionKeyId, ResponseError, ResponseStatus, DateLogRequest,DateLogResponse,LogUser,Request,Response,Total_Records, Total_Clears, Total_Exceptions
	--order by DateLogRequest ASC

END
