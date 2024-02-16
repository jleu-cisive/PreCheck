-- =============================================
-- Author:		Dongmei he
-- Create date: 3/15/2022
-- Description:	Populates/Sync OrderSummary table
-- Modify By: Gaurav Bangia
-- Modify Date: 3/29/2022
-- Last Modify By: Gaurav Bangia
-- Modify Date : 4/12/2022
-- Modify Purpose: The drug test orderid and report id logic was incorrect
-- Modified by Lalit on 11 oct 2022 to include orphan drug test records
-- Modified by Lalit on 19 oct 2022 to correct drugtest result
-- =============================================
CREATE PROCEDURE [StudentCheck].[SyncOrderSummaryUpdate] --'3/23/2022 2:01:15 PM', '3/23/2022 2:40:05 PM'
	 @StartDate		DATETIME	= NULL
	,@EndDate		DATETIME	= NULL
AS
BEGIN TRY
	
	-- TODO- Adjusting start date to have a overlap
	--SET @StartDate = DATEADD(HOUR,-12, @StartDate)

	DECLARE @dateRange VARCHAR(500) = Concat(@startdate, ' - ', @enddate)
	EXEC Enterprise.Job.WriteToTraceLog @Component='SCDsh', -- varchar(5)
	    @TaskName='StudentCheck.SyncOrderSummaryUpdate', -- varchar(50)
	    @Message=@dateRange, -- varchar(2000)
	    @TraceLevel='INFO' -- varchar(10)

	DROP TABLE IF EXISTS #EnterpriseOrders

	SELECT OrderNumber=CAST(ISNULL(OrderNumber,0) AS INT)
			,o.OrderId
			,HasBackground= CASE WHEN bg.OrderServiceId IS NULL THEN 0 ELSE 1 END
            ,HasDrugScreen= CASE WHEN dt.OrderServiceId IS NULL THEN 0 ELSE 1 END
            ,HasImmunization= CASE WHEN imm.OrderServiceId IS NULL THEN 0 ELSE 1 END
        INTO #EnterpriseOrders
		FROM Enterprise..[Order] o 
			LEFT outer JOIN Enterprise.dbo.OrderService bg ON bg.OrderId = o.OrderId AND bg.BusinessServiceId=1
			LEFT outer JOIN Enterprise.dbo.OrderService dt ON dt.OrderId = o.OrderId AND dt.BusinessServiceId=2
			LEFT outer JOIN Enterprise.dbo.OrderService imm ON imm.OrderId = o.OrderId AND imm.BusinessServiceId=3
		WHERE --(o.ModifyDate BETWEEN @startdate AND @enddate OR O.CreateDate BETWEEN @startdate AND @enddate)
		  (o.DASourceId=1)

	UPDATE OS
	SET
		 OS.ClientId = ap.CLNO
		,OS.Applicant_FirstName = LTRIM(RTRIM(A.First))
		,OS.Applicant_LastName = LTRIM(RTRIM(A.Last))
		,OS.Applicant_MiddleName = LTRIM(RTRIM(A.Middle))
		,OS.Applicant_UID = REPLACE(ap.SSN, '-', '')
		,OS.ProgramId = A.ClientProgramID
		,OS.ProgramName = A.ProgramName
		,OS.ApDate = AP.ApDate
		--,OS.HasBackground = CASE WHEN GetOrderId.HasBackground IS NULL THEN 1 ELSE GetOrderId.HasBackground end 
		--,OS.HasDrugScreen = CASE WHEN GetOrderId.HasDrugScreen IS NULL THEN 0 ELSE GetOrderId.HasDrugScreen end
		--,OS.HasImmunization = CASE WHEN GetOrderId.HasImmunization IS NULL THEN 0 ELSE GetOrderId.HasImmunization end
		,OS.BG_OrderStatusId = BS.OrderSummaryStatusId
		,OS.BG_OrderStatus = BS.StatusCode
		,OS.BG_ResultId = CASE 
			WHEN GetOrderId.HasBackground = 1
				AND BS.StatusCode = 'F'
				THEN BRS.OrderSummaryResultId
			ELSE NULL
			END
		,OS.BG_Result = CASE 
			WHEN GetOrderId.HasBackground = 1
				AND BS.StatusCode = 'F'
				THEN BRS.ResultCode
			ELSE NULL
			END
		,OS.DT_OrderStatusId = DS.OrderSummaryStatusId
		,OS.DT_OrderStatus = DS.StatusCode
		,OS.DT_ResultId = DRS.OrderSummaryResultId
		,OS.DT_Result = DRS.DisplayName
		,DT_OrderId = ISNULL(D.CandidateId, D1.CandidateId)
		,DT_ReportId = ISNULL(D.TID,D1.TID)
		,OS.IM_OrderStatusId = ISC.OrderSummaryStatusId
		,OS.IM_OrderStatus = ISC.StatusCode
		,OS.IM_ResultId = IRS.OrderSummaryResultId
		,OS.IM_Result = CASE 
			WHEN ISNULL(GetOrderId.HasImmunization, 0) = 1
				AND IRS.DisplayName IS NULL
				THEN 'Unknown'
			ELSE IRS.DisplayName
			END
		,OS.OrderStatusId = CS.OrderSummaryStatusId
		,OS.ModifyDate = GETDATE()
	FROM Report.ListReports_ResultOrStatusChanged(@StartDate, @EndDate) AS DR
	INNER JOIN Report.OrderSummary AS os WITH (NOLOCK) ON dr.APNO = OS.OrderNumber
	INNER JOIN dbo.Appl AS ap ON ap.APNO = DR.APNO
	LEFT OUTER JOIN #EnterpriseOrders GetOrderId ON os.OrderNumber=GetOrderId.OrderNumber
	LEFT OUTER JOIN dbo.ApplFlagStatus AS FS ON AP.APNO = FS.APNO
	LEFT OUTER JOIN dbo.OCHS_CandidateInfo AS CI ON AP.APNO = CI.APNO
		AND ap.clno = ci.clno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d ON CONVERT(VARCHAR(25), ap.APNO) = d.OrderIDOrApno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d1 ON CONVERT(VARCHAR(25), CI.OCHS_CandidateInfoID) = d1.OrderIDOrApno
	----------------------------------------------------
	LEFT OUTER JOIN dbo.vwIndependentDrugResultCurrent as d2 ON replace(d2.SSN,'-','')=replace(ap.SSN,'-','') AND d2.CLNO=ap.CLNO
	-----------------------------------------------------
	LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap] AS M ON M.VendorTestResult = D.TestResult
		AND M.VendorOrderStatus = D.OrderStatus
	LEFT OUTER JOIN Enterprise.Verify.OrderImmunization AS oi ON GetOrderId.OrderId = oi.OrderID
		AND oi.IsActive = 1
	--END
	INNER JOIN (
		SELECT A.APNO
			,a.First
			,a.Middle
			,a.Last
			,a.OrigCompDate
			,c.ClientTypeID
			,a.ClientProgramID
			,ProgramName = cp.Name
		FROM dbo.Appl a
		LEFT OUTER JOIN dbo.ClientProgram cp ON cp.ClientProgramID = a.ClientProgramID
		INNER JOIN dbo.Client c ON a.clno = c.CLNO
		) AS A ON OS.OrderNumber = A.APNO
	LEFT OUTER JOIN Report.refOrderSummaryStatus BS ON CASE 
			WHEN ISNULL(GetOrderId.HasBackground, 1) = 1
				THEN ISNULL(Ap.ApStatus, 'P')
			ELSE NULL
			END = BS.StatusCode
	LEFT OUTER JOIN Report.refOrderSummaryStatus DS ON CASE 
			WHEN (
					ISNULL(GetOrderId.HasDrugScreen, 0) = 0
					AND ISNULL(ci.OCHS_CandidateInfoID, ISNULL(d.TID,d2.TID)) IS NULL
					)
				THEN NULL
			WHEN (
					M.PreCheckOrderStatus IS NULL
					AND (ISNULL(D.OrderStatus, ISNULL(d1.OrderStatus,d2.OrderStatus)) LIKE 'Completed%')
					)
				THEN 'F'
			ELSE ISNULL(M.PreCheckOrderStatus, 'P')
			END = DS.StatusCode

			--All case statements below were added to
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
					AND ISNULL(GetOrderId.HasDrugScreen, (ISNULL(ci.OCHS_CandidateInfoID, ISNULL(d.TID, ISNULL(ISNULL(d1.TID,d2.TID), 0))))) = 0
					)
				THEN Ap.ApStatus
			WHEN (
					Ap.ApStatus = 'F'
					AND ISNULL(GetOrderId.HasDrugScreen, (ISNULL(ci.OCHS_CandidateInfoID, ISNULL(d.TID, ISNULL(ISNULL(d1.TID,d2.TID), 0))))) <> 0
					)
				THEN CASE 
						WHEN (
								M.PreCheckOrderStatus IS NULL
								AND ISNULL(D.OrderStatus, ISNULL(d1.OrderStatus,d2.OrderStatus)) LIKE 'Completed%'
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
	LEFT OUTER JOIN Report.refOrderSummaryResult DRS ON replace(CASE 
			WHEN (
					ISNULL(GetOrderId.HasDrugScreen, 0) = 0
					AND ISNULL(D.TID, ISNULL(d1.TID,d2.TID)) IS NULL
					)
				THEN NULL
			WHEN (
					M.PreCheckOrderStatus IS NULL
					AND (ISNULL(D.OrderStatus, ISNULL(d1.OrderStatus,d2.OrderStatus)) LIKE 'Completed%')
					)
				THEN ISNULL(D.TestResult, ISNULL(d1.TestResult,d2.TestResult))
			ELSE ISNULL(M.PreCheckTestResult, ISNULL(D.TestResult, isnull(d1.TestResult, d2.TestResult)))
			end,' ','') = DRS.ResultCode
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
	  
	SELECT @@ROWCOUNT, 0, ERROR_MESSAGE()
	
	DROP TABLE IF EXISTS #EnterpriseOrders

	-- APPS where client account is UPDATED
	  UPDATE OS
	  SET OS.ClientId=A.CLNO,
	  OS.ModifyDate=GETDATE()
	  --SELECT OS.OrderNumber, OS.ClientId, A.CLNO
	  FROM Report.OrderSummary OS 
		INNER JOIN dbo.Appl A WITH (NOLOCK) ON OS.OrderNumber=A.APNO AND OS.ClientId<>A.CLNO
		-- BAD APPS ACCOUNT
	  WHERE --A.CLNO=3468
		--AND 
		A.CreatedDate >= DATEADD(MONTH, -3, @StartDate)

END TRY
BEGIN CATCH  
    SELECT @@ROWCOUNT, 1, ERROR_MESSAGE()
END CATCH  

