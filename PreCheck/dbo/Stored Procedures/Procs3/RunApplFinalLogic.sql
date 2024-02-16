
-- =============================================
-- Author:		<Bhavana Bakshi>
-- Create date: <04/25/2008>
-- Description:	<To update applicaton's flag status from OASIS when the application in finaled>
--  Flag  Description
--  1      Clear
--  2      Needs Review
-- =============================================
--===================================================
-- Edit By:-	Dongmei He	
-- Edit Date :- 03/30/2022
-- Description:-  PR11-Additional Case Adjudication Details 
--                for Taleo Candidates
--===================================================

CREATE PROCEDURE [dbo].[RunApplFinalLogic] @apno INT
AS BEGIN
    SET NOCOUNT OFF;
    DECLARE @ApStatus CHAR(1), @Flag INT, @CLNO INT, @adjreview VARCHAR(50), @tmpFlag INT, @ReopenDate DATE;
    DECLARE @cnt INT;
    DECLARE @AAID INT;
    DECLARE @HCAAdjudicationCase BIT;
    DECLARE @AdjudicationCLNO TABLE(clno INT);
	DECLARE @ApplFinalAdjudicationLogId INT
	DECLARE @NumberOfDaysToDeleteLog INT = 30
	DECLARE @LogTempTable TABLE (ApplFinalAdjudicationLogId INT)
    SELECT @CLNO=CLNO, @ReopenDate=ReopenDate FROM Appl WHERE APNO=@apno;
    SET @adjreview=(SELECT Value
                    FROM ClientConfiguration
                    WHERE ConfigurationKey='AdjudicationProcess' AND CLNO=@CLNO);
    SELECT @HCAAdjudicationCase=CASE WHEN (SELECT COUNT(*)
                                           FROM ClientConfiguration cc
                                                INNER JOIN dbo.vwClient c ON(cc.CLNO=c.ParentId OR(cc.CLNO=c.ClientId AND c.ParentId IS NULL))
                                           WHERE ConfigurationKey='EnableDefaultAdjudicationStatusOnly' AND Value='True' AND c.ClientId=@CLNO)>=1 THEN 1 ELSE 0 END;
    SELECT @ApStatus=ApStatus FROM Appl WHERE APNO=@apno;

	-- overriding configuration to rollback the adjudication process
	SET @adjreview = 'False'

    --1-CLEAR
    --2-NEEDS REVIEW
    --3-ADVERSE
    SET @Flag=1; --DEFAULT
    SET @tmpFlag=0; --default
    IF(@ApStatus='F')BEGIN
        IF(@adjreview='True')BEGIN
		 BEGIN TRY
            --------ADJREVIEW-----------------------------------
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM Empl WITH(NOLOCK)
                          WHERE IsOnReport=1 AND IsHidden=0 AND Apno=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM Educat WITH(NOLOCK)
                          WHERE IsOnReport=1 AND IsHidden=0 AND APNO=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM ProfLic WITH(NOLOCK)
                          WHERE IsOnReport=1 AND IsHidden=0 AND Apno=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM PersRef WITH(NOLOCK)
                          WHERE IsOnReport=1 AND IsHidden=0 AND APNO=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM MedInteg WITH(NOLOCK)
                          WHERE IsHidden=0 AND APNO=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM DL WITH(NOLOCK)
                          WHERE IsHidden=0 AND APNO=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM Crim WITH(NOLOCK)
                          WHERE IsHidden=0 AND APNO=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;
            SET @tmpFlag=(SELECT MAX(ISNULL(ClientAdjudicationStatus, 0))
                          FROM Credit WITH(NOLOCK)
                          WHERE IsHidden=0 AND APNO=@apno);
            IF @tmpFlag>@Flag SET @Flag=@tmpFlag;

            --USONC client adjudication mapping
            IF(@Flag=4)SET @Flag=4; --adverse
            ELSE IF(@Flag=3)SET @Flag=3; --pending review
            ELSE IF(@Flag=2)SET @Flag=1; --clear
            ELSE IF(@Flag=1)SET @Flag=0; --pending review should not happen
			END TRY
			BEGIN CATCH
			   INSERT INTO dbo.DatabaseObjectError
                 SELECT ERROR_NUMBER(),ERROR_STATE(),ERROR_SEVERITY(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE(), 'RunApplFinalLogic_AdjReview';  
			END CATCH
        END;
        ELSE IF(@HCAAdjudicationCase=1)BEGIN
		BEGIN TRY
		
                 DECLARE @ReportSections dbo.ReportSection;

				 INSERT INTO Stage.ApplFinalAdjudicationLog 
				 SELECT @apno, 0, GETDATE(), 'RunApplFinalLogic', GETDATE()

				 SET @ApplFinalAdjudicationLogId = SCOPE_IDENTITY()

                 INSERT INTO @ReportSections
                 SELECT ApplSectionID, Section, SectStat, SectSubStatusID
                 FROM [GetReportSectionStatus](@apno);

                 SET @Flag=(SELECT [dbo].[GetReportOverallStatus](@CLNO, @ReportSections));

				 INSERT INTO Stage.ApplFinalAdjudicationSubLog 
				 SELECT  @ApplFinalAdjudicationLogId, ApplSection, SectStat, SectSubStatusID, GETDATE(), 'RunApplFinalLogic' 
				 FROM @ReportSections

				 UPDATE Stage.ApplFinalAdjudicationLog SET OverallStatus = @Flag, ModifyDate = GETDATE() 
				  WHERE ApplFinalAdjudicationLogId = @ApplFinalAdjudicationLogId
				 
				 INSERT INTO @LogTempTable
                 SELECT DISTINCT ApplFinalAdjudicationLogId FROM Stage.ApplFinalAdjudicationSubLog WHERE CreateDate >= DateAdd(day, @NumberOfDaysToDeleteLog, GETDATE())

                 DELETE FROM Stage.ApplFinalAdjudicationSubLog WHERE ApplFinalAdjudicationLogId in 
				        (SELECT ApplFinalAdjudicationLogId FROM @LogTempTable)
				 DELETE FROM Stage.ApplFinalAdjudicationLog WHERE ApplFinalAdjudicationLogId in 
				        (SELECT ApplFinalAdjudicationLogId FROM @LogTempTable)

		 END TRY
		 BEGIN CATCH
				 INSERT INTO dbo.DatabaseObjectError
                 SELECT ERROR_NUMBER(),ERROR_STATE(),ERROR_SEVERITY(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE(), 'RunApplFinalLogic_HCAAdjudicationCase';  
		 END CATCH
        END;
        ELSE
        ---------STANDARD--------------------------------
        BEGIN
		BEGIN TRY
                 IF(SELECT COUNT(Apno)
                    FROM Empl WITH(NOLOCK)
                    WHERE IsOnReport=1 AND IsHidden=0 AND Apno=@apno AND SectStat NOT IN ('3', '4', '5'))>0 BEGIN
                     SET @Flag=2; --Needs review
                 END;
                 IF(SELECT COUNT(APNO)
                    FROM Educat WITH(NOLOCK)
                    WHERE IsOnReport=1 AND IsHidden=0 AND APNO=@apno AND SectStat NOT IN ('3', '4', '5'))>0 BEGIN
                     SET @Flag=2;
                 END;
                 IF(SELECT COUNT(Apno)
                    FROM ProfLic WITH(NOLOCK)
                    WHERE IsOnReport=1 AND IsHidden=0 AND Apno=@apno AND SectStat NOT IN ('3', '4', '5'))>0 BEGIN
                     SET @Flag=2;
                 END;
                 IF(SELECT COUNT(APNO)
                    FROM PersRef WITH(NOLOCK)
                    WHERE IsOnReport=1 AND IsHidden=0 AND APNO=@apno AND SectStat NOT IN ('3', '4', '5'))>0 BEGIN
                     SET @Flag=2;
                 END;
                 IF(SELECT COUNT(APNO)
                    FROM MedInteg WITH(NOLOCK)
                    WHERE IsHidden=0 AND APNO=@apno AND SectStat NOT IN ('1', '2', '3'))>0 BEGIN
                     SET @Flag=2;
                 END;
                 IF(SELECT COUNT(APNO)
                    FROM DL WITH(NOLOCK)
                    WHERE IsHidden=0 AND APNO=@apno AND SectStat NOT IN ('3', '4', '5'))>0 BEGIN
                     SET @Flag=2;
                 END;
                 IF(SELECT COUNT(APNO)
                    FROM Crim WITH(NOLOCK)
                    WHERE IsHidden=0 AND APNO=@apno AND Clear<>'T')>0 BEGIN
                     SET @Flag=2;
                 END;
				 END TRY
		 BEGIN CATCH
				 INSERT INTO dbo.DatabaseObjectError
                 SELECT ERROR_NUMBER(),ERROR_STATE(),ERROR_SEVERITY(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE(), 'RunApplFinalLogic_Standard';  
		 END CATCH
        END;
        -----------------------------
        --UPDATE/MERGE
        IF(SELECT COUNT(APNO)FROM ApplFlagStatus WHERE APNO=@apno)=0 BEGIN
            INSERT INTO ApplFlagStatus(APNO, FlagStatus, LastUpdatedUTC)
            VALUES(@apno, @Flag, GETUTCDATE());
        END;
        ELSE BEGIN
            UPDATE ApplFlagStatus
            SET FlagStatus=@Flag, LastUpdatedUTC=GETUTCDATE()
            WHERE APNO=@apno;
        END;
    END;
    IF(@ApStatus='F')BEGIN
        SELECT @cnt=COUNT(*)FROM FreeReport WHERE APNO=@apno;
        IF @cnt=0 BEGIN
            DECLARE @FreeReport BIT;
            SELECT @FreeReport=ISNULL(FreeReport, 0)FROM Appl WHERE APNO=@apno;
            IF @FreeReport=1 BEGIN
                INSERT INTO FreeReport(APNO, CLNO, StatusID, FreeReportLetterReturnID, [2ndLetterReturnID], Name, Address1, City, State, Zip, ApplicantEmail)
                SELECT a.APNO, a.CLNO, 24, 0, 0, a.[First]+' '+ISNULL(a.Middle, '')+' '+ISNULL(a.[Last], '') AS [Name], ISNULL(a.Addr_Num, '')+' '+ISNULL(a.Addr_Apt, '')+' '+ISNULL(a.Addr_Dir, '')+' '+a.Addr_Street+' '+ISNULL(Addr_StType, '') AS Address1, a.City, a.State, a.Zip, Email
                FROM Appl a
                WHERE a.APNO=@apno;
            END;
            ELSE
            -- for US Oncology
            BEGIN
                INSERT INTO FreeReport(APNO, CLNO, StatusID, FreeReportLetterReturnID, [2ndLetterReturnID], Name, Address1, City, State, Zip, ApplicantEmail)
                SELECT a.APNO, a.CLNO, 24, 0, 0, a.[First]+' '+ISNULL(a.Middle, '')+' '+ISNULL(a.[Last], '') AS [Name], ISNULL(a.Addr_Num, '')+' '+ISNULL(a.Addr_Apt, '')+' '+ISNULL(a.Addr_Dir, '')+' '+a.Addr_Street+' '+ISNULL(Addr_StType, '') AS Address1, a.City, a.State, a.Zip, Email
                FROM Appl a
                WHERE a.APNO=@apno AND a.CLNO=6977 AND(a.State='CA' OR a.State='OK' OR a.State='NY' OR a.State='MN');
            END;
            SELECT @AAID=FreeReportID FROM FreeReport WHERE APNO=@apno;
            INSERT INTO AdverseActionHistory(AdverseActionID, StatusID, UserID, [Date], ReportID)
            VALUES(@AAID, 24, 'system', GETDATE(), 0);
        END;
    END;
    --Checks to see if an integration client needs a callback when app is finaled and marks it accordingly for winservice to callback with the link to the report
    --KMiryala 11/11/2010
    UPDATE dbo.Integration_OrderMgmt_Request
    SET Process_Callback_Final=1, Callback_Final_Date=NULL
    WHERE APNO=@apno;
    IF(@CLNO IN (10444, 3115))BEGIN
        IF(@ReopenDate IS NULL)BEGIN
            --added by santosh for callbacks to Direct (1 step) integrations (TMHS, HRSOFT etc.)
            UPDATE [dbo].[Integration_PrecheckCallback]
            SET Process_Callback_Final=1, Callback_Final_Date=NULL
            WHERE APNO=@apno;
        END;
    END;
    ELSE BEGIN
        --added by santosh for callbacks to Direct (1 step) integrations (TMHS, HRSOFT etc.)
        UPDATE [dbo].[Integration_PrecheckCallback]
        SET Process_Callback_Final=1, Callback_Final_Date=NULL
        WHERE APNO=@apno;
    END;
END;
