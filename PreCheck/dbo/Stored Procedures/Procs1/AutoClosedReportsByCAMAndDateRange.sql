-- =============================================
-- Author:		Prasanna
-- Create date: 07/14/2015
-- Description:	Get reports that were closed utilizing the AutoClose solution
-- Modified by Radhika Dereddy on 08/07/2017 -  adjust the CLNO parameter to allow to search all clients as well as single client numbers
-- Modified the parameters CLNO varchar(20) to int, StartDate and endDate from varchar to datetime and CAM to varchar(8)
-- Modified by Aashima on 19/08/2022 - Added to additional columns in output dataset, [ReopenDate] and [Original Close date]
-- EXEC AutoClosedReportsByCAMAndDateRange 0, null, '01/01/2017', '06/30/2017'
-- EXEC AutoClosedReportsByCAMAndDateRange 0,'HROCServ', '08/01/2017', '08/04/2017','4:294'
-- =============================================


CREATE PROCEDURE [dbo].[AutoClosedReportsByCAMAndDateRange] 
	@Clno int,
	@CAM varchar(8),
	@startdate datetime,
	@enddate datetime,
	@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221
AS
BEGIN
	
	set @CAM = Coalesce(@CAM , NULL);
	--commented the below section to pull the appropriate results -RD 08/07/2017
	--set @Clno= Coalesce(@Clno , NULL);	
	--set @startDate = Coalesce(@startDate , '01/01/1900');
	--set @endDate = Coalesce(@enddate , GetDate());

	
	--code added by vairavan for ticket id -67221 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -67221 ends

	select aacLog.apno as [Application Number],appl.clno as [Client ID],c.Name as ClientName,appl.UserID,appl.apDate as [Date Of Application],
	aacLog.ClosedOn as [Date Closed], 
	FORMAT(appl.ReopenDate,'MM/dd/yyyy hh:mm tt') as [ReopenDate],
	FORMAT(appl.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS [Original Close date]
	from ApplAutoCloseLog aacLog 
	inner join Appl appl on aacLog.apno = appl.apno 
	inner join Client c on c.clno = appl.clno
	where appl.CLNO = IIF(@CLNO=0,appl.CLNO,@CLNO)
	and (@CAM is null or appl.UserID like '%' + @CAM + '%')		
	and (aacLog.ClosedOn between @startdate and DATEADD(d,1,@EndDate))
	and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221

	--commented the below section to pull the appropriate results -RD 08/07/2017
	-- appl.Clno = '' or appl.clno = @Clno	
	--and convert(date, aacLog.ClosedOn, 120) between @startdate and @enddate;


END

