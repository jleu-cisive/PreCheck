/*---------------------------------------------------------------------------------   
Previous information is not available 
  
ModifiedBy		ModifiedDate	TicketNo	Description  
Shashank Bhoi	03/16/2023		84621		#84621  include both affiliate 4 (HCA) & 294 (HCA Velocity).   
											EXEC dbo.GetClientProcessJobRequirement 7519,'0'
*/---------------------------------------------------------------------------------  
CREATE PROCEDURE DBO.GetClientProcessJobRequirement  
(@CLNO Int = 0,@ProcessLevel varchar(10) = 0)  
AS  
--Code commenetd by Shashank for ticket id -#84621
--select * from precheck.config.ClientProcessJobRequirement (nolock)  
--where (ParentCLNO = @CLNO OR @CLNO =0) and (ProcessLevel =@ProcessLevel or @ProcessLevel = '0')   
--order by ProcessLevel

--Code Added by Shashank for ticket id -#84621
select  CPJR.*
FROM	precheck.config.ClientProcessJobRequirement (NOLOCK)  AS CPJR
		LEFT JOIN Precheck.dbo.Client (NOLOCK)					AS C ON CPJR.ParentCLNO = C.CLNO
where (CPJR.ParentCLNO = @CLNO OR @CLNO =0) and (ProcessLevel =@ProcessLevel or @ProcessLevel = '0')
		AND C.AffiliateID IN (4, 294)
order by ProcessLevel
