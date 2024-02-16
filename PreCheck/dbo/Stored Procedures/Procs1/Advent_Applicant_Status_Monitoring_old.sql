-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 07/19/2019
-- Description:	A cumulative report showing all of the reports which Advent has ever initiated/completed and should be added to each day
-- Execution: EXEC Advent_Applicant_Status_Monitoring 15355
-- Modified by Humera Ahmed on 3/18/2020 for HDT#69475 Please provide list of what the different status codes (letters, numbers etc.) and their meaning - ex. F=Final
-- Modified by Andrew Seyboldt on 03/15/2021 to fine tune the procedure by adding the indexes to Integration_OrderMgmt_Request
-- Modifed by Radhika Dereddy on 03/18/2021 by removing the view Enterprise.Report.InvitationTurnaroun to its own tables and the query now runs in 33 secs which was ealier taking 30mins
-- =============================================
CREATE PROCEDURE [dbo].[Advent_Applicant_Status_Monitoring_old] 
	-- Add the parameters for the stored procedure here
--@CLNO int = 15355
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ETAPastTrigger date = GETDATE()	
	DECLARE @StartDate Date = CONVERT(DATE, DATEADD(m, -6, GetDate()))

	DROP TABLE IF EXISTS #tmpIntegrationRequestDetails
	DROP TABLE IF EXISTS #tmpETADates
	DROP TABLE IF EXISTS #tempRequests
	
	SELECT  r.clno,
			r.Request,
			r.TransformedRequest,
			r.APNO,
			r.FacilityCLNO
	INTO #tempRequests
	FROM Integration_OrderMgmt_Request R(NOLOCK) 
	WHERE R.CLNO = 15355
	AND R.RequestDate >= @StartDate 

	SELECT	Request.n.value('RequisitionNumber[1]','VARCHAR(30)') AS RequisitionNumber,  
			Request.n.value('ClientApplicationNumber[1]','VARCHAR(30)') AS TransactionID,  
			Request.n.value('CandidateID[1]','VARCHAR(30)') AS CandidateID,
			Request.n.value('RequisitionJobCode[1]','VARCHAR(30)') AS FacilityNumber,  
			Request.n.value('PrimaryLocationCodeDescription[1]','VARCHAR(100)') AS PrimaryLocationCodeDescription,  
			Request.n.value('Last[1]','VARCHAR(50)') AS LastName,
			Request.n.value('First[1]','VARCHAR(50)') AS FirstName,
			R.APNO,
			Request.n.value('Attn[1]','VARCHAR(50)') AS Attn,
			R.FacilityCLNO
		INTO #tmpIntegrationRequestDetails
	FROM Integration_OrderMgmt_Request R(NOLOCK)
	CROSS APPLY TransformedRequest.nodes('//NewApplicant[1]') AS Request(n) 

	--SELECT * FROM #tmpIntegrationRequestDetails

	SELECT T.APNO, MAX(E.ETADate) AS [Report ETA]
		INTO #tmpETADates
	FROM #tmpIntegrationRequestDetails AS T
	INNER JOIN ApplSectionsETA AS E(NOLOCK) ON T.APNO = E.Apno
	GROUP BY T.APNO

	--SELECT * FROM #tmpETADates

	SELECT	A.[First] AS [Applicant First Name],
			a.[Last] AS [Applicant Last Name],   
			X.CandidateID, 
			X.RequisitionNumber AS [Requisition ID],
			F.FacilityName AS [Facility Name],
			X.Attn AS [Preboarding Specialist],
			A.APNO AS [Report Number],
			CASE 
				WHEN A.ReopenDate IS NOT NULL THEN 'R (Re-opened)' 
											  ELSE (SELECT asd.AppStatusItem+' ('+asd.AppStatusValue+')' FROM dbo.AppStatusDetail asd WHERE asd.AppStatusItem = A.ApStatus) 
			END [Report Status],
			FORMAT(os.CreateDate,'MM/dd/yyyy hh:mm tt') AS [CIC Invite Sent],
			FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm tt') AS [CIC Invite Completed],
			FORMAT(C.ClientCertUpdated,'MM/dd/yyyy hh:mm tt') AS [Certification Completed],
			CASE 
				WHEN DATEDIFF(d, @ETAPastTrigger, CONVERT(varchar, Y.[Report ETA], 101)) < 0 THEN 'ETA Unavailable'
				WHEN DATEDIFF(d, @ETAPastTrigger, CONVERT(varchar, Y.[Report ETA], 101)) >= 0 THEN CONVERT(varchar, Y.[Report ETA], 101)
			END AS [Report ETA],
			CASE 
				WHEN A.ApStatus != 'F' THEN [dbo].[ElapsedBusinessDays_2](A.ApDate,CURRENT_TIMESTAMP) 
				WHEN A.ApStatus = 'F' THEN [dbo].[ElapsedBusinessDays_2](A.ApDate,A.OrigCompDate) 
			END	AS [Turnaround Time]
	FROM #tmpIntegrationRequestDetails X
	INNER JOIN Appl A(NOLOCK) ON X.APNO = A.APNO
	INNER JOIN Client cl(NOLOCK) ON A.CLNO = cl.CLNO
	LEFT OUTER JOIN HEVN.dbo.Facility AS F(NOLOCK) ON X.FacilityCLNO = F.FacilityCLNO
	LEFT OUTER JOIN ClientCertification C(NOLOCK) ON A.APNO = C.APNO
	LEFT OUTER JOIN #tmpETADates AS Y(NOLOCK) ON A.APNO = Y.Apno
	--LEFT OUTER JOIN Enterprise.Report.InvitationTurnaround AS it(NOLOCK) ON A.APNO = IT.OrderNumber
	LEFT OUTER JOIN Enterprise..[Order] AS O(NOLOCK) ON O.OrderNumber = A.APNO and O.DASourceId=2
	INNER JOIN Enterprise.Staging.OrderStage AS os(NOLOCK) ON O.OrderID = os.OrderID 
	WHERE cl.WebOrderParentCLNO = 15355
	--A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE WebOrderParentCLNO = 15355)
	  AND A.ApStatus != 'M'


END
