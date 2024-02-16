-- =============================================
-- Author:		Dongmei he
-- Create date: 3/15/2022
-- Description:	Populates/Sync OrderSummary table
-- Modify By: Gaurav Bangia
-- Modify Date: 3/30/2022
-- =============================================
CREATE PROCEDURE [StudentCheck].[SyncOrderSummaryInsert] --null, null
	 @StartDate	DATETIME	= NULL
	,@EndDate		DATETIME	= NULL
AS
BEGIN TRY
	--SET NOCOUNT ON;
	DECLARE @dateRange VARCHAR(500) = Concat(@startdate, ' - ', @enddate)
	EXEC Enterprise.Job.WriteToTraceLog @Component='SCDsh', -- varchar(5)
	    @TaskName='StudentCheck.SyncOrderSummaryInsert', -- varchar(50)
	    @Message=@dateRange, -- varchar(2000)
	    @TraceLevel='INFO' -- varchar(10)
	
	INSERT INTO Report.OrderSummary (
		 OrderNumber
		,Applicant_FirstName
		,Applicant_LastName
		,Applicant_MiddleName
		,Applicant_UID
		,OrderCreateDate
		,ClientId
		,ProgramId
		,ProgramName
		,ApDate
		,HasBackground
		,HasDrugScreen
		,HasImmunization
		,BG_OrderStatusId
		,BG_CompleteDate
		,BG_ResultId
		,BG_OrderStatus
		,BG_Result
		,DT_OrderStatusId
		,DT_CompleteDate
		,DT_ResultId
		,DT_OrderId
		,DT_OrderStatus
		,DT_Result
		,DT_ReportId
		,IM_OrderStatusId
		,IM_ResultId
		,IM_OrderStatus
		,IM_Result
		,OrderStatusId
		)
	SELECT  AP.APNO
		,LTRIM(RTRIM(ap.First))
		,LTRIM(RTRIM(ap.Last))
		,LTRIM(RTRIM(ap.Middle))
		,REPLACE(ap.SSN, '-', '')
		,AP.CreatedDate
		,ap.CLNO
		,AP.ClientProgramID
		,ProgramName=CP.Name
		,ap.ApDate
		,CASE WHEN GetOrderId.HasBackground IS NULL THEN 1 ELSE GetOrderId.HasBackground end 
		,CASE WHEN GetOrderId.HasDrugScreen IS NULL THEN 0 ELSE GetOrderId.HasDrugScreen end
		,CASE WHEN GetOrderId.HasImmunization IS NULL THEN 0 ELSE GetOrderId.HasImmunization end
		,BS.OrderSummaryStatusId
		,Ap.OrigCompDate
		,
		--CASE WHEN rS.HasBackground=1 THEN BRS.OrderSummaryResultId ELSE NULL END,
		--RS.BackgroundStatus,
		--RS.BackgroundResult,
		CASE 
			WHEN GetOrderId.HasBackground = 1
				AND BS.StatusCode = 'F'
				THEN BRS.OrderSummaryResultId
			ELSE NULL
			END
		,BS.StatusCode
		,
		--RS.BackgroundResult,
		CASE 
			WHEN GetOrderId.HasBackground = 1
				AND BS.StatusCode = 'F'
				THEN BRS.ResultCode
			ELSE NULL
			END
		,DS.OrderSummaryStatusId
		,NULL
		,DRS.OrderSummaryResultId
		,ISNULL(D.CandidateId, ap.APNO)
		,DS.StatusCode
		,SUBSTRING(LTRIM(RTRIM(DRS.DisplayName)), 1, 20)
		,-- Modified by Radhika Dereddy on 11/21/2021
		ISNULL(d.tid, d1.tid)
		,ISC.OrderSummaryStatusId
		,IRS.OrderSummaryResultId
		,ISC.StatusCode
		,CASE 
			WHEN ISNULL(GetOrderId.HasImmunization, 0) = 1
				AND IRS.DisplayName IS NULL
				THEN 'Unknown'
			ELSE IRS.DisplayName
			END AS a29
		,CS.OrderSummaryStatusId AS a30
	FROM
		dbo.Appl AS ap WITH (NOLOCK)
	INNER JOIN dbo.Client C WITH (NOLOCK) ON AP.CLNO=C.CLNO
	LEFT outer JOIN (
		SELECT OrderNumber
			,o.OrderId
			,HasBackground = CASE WHEN bg.OrderServiceId IS NULL THEN 0 ELSE 1 end
			,HasDrugScreen = CASE WHEN dt.OrderServiceId IS NULL THEN 0 ELSE 1 end
			,HasImmunization =  CASE WHEN imm.OrderServiceId IS NULL THEN 0 ELSE 1 end
		FROM Enterprise..[Order] o 
			LEFT outer JOIN Enterprise..OrderService bg ON o.OrderId=bg.OrderId AND bg.BusinessServiceId=1
			LEFT outer JOIN Enterprise..OrderService dt ON o.OrderId=dt.OrderId AND dt.BusinessServiceId=2
			LEFT outer JOIN Enterprise..OrderService imm ON o.OrderId=imm.OrderId AND imm.BusinessServiceId=3
		 WHERE (o.ModifyDate BETWEEN @startdate AND @enddate OR O.CreateDate BETWEEN @startdate AND @enddate)
		  AND o.DASourceId=1
		) AS GetOrderId ON ap.APNO = GetOrderId.OrderNumber
	LEFT OUTER JOIN dbo.ApplFlagStatus AS FS ON ap.APNO = FS.APNO
	LEFT OUTER JOIN dbo.OCHS_CandidateInfo AS CI ON ap.APNO = CI.APNO
		AND ap.clno = ci.clno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d ON CONVERT(VARCHAR(25), ap.APNO) = d.OrderIDOrApno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d1 ON CONVERT(VARCHAR(25), CI.OCHS_CandidateInfoID) = d1.OrderIDOrApno
	LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap] AS M ON M.VendorTestResult = D.TestResult
		AND M.VendorOrderStatus = D.OrderStatus
	LEFT OUTER JOIN Enterprise.Verify.OrderImmunization AS oi ON GetOrderId.OrderId = oi.OrderID
		AND oi.IsActive = 1
	LEFT OUTER JOIN dbo.ClientProgram cp ON cp.ClientProgramID = ap.ClientProgramID AND cp.CLNO = ap.CLNO
	LEFT OUTER JOIN report.OrderSummary os ON ap.APNO = os.OrderNumber
	--All case statements below were needed to get correct IDs,displayname and codes.
	LEFT OUTER JOIN Report.refOrderSummaryStatus BS ON CASE 
			WHEN ISNULL(GetOrderId.HasBackground, 1) = 1
				THEN ISNULL(Ap.ApStatus, 'P')
			ELSE NULL
			END = BS.StatusCode
	LEFT OUTER JOIN Report.refOrderSummaryStatus DS ON CASE 
			WHEN (
					ISNULL(GetOrderId.HasDrugScreen, 0) = 0
					AND ISNULL(ci.OCHS_CandidateInfoID, D.TID) IS NULL
					)
				THEN NULL
			WHEN (
					M.PreCheckOrderStatus IS NULL
					AND (ISNULL(D.OrderStatus, d1.OrderStatus) LIKE 'Completed%')
					)
				THEN 'F'
			ELSE ISNULL(M.PreCheckOrderStatus, 'P')
			END = DS.StatusCode
	LEFT OUTER JOIN Report.refOrderSummaryStatus ISC ON CASE 
			WHEN ISNULL(GetOrderId.HasImmunization, 0) = 1
				THEN 'F'
			ELSE NULL
			END = ISC.StatusCode
	LEFT OUTER JOIN Report.refOrderSummaryStatus CS ON CASE 
			WHEN Ap.ApStatus <> 'F'
				THEN Ap.ApStatus
			WHEN (
					Ap.ApStatus = 'F'
					AND ISNULL(GetOrderId.HasDrugScreen, (ISNULL(ci.OCHS_CandidateInfoID, ISNULL(d.TID, ISNULL(d1.TID, 0))))) = 0
					)
				THEN Ap.ApStatus
			WHEN (
					Ap.ApStatus = 'F'
					AND ISNULL(GetOrderId.HasDrugScreen, (ISNULL(ci.OCHS_CandidateInfoID, ISNULL(d.TID, ISNULL(d1.TID, 0))))) <> 0
					)
				THEN CASE 
						WHEN (
								M.PreCheckOrderStatus IS NULL
								AND ISNULL(D.OrderStatus, d1.OrderStatus) LIKE 'Completed%'
								)
							THEN 'F'
						ELSE ISNULL(M.PreCheckOrderStatus, 'P')
						END
			END = CS.StatusCode
	LEFT OUTER JOIN Report.refOrderSummaryResult BRS ON LTRIM(RTRIM(CASE 
					WHEN ISNULL(FS.FlagStatus, 0) = 1
						THEN 'C'
					ELSE ''
					END)) = LTRIM(RTRIM(BRS.ResultCode))
		AND BRS.ServiceType = 'B'
	LEFT OUTER JOIN Report.refOrderSummaryResult DRS ON CASE 
			WHEN (
					ISNULL(GetOrderId.HasDrugScreen, 0) = 0
					AND ISNULL(D.TID, d1.tid) IS NULL
					)
				THEN NULL
			WHEN (
					M.PreCheckOrderStatus IS NULL
					AND (ISNULL(D.OrderStatus, d1.OrderStatus) LIKE 'Completed%')
					)
				THEN ISNULL(D.TestResult, d1.TestResult)
			ELSE ISNULL(M.PreCheckTestResult, ISNULL(D.TestResult, d1.TestResult))
			END = DRS.ResultCode
		AND DRS.ServiceType = 'D'
	LEFT OUTER JOIN Report.refOrderSummaryResult IRS ON CASE 
			WHEN ISNULL(GetOrderId.HasImmunization, 0) = 1
				THEN CASE 
						WHEN oi.IsCompliant = 1
							THEN 'Compliant'
						WHEN oi.IsCompliant = 0
							THEN 'NonCompliant'
						ELSE 'Unknown'
						END
			ELSE NULL
			END = IRS.ResultCode
		AND IRS.ServiceType = 'I'
	WHERE c.ClientTypeID IN (6,8,11)
	AND (
		ap.CreatedDate BETWEEN @startdate AND @enddate
		OR AP.ApDate BETWEEN @startdate AND @enddate
		)
	AND os.OrderNumber IS NULL
	
	Select @@ROWCOUNT, 0, ERROR_MESSAGE()
END TRY

BEGIN CATCH  
    select @@ROWCOUNT, 1, ERROR_MESSAGE()
END CATCH  
