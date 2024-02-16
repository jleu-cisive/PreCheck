
-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 4/7/2017
-- Description:	<Description,,>
-- Modified By: Deepak Vodethela
-- Modified Date: 12/15/2020
-- Description: 1.) Update "ReOrder Servce Completed" status for all pending Crim's. This is to make sure ReOrder service Runs first.
--				2.) Reset the Reopened Crim leads which are completed to the initial stage so that the ReOrder service runs first 
--					and then Review Reportability Service
-- VD:03/08/2021 - As part of code review, the Table Variables have been changed to Temporary Tables
-- =============================================
CREATE PROCEDURE [dbo].[Automation_Crim_Review_ReOrderService]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #tmpMultipleStatusCrims;
	DROP TABLE IF EXISTS #tmpClearsAndRecords;
	DROP TABLE IF EXISTS #tmpReOrderService;
	DROP TABLE IF EXISTS #CrimCompletedStatuses;

	CREATE TABLE #tmpCrim (APNO INT,CNTY_NO INT, County VARCHAR(50))
	CREATE TABLE #tmpMultipleStatusCrims (APNO INT,CNTY_NO INT, County VARCHAR(50),NumClear int, clear varchar(1))
	CREATE TABLE #tmpClearsAndRecords (APNO INT,CNTY_NO INT,County VARCHAR(50),NumClear int, clear varchar(1))
	CREATE TABLE #tmpReOrderService (APNO Int,CNTY_NO Int,OldStatus varchar(1),NewStatus varchar(1),County varchar(50),CreatedDate Datetime)
	CREATE TABLE #CrimCompletedStatuses ([CompletedStatus] CHAR)

	-- Insert Completed Statuses
	INSERT INTO #CrimCompletedStatuses
		SELECT s.crimsect FROM dbo.Crimsectstat as s WHERE s.ReportedStatus_Integration = 'Completed'

	INSERT INTO #tmpCrim
	SELECT C.APNO, CNTY_NO, County
	FROM Crim C(NOLOCK) 
	INNER JOIN APPL A (NOLOCK) ON C.APNO = A.APNO
	WHERE A.ApStatus IN ('P', 'W') AND IsHidden=0  and [CLEAR] Not In ('I')
	GROUP BY C.APNO, C.CNTY_NO, C.County
	HAVING COUNT(1) > 1 

	Insert into #tmpMultipleStatusCrims
	Select  t.APNO, t.CNTY_NO, t.County,COUNT([CLEAR]), [CLEAR]
	From #tmpCrim t inner join Crim c (NOLOCK) ON T.APNO = C.APNO AND T.CNTY_NO = C.CNTY_NO
	Where IsHidden=0 and [CLEAR] Not In ('I')
	Group By t.APNO, t.CNTY_NO, t.County,[CLEAR]

	--Select * from #tmpMultipleStatusCrims 

	--Multiple Clears to be marked for Review 
	INSERT INTO #tmpReOrderService (APNO,CNTY_NO,County,NewStatus,CreatedDate)
	SELECT APNO,CNTY_NO,County,'Z',CURRENT_TIMESTAMP
	FROM #tmpMultipleStatusCrims 
	WHERE ((NumClear>=2 and [CLEAR]='T') ) 
	--ORDER by apno,CNTY_NO

	--Records with multiple clears and Record Founds that need to be considered
	Insert into #tmpClearsAndRecords
	select * 
	from #tmpMultipleStatusCrims 
	where cast(apno as varchar) + cast(CNTY_NO as varchar) in  (select cast(apno as varchar) + cast(CNTY_NO as varchar)  
																  from #tmpMultipleStatusCrims 	
																  where cast(apno as varchar) + cast(CNTY_NO as varchar)  not in (select cast(apno as varchar) + cast(CNTY_NO as varchar)   from #tmpReOrderService)
																  GROUP by apno,CNTY_NO having count(1)>1) 
	AND [CLEAR] in ('T','F')


	--Clears and Records for the same County should be marked for Review
	INSERT INTO #tmpReOrderService (APNO,CNTY_NO,County,NewStatus,CreatedDate)
	SELECT APNO,CNTY_NO,County,'Z',CURRENT_TIMESTAMP
    FROM ( SELECT APNO,CNTY_NO,County FROM #tmpClearsAndRecords 
			GROUP BY APNO,CNTY_NO,County HAVING COUNT(1)>1) Qry

	--Update CRIMID and current record status in the temp table to be ready to insert into the 
	UPDATE t
		SET OldStatus = C.[CLEAR] 
	FROM Crim C (NOLOCK) INNER JOIN #tmpReOrderService t ON C.APNO = t.APNO AND C.CNTY_NO = t.CNTY_NO
	WHERE C.[Clear] in ('T','F')

	INSERT INTO [dbo].[Crim_Review_ReOrderService_Log]
           ([APNO]
           ,[OldStatus]
           ,[NewStatus]
           ,[Createddate]
		   ,CNTY_NO
		   ,County)
	SELECT [APNO]
           ,[OldStatus]
           ,[NewStatus]
           ,[Createddate]
		   ,CNTY_NO
		   ,County
	FROM #tmpReOrderService 
	--Where cast(apno as varchar) + cast(CNTY_NO as varchar)  NOT IN (SELECT cast(apno as varchar) + cast(CNTY_NO as varchar)  FROM [dbo].[Crim_Review_ReOrderService_Log] (NOLOCK))

	--Review ReOrder Service to update 
	UPDATE C 
		SET Clear = 'Z', --Needs Research
			Priv_Notes = 'Status Changed From ' + ISNULL(S.crimdescription,C.[Clear]) + ' to Needs Research  due to a secondary search @ ' + convert(varchar(25), getdate(), 100) + '; ' + isnull(Priv_Notes,''),
			RefCrimStageID = 2 
	FROM Crim C (NOLOCK) INNER JOIN #tmpReOrderService t  ON C.APNO = t.APNO AND C.CNTY_NO = t.CNTY_NO
	left JOIN dbo.Crimsectstat S ON C.[Clear] = S.crimsect
	Where [Clear] in ('T','F')


	DECLARE @County_List VARCHAR(8000)
	Select DISTINCT @County_List = COALESCE(@County_List , '') + CAST(APNO AS VARCHAR) + '(' + County + ');' + char(9) + char(13)  From #tmpReOrderService --Where cast(apno as varchar) + cast(CNTY_NO as varchar)  NOT IN (SELECT cast(apno as varchar) + cast(CNTY_NO as varchar)  FROM [dbo].[Crim_Review_ReOrderService_Log] (NOLOCK))
	--SELECT @County_List
	IF len(ISNULL(@County_List,'')) >10
		BEGIN
			Set @County_List = 'The following county searches have duplicate searches and "Needs to be Reviewed" and consolidated. ' + char(9) + char(13)   + isnull(@County_List,'')
			--EXEC msdb.dbo.sp_send_dbmail    @recipients=N'santoshchapyala@Precheck.com',    @body=@County_List ;
			EXEC msdb.dbo.sp_send_dbmail  @from_address = 'ReOrder Service<ReOrderService@PreCheck.com>',@subject=N'REORDER Service Notification',  @recipients=N'CriminalReorder@precheck.com',    @body=@County_List ;
		END


	-- 12/15/2020 - Santosh/Deepak - Get all the Crims with one County
	INSERT INTO #tmpCrim
	SELECT C.APNO, CNTY_NO, County
	FROM Crim C(NOLOCK) 
	INNER JOIN APPL A (NOLOCK) ON C.APNO = A.APNO
	WHERE A.ApStatus IN ('P', 'W') 
	  AND IsHidden = 0 
	  AND C.RefCrimStageID NOT IN (2, 4)
	GROUP BY C.APNO, C.CNTY_NO, C.County
	HAVING COUNT(1) = 1 

	-- [DEEPAK] - START :TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update
	/* -- Start ReOpen leads --  Get latest Completed ReOpened Crim records */
		SELECT DISTINCT	c.APNO, crim.CrimID, cld.OldValue, cld.NewValue, cld.ChangeDate, crim.RefCrimStageID,
				ROW_NUMBER() OVER (PARTITION BY cld.KeyColumnValue ORDER BY cld.ChangeLogDetailId DESC) AS RowNumber
			INTO #tmpReOpenedLeads
		FROM #tmpCrim AS c
		INNER JOIN Crim crim(NOLOCK)  on c.Apno = crim.APNO and crim.IsHidden = 0
		INNER JOIN dbo.CDCChangeLogDetail AS cld(NOLOCK) ON crim.CrimID = cld.KeyColumnValue AND cld.ChangeLogId = 9
		INNER JOIN #CrimCompletedStatuses AS S ON crim.[Clear] = s.CompletedStatus
		WHERE crim.RefCrimStageID NOT IN (2, 4)

		-- Delete crim records which are not latest
		DELETE L FROM #tmpReOpenedLeads l WHERE L.RowNumber != 1

		-- Reset the reopened leads to the inital stage
		--SELECT * 
			UPDATE C SET C.RefCrimStageID = 2 
		FROM #tmpReOpenedLeads AS L
		INNER JOIN CRIM C(NOLOCK)  ON L.CrimID = C.CrimID AND C.IsHidden = 0
		INNER JOIN #CrimCompletedStatuses AS o ON L.OldValue = o.[CompletedStatus] 
		INNER JOIN #CrimCompletedStatuses AS n ON L.NewValue = n.[CompletedStatus]
		WHERE c.RefCrimStageID NOT IN (2, 4)
	  /* -- End ReOpen leads -- */

	-- Insert into ChangeLog
	INSERT INTO dbo.ChangeLog
	(
		--HEVNMgmtChangeLogID - column value is auto-generated
		TableName,
		ID,
		OldValue,
		NewValue,
		ChangeDate,
		UserID
	)
	SELECT 'Crim.RefCrimStageID', c.CrimID, c.RefCrimStageID,'2', CURRENT_TIMESTAMP,'ReOrdSvc'
	FROM #tmpCrim AS t
	INNER JOIN Crim C (NOLOCK) ON C.APNO = t.APNO AND C.CNTY_NO = t.CNTY_NO
	INNER JOIN #CrimCompletedStatuses AS S ON C.[Clear] = S.CompletedStatus
	WHERE c.IsHidden = 0
	  AND C.RefCrimStageID NOT IN (2, 4)

	-- 12/15/2020 - Santosh/Deepak - Assign "ReOrder Servce Completed" status for all pending Crim's
	--SELECT C.CrimID, C.APNO, C.[Clear]
		UPDATE c SET C.RefCrimStageID = 2 
	FROM #tmpCrim AS t
	INNER JOIN Crim C (NOLOCK) ON C.APNO = t.APNO AND C.CNTY_NO = t.CNTY_NO
	INNER JOIN #CrimCompletedStatuses AS S ON C.[Clear] = S.CompletedStatus
	WHERE c.IsHidden = 0
	  AND c.RefCrimStageID NOT IN (2, 4)
	  --AND c.CrimID NOT IN (SELECT L.CrimID FROM #tmpReOpenedLeads AS L)

	DROP TABLE #tmpCrim
	DROP TABLE #tmpReOpenedLeads
	-- [DEEPAK] - END :TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update

	SET NOCOUNT OFF
END
