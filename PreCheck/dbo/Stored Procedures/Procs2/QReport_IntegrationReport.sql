-- =============================================
-- Author:		Prasanna Kumari
-- Create date: 04/12/2021>
-- Description:	Information for all transactions to/from iCIMS integration for the date range HDT#87080
-- EXEC QReport_IntegrationReport 13126,'03/01/2021','03/31/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_IntegrationReport] 
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tempCLNO
	(
		CLNO int
	)

	 INSERT INTO #tempCLNO
	 select ISNULL(WebOrderParentCLNO, @CLNO) from dbo.client(nolock) where CLNO = @CLNO

	select distinct isnull(apst.FirstName,'')+' '+isnull(apst.MiddleName,'')+' '+isnull(apst.LastName,'') as [Candidate Name],
		 apst.ClientCandidateId as CandidateId, asd.AppStatusValue [Status], iomr.RequestDate [Date],
		 Isurl.Url [ICIMS API Call] 
	from dbo.Integration_OrderMgmt_Request iomr (nolock)
	inner join dbo.Integration_StatusUpdate_Urls Isurl(nolock) on  iomr.RequestID = Isurl.Apno
	inner join dbo.Appl a(nolock) on a.APNO = iomr.APNO
	inner join dbo.AppStatusDetail(nolock) asd on a.ApStatus = asd.AppStatusItem
	inner join Enterprise.staging.OrderStage os(nolock) on  os.IntegrationRequestId  = iomr.RequestID
	inner join Enterprise.staging.Applicantstage apst(nolock) on apst.StagingOrderId = os.StagingOrderId
	where iomr.CLNO in (select CLNO from #tempCLNO)
	and iomr.RequestDate >= @StartDate and iomr.RequestDate <= @EndDate
	order by Date

END
