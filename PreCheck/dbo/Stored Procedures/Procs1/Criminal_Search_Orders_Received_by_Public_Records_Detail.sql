-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 09/06/2018
-- Description:	Qreport that measures when criminal searches are made available (after AI Review) to the Public Records team to be worked.
-- execution: EXEC Criminal_Search_Orders_Received_by_Public_Records_Detail '08/15/2018','08/31/2018'
----------------------------------------------------------------
-- Modified date : 03/07/2023
-- Modified By   : Vairavan A
-- Ticket No.     : 3601 
-- Description   : New Qreports for reporting metrics for Public Records - lead count by state details
-- execution: EXEC Criminal_Search_Orders_Received_by_Public_Records_Detail '03/07/2023','03/07/2023'
-- =============================================
CREATE PROCEDURE  Criminal_Search_Orders_Received_by_Public_Records_Detail 
	-- Add the parameters for the stored procedure here
	@StartDate Date,
	@EndDate Date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @serviceName varchar(100) = 'ApplicantService.UpsertApplication'

	--Code commented for ticket no - 3601 starts here 
	/*
	;WITH XMLNAMESPACES (
		   N'http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts' as DC
		   ,N'http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper' as A 
	)

	SELECT  A.Apno AS [Report Number], o.AIMICreatedDate AS [AIMI Created Date], a.CreatedDate AS [Report Created Date], 
			FORMAT(c.Crimenteredtime,'MM/dd/yyyy') AS [Date Criminal Search Rcvd],FORMAT(c.Crimenteredtime,'HH:mm:ss') AS [Criminal Search Rcvd Time],
			--FORMAT(o.AIMICreatedDate,'MM/dd/yyyy') AS [Date Criminal Search Rcvd],FORMAT(o.AIMICreatedDate,'HH:mm:ss') AS [Criminal Search Rcvd Time],
			c.County AS [Search County], x.[Name] AS [Client Name], ra.Affiliate, rct.ClientType AS [Client Type]
	FROM PrecheckServiceLog AS p(nolock)
	INNER JOIN dbo.Appl a(NOLOCK) ON P.APNO	= A.APNO
	INNER JOIN dbo.Crim c(NOLOCK) ON P.APNO	= C.APNO
	INNER JOIN dbo.Client x(NOLOCK) ON p.clientID = x.CLNO	
	INNER JOIN dbo.refAffiliate ra(NOLOCK) ON X.AffiliateID = ra.AffiliateID
	INNER JOIN dbo.refClientType rct(NOLOCK) ON x.ClientTypeID = rct.ClientTypeID
	INNER JOIN [Metastorm9_2].dbo.Oasis AS o(NOLOCK) ON p.APNO = o.APNO
	WHERE --p.ServiceDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
		p.ServiceDate >= @StartDate AND p.ServiceDate <= DateAdd(day, 1, @EndDate)
	  AND (ServiceName = COALESCE(@ServiceName,ServiceName))
	  AND Request.value('(//DC:IncludePublicRecords)[1]','varchar(10)') = 'true'
	  AND Request.value('(//A:Clear)[1]','varchar(1)') = 'R'
	  AND IsNull(Request.value('(//A:SectionID)[1]','varchar(20)'),'') = ''
	ORDER BY a.CreatedDate
	*/
	--Code commented for ticket no - 3601 ends here 
	
	--Code added for ticket no - 3601 starts here 
drop table if exists #tmp

;WITH XMLNAMESPACES (
	 N'http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts' as DC
	,N'http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper' as A 
)

Select   p.apno ,p.clientID	into #tmp
FROM PrecheckServiceLog AS p(nolock)
where 	p.ServiceDate >= @StartDate AND p.ServiceDate <= DateAdd(day, 1, @EndDate)
AND (ServiceName = COALESCE(@ServiceName,ServiceName))
and p.Request.value('(//DC:IncludePublicRecords)[1]','varchar(10)') = 'true'
AND p.Request.value('(//A:Clear)[1]','varchar(1)') = 'R'
AND IsNull(p.Request.value('(//A:SectionID)[1]','varchar(20)'),'') = ''


drop table if exists #tmp2

SELECT  A.Apno AS [Report Number], Cast(NULL as datetime) AS [AIMI Created Date], a.CreatedDate AS [Report Created Date], 
FORMAT(c.Crimenteredtime,'MM/dd/yyyy') AS [Date Criminal Search Rcvd],
FORMAT(c.Crimenteredtime,'HH:mm:ss') AS [Criminal Search Rcvd Time],
c.County AS [Search County], x.[Name] AS [Client Name], ra.Affiliate, rct.ClientType AS [Client Type],c.Crimenteredtime
into #tmp2
FROM #tmp AS p(nolock)
--inner join #tmp as t on(p.apno = t.apno and p.clientID = t.clientID)
INNER JOIN dbo.Appl a(NOLOCK) ON P.APNO	= A.APNO
INNER JOIN dbo.Crim c(NOLOCK) ON P.APNO	= C.APNO
INNER JOIN dbo.Client x(NOLOCK) ON p.clientID = x.CLNO	
INNER JOIN dbo.refAffiliate ra(NOLOCK) ON X.AffiliateID = ra.AffiliateID
INNER JOIN dbo.refClientType rct(NOLOCK) ON x.ClientTypeID = rct.ClientTypeID


Update  a 
set a.[AIMI Created Date] = o.AIMICreatedDate
from #tmp2 a 
INNER JOIN [Metastorm9_2].dbo.Oasis AS o(NOLOCK) ON a.[Report Number] = o.APNO

Update  #tmp2
set [AIMI Created Date]         = Crimenteredtime,
	[Date Criminal Search Rcvd] = FORMAT([AIMI Created Date],'MM/dd/yyyy'),
	[Criminal Search Rcvd Time] = FORMAT([AIMI Created Date],'HH:mm:ss') 

select * 
from #tmp2 
order by [Report Created Date]

	--Code added for ticket no - 3601 ends here 

END

