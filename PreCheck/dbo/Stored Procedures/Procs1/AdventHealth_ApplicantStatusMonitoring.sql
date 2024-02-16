
-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 07/19/2019
-- Description:	A cumulative report showing all of the reports which Advent has ever initiated/completed and should be added to each day
-- Execution: EXEC [AdventHealth_ApplicantStatusMonitoring] 15355
-- Modified by Humera Ahmed on 3/18/2020 for HDT#69475 Please provide list of what the different status codes (letters, numbers etc.) and their meaning - ex. F=Final
-- Modified by Andy on 03/15/2021 by adding an index to Integration_OrderMgmt_Request table
-- added a temprequest table for performance.
-- Modfied by Doug Degenaro on 6/07/2021 for HDT#7290 To change 6 months to 3 months back
-- Modified by Prasanna Kumari on 8/24/2021 for HDT#15449 to change the column value for "CIC Invite Completed" to update from ApplicantConsent table
-- =============================================
CREATE PROCEDURE [dbo].[AdventHealth_ApplicantStatusMonitoring] 
	-- Add the parameters for the stored procedure here
@Clno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @ETAPastTrigger date = GETDATE()	
	DECLARE @StartDate Date = CONVERT(DATE, DATEADD(m, -3, GetDate())) --for HDT#7290 To change 6 months to 3 months back


	DROP TABLE IF EXISTS #tmpIntegrationRequestDetails
	DROP TABLE IF EXISTS #tmpETADates
	DROP TABLE IF EXISTS #tempRequests
	DROP TABLE IF EXISTS #tmpResults
	
	SELECT  r.clno,
			r.Request,
			r.TransformedRequest,
			r.APNO,
			r.FacilityCLNO
	INTO #tempRequests
	FROM Integration_OrderMgmt_Request R(NOLOCK) 
	WHERE R.CLNO = @CLNO
	AND R.RequestDate>= @StartDate 

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
	FROM #tempRequests R
	CROSS APPLY R.TransformedRequest.nodes('//NewApplicant[1]') AS Request(n) 
	


	--SELECT * FROM #tmpIntegrationRequestDetails

	SELECT T.APNO, MAX(E.ETADate) AS [Report ETA]
		INTO #tmpETADates
	FROM #tmpIntegrationRequestDetails AS T
	INNER JOIN ApplSectionsETA AS E(NOLOCK) ON T.APNO = E.Apno
	GROUP BY T.APNO

	--SELECT * FROM #tmpETADates

	SELECT distinct X.CandidateID, 
			A.[First] AS [Applicant First Name],
			a.[Last] AS [Applicant Last Name],
			X.RequisitionNumber AS [Requisition ID],
			F.FacilityName AS [Facility Name],
			X.Attn AS [Preboarding Specialist],
			A.APNO AS [Report Number],	
			aps.ApplicantId As [ApplicantId],			
			CASE 
				WHEN A.ReopenDate IS NOT NULL THEN 'R (Re-opened)' 
											  ELSE (SELECT asd.AppStatusItem+' ('+asd.AppStatusValue+')' FROM dbo.AppStatusDetail asd WHERE asd.AppStatusItem = A.ApStatus) 
			END [Report Status],
			FORMAT(os.CreateDate,'MM/dd/yyyy hh:mm tt') AS [CIC Invite Sent],
			FORMAT(C.ClientCertUpdated,'MM/dd/yyyy hh:mm tt') AS [Certification Completed],
			CASE 
				WHEN DATEDIFF(d, @ETAPastTrigger, CONVERT(varchar, Y.[Report ETA], 101)) < 0 THEN 'ETA Unavailable'
				WHEN DATEDIFF(d, @ETAPastTrigger, CONVERT(varchar, Y.[Report ETA], 101)) >= 0 THEN CONVERT(varchar, Y.[Report ETA], 101)
			END AS [Report ETA],
			CASE 
				WHEN A.ApStatus != 'F' THEN [dbo].[ElapsedBusinessDays_2](A.ApDate,CURRENT_TIMESTAMP) 
				WHEN A.ApStatus = 'F' THEN [dbo].[ElapsedBusinessDays_2](A.ApDate,A.OrigCompDate) 
			END	AS [Turnaround Time]
    INTO #tmpResults
	FROM #tmpIntegrationRequestDetails X
	INNER JOIN Appl A(NOLOCK) ON X.APNO = A.APNO
	INNER JOIN Client Cl(NOLOCK) ON A.CLNO = Cl.CLNO
	LEFT OUTER JOIN HEVN.dbo.Facility AS F(NOLOCK) ON X.FacilityCLNO = F.FacilityCLNO
	LEFT OUTER JOIN ClientCertification C(NOLOCK) ON A.APNO = C.APNO
	LEFT OUTER JOIN #tmpETADates AS Y(NOLOCK) ON A.APNO = Y.Apno
	LEFT OUTER JOIN Enterprise..[Order] AS O(NOLOCK) ON O.OrderNumber = A.APNO and O.DASourceId=2
	INNER JOIN Enterprise.Staging.OrderStage AS os(NOLOCK) ON o.OrderID = os.OrderID 
	INNER JOIN Enterprise.Staging.ApplicantStage AS aps(NOLOCK) ON aps.ApplicantNumber = a.APNO
	WHERE Cl.WebOrderParentCLNO = @CLNO
	  AND A.ApStatus != 'M'


	SELECT t1.CandidateID,t1.[Applicant First Name],t1.[Applicant Last Name],t1.[Requisition ID],t1.[Facility Name],
		t1.[Preboarding Specialist],t1.[Report Number],t1.[Report Status],t1.[CIC Invite Sent], t2.CreateDate as [CIC Invite Completed],
		t1.[Certification Completed], t1.[Report ETA], t1.[Turnaround Time]
	FROM
		#tmpResults t1
	INNER JOIN
	(
		SELECT ApplicantConsentId, ApplicantId,CreateDate,rownumber
		FROM
		(
		  SELECT ApplicantConsentId, ApplicantId,CreateDate,    
		   ROW_NUMBER() OVER (PARTITION BY ApplicantId ORDER BY ApplicantConsentId DESC) AS rownumber
		  FROM Enterprise..ApplicantConsent AC
		) tmp
	WHERE rownumber = 1
	) t2 
	ON t1.ApplicantId = t2.ApplicantId
	order by CandidateID


END
