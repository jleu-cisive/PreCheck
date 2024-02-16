-- ===================================================================
-- Author:		Gaurav Bangia
-- Create date: 8/25/2015
-- Description:	The procedure is responsible to update ApStatus 
-- Initially would be triggered only through Certification data repository/application
-- InProgress = 'P', OnHold = 'M'
--	EXEC UpdApplicationStatus 3254327 , 'ClientCertification', true 
-- Modify Date: 8/22/2022
-- Modify By: Karan/Gaurav 
-- Modify Purpose: Project change: ITG04
-- Last Modify Date: 10/28/2022 (prod)- 10/26/2022 (stage)
-- Last Modify By: Gaurav
-- Last Modify Purpose: Add logging as updates on integration request table weren't working for some requestIds
--
--
-- Modify Date: 11/01/2022
-- Modify By: Jeff Simenc 
-- Modify Purpose: Deadlock issue with update to dbo.Integration_OrderMgmt_Request. There was a missing index on the OrderNumber column of the Enterprise.Staging.OrderStage.  This was added
--					to the table.  Replaced the use of int variable @ApplicationID with a varchar
--					copy @AppID in the UPDATE to Enterprise.staging.ReviewRequest and insert to Enterprise.staging.ReviewResponseAction 

-- =============================================================
CREATE PROCEDURE [dbo].[UpdApplicationStatus]
	@ApplicationId				INT,
	@Source						VARCHAR(25) = 'ClientCertification',
	@IsCertifyResponseYes		BIT = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @INPROGRESS VARCHAR(1) = 'P' 
	DECLARE @ONHOLD VARCHAR(1) = 'M'
	DECLARE @ApplicationStatus VARCHAR(1)
	DECLARE @ApplicantSSN VARCHAR(11)
	DECLARE @ApplicantDOB DATETIME 
	DECLARE @AppID VARCHAR(20)  = CAST(@ApplicationId AS VARCHAR(20))	-- varchar copy of @ApplicationId for use in update to Enterprise.staging.ReviewRequest and insert to Enterprise.staging.ReviewResponseAction


	DECLARE @traceLogParams VARCHAR(500)
	SET @traceLogParams = CONCAT('@ApplicationId:', @ApplicationId, ' || ', '@Source:', @Source, ' || ', '@IsCertifyResponseYes:', @IsCertifyResponseYes)

	EXEC JOB.WriteToTraceLog @Component = 'UpdApplicationStatus', @TaskName = 'CertifyApp-Start',  @Message = @traceLogParams,  @TraceLevel = 'INFO' 
	
    IF(@Source='ClientCertification' AND @IsCertifyResponseYes IS NOT NULL)
	BEGIN
		
		IF(@IsCertifyResponseYes=1)
			SET @ApplicationStatus = @INPROGRESS
		ELSE
			SET @ApplicationStatus = @ONHOLD
		
		--print @ApplicationStatus
		IF(@ApplicationStatus=@ONHOLD)
		BEGIN
			
			UPDATE APPL 
			SET APSTATUS = @ApplicationStatus,
			APDATE = GETDATE(),
			SubStatusID = 29
			WHERE APNO = @ApplicationId
			AND APSTATUS <> @ONHOLD 
		END
		ELSE
		BEGIN
			
			SELECT @ApplicantSSN = ISNULL(SSN,I94), @ApplicantDOB = DOB FROM APPL WHERE APNO = @ApplicationId
			--print @ApplicantSSN
			--print @ApplicantDOB
			IF(ISNULL(@ApplicantSSN,'') <> '' AND ISNULL(@ApplicantDOB, '') <> '')
			BEGIN
				UPDATE APPL 
				SET APSTATUS = @ApplicationStatus,
				APDATE = GETDATE(),
				SubStatusID = 28
				WHERE APNO = @ApplicationId and ApStatus = 'M' -- ApStatus <> 'F' -- kiran - only update the apdate when in ON Hold status
			END
			--ELSE
				--PRINT 'INVALID REQUEST TO PLACE APPLICATION ''IN PROGRESS'
			EXEC JOB.WriteToTraceLog @Component = 'UpdApplicationStatus', @TaskName = 'CertifyApp-End',  @Message = @traceLogParams,  @TraceLevel = 'INFO' 
		END

		DECLARE @isHRReviewMode bit 
		Select @isHRReviewMode = [Enterprise].[dbo].IsHrAutoReviewMode(@ApplicationId)
		SET @traceLogParams = CONCAT(@traceLogParams,' || ','@isHRReviewMode:', @isHRReviewMode)

		EXEC JOB.WriteToTraceLog @Component = 'UpdApplicationStatus', @TaskName = 'IsHRReview-End',  @Message = @traceLogParams,  @TraceLevel = 'INFO' 
		
		if(@IsCertifyResponseYes=1 and @isHRReviewMode=1)
		BEGIN TRY
			EXEC JOB.WriteToTraceLog @Component = 'UpdApplicationStatus', @TaskName = 'Upd-Tran-Begin',  @Message = @traceLogParams,  @TraceLevel = 'INFO' 

			BEGIN TRANSACTION
			
			UPDATE dbo.Integration_OrderMgmt_Request 
			SET refUserActionID=1,
			Process_Callback_Acknowledge=1,
			Callback_Acknowledge_Date=NULL,
			ModifiedDate=GETDATE()
			WHERE APNO=@ApplicationId AND refuserActionID=22

			update  rr 
			SET ClosingReviewStatusId=4,
			rr.ModifyDate=GETDATE() 
			FROM Enterprise.Staging.OrderStage O
			INNER JOIN Enterprise.Staging.ApplicantStage app  ON app.StagingOrderId = O.StagingOrderId
			join Enterprise.staging.ReviewRequest rr on rr.StagingApplicantId=app.StagingApplicantId
			where o.OrderNumber=@AppID		-- Changed to use varchar variable of @ApplicationID
			AND rr.ClosingReviewStatusId=3
		
			insert into Enterprise.staging.ReviewResponseAction
			(ReviewRequestId,ReviewStatusId,UserName,UserIP,IsActive,CreateDate,CreateBy,ModifyDate,ModifyBy)
			Select 
			RR.ReviewRequestId, 4, CC.ClientCertBy, CC.ClientICertByPAddress, 1, GETDATE(), 0, GETDATE(), 0
			FROM dbo.ClientCertification cc 
			INNER JOIN Enterprise.Staging.OrderStage O ON cc.APNO=o.OrderNumber
			INNER JOIN Enterprise.Staging.ApplicantStage a ON a.StagingOrderId = O.StagingOrderId
			INNER JOIN Enterprise.Staging.ReviewRequest rr ON rr.StagingApplicantId = a.StagingApplicantId
			LEFT OUTER JOIN Enterprise.staging.ReviewResponseAction rd ON rr.ReviewRequestId=rd.ReviewRequestId
				AND rd.ReviewStatusId=4
			WHERE o.OrderNumber=@AppID  -- Changed to use varchar variable of @ApplicationID
			AND rd.ReviewResponseActionId IS null

			EXEC JOB.WriteToTraceLog @Component = 'UpdApplicationStatus', @TaskName = 'Upd-Tran-Commit',  @Message = @traceLogParams,  @TraceLevel = 'INFO' 

			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			SET @traceLogParams = CONCAT('Error_Message:', ERROR_MESSAGE(), ' || ', 'Error_Line:', ERROR_LINE(), ' || ', @traceLogParams)
			EXEC JOB.WriteToTraceLog @Component = 'UpdApplicationStatus', @TaskName = 'Upd-Tran-Commit',  @Message = @traceLogParams,  @TraceLevel = 'ERROR' 
		END CATCH
	END
	
END



