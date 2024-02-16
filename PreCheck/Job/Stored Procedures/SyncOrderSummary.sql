
/****** Object:  StoredProcedure [Job].[SyncOrderSummary]    Script Date: 1/11/2022 6:11:18 PM ******/


-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 5/9/2020
-- Description:	Populates/Sync OrderSummary table
-- Scope: For StudentCheck client types currently
-- Modified by Prasanna on 10/21/2021 for HDT#13925 Issue with Applicant Report File Export
-- exec [Job].[SyncOrderSummary] null, null, null, null
-- Modified by Radhika Dereddy on 11/21/2021 to just use 20 characters for DrugScreenResult since the SyncJob is failing
-- Modified by Joshua Ates on 1/13/2022
--		Removed  Enterprise.vwReportStatus RS WITH(NOLOCK)  from the procedure and replaced it with base tables to improve speed dramatically.
-- Modified by Joshua Ates on 1/25/2022
--		Removed order date constraint have it looking for modifcations based on last job run date.
-- =============================================
CREATE PROCEDURE [Job].[SyncOrderSummary]
--DECLARE
	 @NewRecordStartDate	DATETIME	= NULL
	,@NewRecordEndDate		DATETIME	= NULL
	,@OldRecordStartDate	DATETIME	= NULL
	,@OldRecordEndDate		DATETIME	= NULL
AS
BEGIN
	--SET NOCOUNT ON;

	-- insert new entries
	IF (@NewRecordStartDate IS NULL)
		SELECT @NewRecordStartDate = ISNULL(MAX(OrderCreateDate), '1/1/2012')
		FROM Report.OrderSummary

	IF (@NewRecordEndDate IS NULL)
		SELECT @NewRecordEndDate = GETDATE()

	IF (@OldRecordStartDate IS NULL)
		SELECT MAX(CreateDate) FROM [JobMaster].[dbo].[JobScheduleLogSub] WHERE JobID = '1012' AND IsComplete = 1 AND HasError = 0 --get most recent successful job run

	IF (@OldRecordEndDate IS NULL)
		SELECT @OldRecordEndDate = @NewRecordEndDate

	UPDATE OS
	SET
		 OS.Applicant_FirstName = LTRIM(RTRIM(A.First))
		,OS.Applicant_LastName = LTRIM(RTRIM(A.Last))
		,OS.Applicant_MiddleName = LTRIM(RTRIM(A.Middle))
		,OS.Applicant_UID = REPLACE(ap.SSN, '-', '')
		,OS.ProgramId = A.ClientProgramID
		,OS.ProgramName = A.ProgramName
		,OS.ApDate = AP.ApDate
		,OS.HasBackground = GetOrderId.HasBackground
		,OS.HasDrugScreen = GetOrderId.HasDrugScreen
		,OS.HasImmunization = GetOrderId.HasImmunization
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
		,OS.DT_OrderId = D.CandidateId
		,OS.DT_ReportId = D.ClientConfiguration_DrugScreeningID
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
	FROM Report.ListReports_ResultOrStatusChanged(@OldRecordStartDate, @OldRecordEndDate) AS DR
	INNER JOIN Report.OrderSummary AS os WITH (NOLOCK) ON dr.APNO = OS.OrderNumber
	--INNER JOIN  Enterprise.vwReportStatus RS WITH(NOLOCK) 
	--	ON	RS.OrderNumber=OS.OrderNumber AND RS.OrderNumber=DR.APNO
	INNER JOIN dbo.Appl AS ap ON ap.APNO = DR.APNO
	INNER JOIN (
		SELECT OrderNumber
			,OrderId
			,ShortName
			,HasDrugScreen
			,HasBackground
			,HasImmunization
		FROM Enterprise..vwApplicantOrder
		LEFT JOIN Enterprise.dbo.DynamicAttribute ON DAOrderStatusId = DynamicAttribute.DynamicAttributeId
		WHERE HasImmunization = 1
			OR HasDrugScreen = 1
			OR HasBackground = 1
		) AS GetOrderId ON ap.APNO = GetOrderId.OrderNumber
	LEFT OUTER JOIN dbo.ApplFlagStatus AS FS ON GetOrderId.OrderNumber = FS.APNO
	LEFT OUTER JOIN dbo.OCHS_CandidateInfo AS CI ON GetOrderId.OrderNumber = CI.APNO
		AND ap.clno = ci.clno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d ON CONVERT(VARCHAR(25), ap.APNO) = d.OrderIDOrApno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d1 ON CONVERT(VARCHAR(25), CI.OCHS_CandidateInfoID) = d1.OrderIDOrApno
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
	WHERE os.ModifyDate BETWEEN @OldRecordStartDate AND @OldRecordEndDate ----Modified for HDT#13925 Issue with Applicant Report File Export
	


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
	SELECT GetOrderId.OrderNumber
		,LTRIM(RTRIM(ap.First))
		,LTRIM(RTRIM(ap.Last))
		,LTRIM(RTRIM(ap.Middle))
		,REPLACE(ap.SSN, '-', '')
		,AP.CreatedDate
		,ap.CLNO
		,a.ClientProgramID
		,a.ProgramName
		,ap.ApDate
		,GetOrderId.HasBackground
		,GetOrderId.HasDrugScreen
		,GetOrderId.HasImmunization
		,BS.OrderSummaryStatusId
		,A.OrigCompDate
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
		,ISNULL(D.CandidateId, a.APNO)
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
		--Enterprise.vwReportStatus rs
		dbo.Appl AS ap
	INNER JOIN (
		SELECT OrderNumber
			,OrderId
			,ShortName
			,HasDrugScreen
			,HasBackground
			,HasImmunization
		FROM Enterprise..vwApplicantOrder
		LEFT JOIN Enterprise.dbo.DynamicAttribute ON DAOrderStatusId = DynamicAttribute.DynamicAttributeId
		WHERE HasImmunization = 1
			OR HasDrugScreen = 1
			OR HasBackground = 1
		) AS GetOrderId ON ap.APNO = GetOrderId.OrderNumber
	LEFT OUTER JOIN dbo.ApplFlagStatus AS FS ON GetOrderId.OrderNumber = FS.APNO
	LEFT OUTER JOIN dbo.OCHS_CandidateInfo AS CI ON GetOrderId.OrderNumber = CI.APNO
		AND ap.clno = ci.clno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d ON CONVERT(VARCHAR(25), ap.APNO) = d.OrderIDOrApno
	LEFT OUTER JOIN dbo.vwDrugResultCurrent AS d1 ON CONVERT(VARCHAR(25), CI.OCHS_CandidateInfoID) = d1.OrderIDOrApno
	LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap] AS M ON M.VendorTestResult = D.TestResult
		AND M.VendorOrderStatus = D.OrderStatus
	LEFT OUTER JOIN Enterprise.Verify.OrderImmunization AS oi ON GetOrderId.OrderId = oi.OrderID
		AND oi.IsActive = 1
	-- END
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
		) A ON GetOrderId.OrderNumber = A.APNO
	LEFT OUTER JOIN report.OrderSummary os ON GetOrderId.OrderNumber = os.OrderNumber
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
	WHERE a.ClientTypeID IN (6,8,11)
		AND os.OrderNumber IS NULL
END
