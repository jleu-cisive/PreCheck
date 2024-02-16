
/*
 =============================================
 Author:		<najma begum>
 Create date: <06/28/2012>
 Description:	<Auto close apps with all clear>
 Notes: NB-11/2012: added 9334 clno so that it does not get autocleared.03/13 - added clno-5337
 =============================================
 =============================================
 Author:		Santosh Chapyala/Kiran Miryala
 Create date: <09/27/2013>
 Description:	<Auto close apps with all clear>
 Notes: Changed the SP to make it config driven instead of hardcoding CLNO's and using StudentCheck as the source. 
 Any client can be AutoClosed based on the configuration
 =============================================
 =============================================
 Author:	  Deepak Vodethela
 Create date: <09/10/2015>
 Description: Get all the App's that are entered via 'StuWeb' and also
			  the Report#'s that DO NOT Qualify for 'StuWeb' but are Selected by CAM's via (InProgressReviewed)
 Notes: Modified the existing temp table to take three values and apply logic
 =============================================
 =============================================
 Author:		Raymundo Lopez
 Create date:	01/18/2019
 Notes:			Added a new temp table to hold APNOs that have past APNOs (based on SSN) with non-clear crims, those APNOs do not qualify for Autoclose
 =============================================
 Author:	  Deepak Vodethela/Kiran Miryala
 Create date: 06/16/2020
 Description: Added conditions to Qualify ZipCrim (AffiliateID#249) reports for AutoClosing
 Modified by Radhika on 06/16/2020 to comment EnteredVia, per deepak it is throwing errors.
 Modified by Deepak on 06/20/2020 : Inner joined the Crim table with @TblAutoClose_InitialList (for Affiliate#249) list.
									For Affiliate#249 the call to the leads service inserts records into Crim table.
									This join is to make sure the relationship between Report and Crim exists.
 =============================================
 */
CREATE PROCEDURE [dbo].[ApplAutoClose_GetAppsToClose_Bkp01242021]
	
AS
BEGIN
SET NOCOUNT ON

PRINT 'Automation_Crim_Review_Reportability - Started ' + cast(Current_timestamp as varchar)
	EXEC [dbo].[Automation_Crim_Review_Reportability]
PRINT 'Automation_Crim_Review_Reportability - Ended ' + cast(Current_timestamp as varchar)

PRINT 'Automation_Crim_Review_ReOrderService - Started'
	EXEC dbo.Automation_Crim_Review_ReOrderService
PRINT 'Automation_Crim_Review_ReOrderService - Ended'

PRINT 'AutoClose - Started ' + cast(Current_timestamp as varchar)
	DECLARE @TblSmartStatusApps AS Table( [APNO] INT );
	DECLARE @TblAutoClose_InitialList AS Table( [APNO] INT, EnteredVia  Varchar(8), InProgressReviewed BIT, AffiliateID int);
	DECLARE @TblAutoClose_List AS Table( [APNO] INT, AffiliateID int );
	DECLARE @TblNonClear_List AS Table( [APNO] INT );
	DECLARE @TblAutoClose_FinalList AS Table( [APNO] INT, SSN varchar(11), AffiliateID int);

	--Get a list of SmartStatus Apps that should be eliminated from the AutoClose list
	INSERT INTO @TblSmartStatusApps([APNO])
	SELECT A.APNO
	FROM dbo.Appl A with (nolock)  
	LEFT JOIN clientconfiguration cc on A.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
	WHERE A.ApStatus = 'P'
	  AND Isnull(A.Investigator, '') <> ''
	  AND A.userid IS NOT null
	  AND Isnull(A.CAM, '') = ''
	  AND cc.value = 'True'
	  AND A.InUse IS NULL

	--SELECT * FROM @TblSmartStatusApps

	-- Get the initial Qualified list of Apps that can be AutoClosed	based of the config setting	
	INSERT INTO @TblAutoClose_InitialList
	SELECT A.Apno, A.EnteredVia, A.InProgressReviewed, C.AffiliateID
	FROM dbo.Appl A with (nolock)
	INNER JOIN Client C ON a.CLNO = C.CLNO AND c.AffiliateID != 249 -- Not eVerifile Clients
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl with (nolock) WHERE SectStat NOT IN ('4','5') and IsOnReport =1 Group by Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat with (nolock) WHERE SectStat NOT IN ('4','5') and IsOnReport =1Group by Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock) WHERE SectStat NOT IN ('4','5')and IsOnReport =1 Group by Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock) WHERE SectStat NOT IN ('4','5') and IsOnReport =1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO 
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit with (nolock) WHERE (SectStat NOT IN ('4') and RepType in ('S')) Or (SectStat NOT IN ('3') and RepType in ('C')) Group by Apno) Credit on A.APNO = Credit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock) WHERE SectStat NOT IN ('3') Group by Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL with (nolock) WHERE SectStat NOT IN ('5') Group by Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsNull(Clear,'')<> 'T' and IsHidden = 0 Group by Apno) Crim1 on A.APNO = Crim1.APNO
	LEFT JOIN clientconfiguration cc on A.clno = cc.clno AND cc.configurationkey = 'AUTOCLOSE'
	WHERE A.ApStatus IN ('P', 'W')
	  AND cc.value = 'True' -- AutoClose configured clients
	  AND (Empl.apno is null) and (Educat.apno is null) and (PersRef.apno is null)
	  AND (ProfLic.apno is null) and (Credit.apno is null)and (MedInteg.apno is null)and (DL.apno is null)
	  AND (Crim1.apno is null)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL	

	-- ZipCrim Process Start
	-- Get all the Reports for Affiliate#249
	INSERT INTO @TblAutoClose_InitialList
	SELECT A.Apno, A.EnteredVia, A.InProgressReviewed, c.AffiliateID
	FROM dbo.Appl A with (nolock) 
	INNER JOIN Client C ON a.CLNO = C.CLNO AND c.AffiliateID = 249 -- eVerifile Clients Only
	INNER JOIN dbo.CRIM C2 ON A.APNO = C2.APNO AND C2.IsHidden = 0
	LEFT JOIN (SELECT COUNT(1) cnt,APNO 
				FROM dbo.Crim with (nolock) 
				WHERE IsNull(Clear,'') NOT IN (SELECT c.crimsect FROM dbo.Crimsectstat c
												WHERE c.ReportedStatus_Integration = 'Completed') 
				  AND IsHidden = 0 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	WHERE A.ApStatus IN ('P', 'W')
	  AND (Crim1.apno is null)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL	

	-- ZipCrim Process End

	--SELECT '@TblAutoClose_InitialList' AS TableName, * from @TblAutoClose_InitialList

	-- Get all the App's that are entered via 'StuWeb' and also
	-- the Report#'s that DO NOT Qualify for 'StuWeb' but are Selected by CAM's via (InProgressReviewed) 
	-- the Reports that are entered via ZipCrim
	INSERT INTO @TblAutoClose_List
	SELECT DISTINCT --TOP 100 -- VD: 02/21/2020 --Commented to execute HCA Educat Re-verications and MHHS BULK AUTO CLOSE Reports
			T.Apno, T.AffiliateID 
		FROM
	(
		SELECT APNO, AffiliateID
		FROM @TblAutoClose_InitialList
		WHERE EnteredVia = 'StuWeb'

		UNION ALL

		-- ZipCrim Process Start
		SELECT I.APNO, AffiliateID
		FROM @TblAutoClose_InitialList AS I
		WHERE I.AffiliateID = 249 -- eVerifile Clients Only
		-- ZipCrim Process End

		UNION ALL

		SELECT APNO, AffiliateID
		FROM @TblAutoClose_InitialList
		WHERE EnteredVia != 'StuWeb'
		  AND InProgressReviewed = 1
	) AS T
	ORDER BY T.APNO

	--SELECT '@TblAutoClose_List' AS TableName, * from @TblAutoClose_List

	--Only Qualify those APPS that do not have the Self-disclosed records and Self-disclosed indicator 
	INSERT INTO @TblAutoClose_FinalList
	SELECT DISTINCT A.APNO,A.SSN, IL.AffiliateID
	FROM  dbo.Appl A with (nolock) 
	INNER JOIN @TblAutoClose_List IL ON A.APNO = IL.APNO 
	LEFT JOIN ApplAdditionalData AD with (nolock)  on (A.Apno = Isnull(AD.Apno,0) OR (A.CLNO = AD.CLNO AND A.SSN = AD.SSN))
	LEFT JOIN ApplicantCrim ac with (nolock)  on A.Apno = ac.Apno
	WHERE Isnull(Crim_SelfDisclosed,0) = 0 
	   AND (ac.Apno is NULL )
	   AND IL.AffiliateID != 249 -- Not eVerifile Clients

	--SELECT '@TblAutoClose_FinalList' AS TableName, * from @TblAutoClose_FinalList

	-- ZipCrim Process Start
	-- Kiran - This is to include All everifile clients reports. 
	INSERT INTO @TblAutoClose_FinalList
	SELECT DISTINCT A.APNO,A.SSN, IL.AffiliateID
	FROM  dbo.Appl A with (nolock) 
	INNER JOIN @TblAutoClose_List IL ON A.APNO = IL.APNO 
	WHERE IL.AffiliateID = 249 
	-- ZipCrim Process End

	--SELECT '@TblAutoClose_FinalList' AS TableName, * from @TblAutoClose_FinalList

	--Find all APNOs in @TblAutoClose_FinalList that have history (based on SSN) 
	--that do not qualify for Autoclose, meaning: past APNOs with non-clear Crims
	INSERT INTO @TblNonClear_List
	SELECT DISTINCT tbl.APNO
	FROM @TblAutoClose_FinalList tbl
	INNER JOIN dbo.Appl a ON tbl.SSN = a.SSN
	INNER JOIN dbo.Crim crim ON tbl.APNO = crim.APNO AND ISNULL(crim.Clear, '') <> 'T' AND crim.IsHidden = 0
	WHERE ISNULL(tbl.SSN, '') <> '' 
	  AND tbl.SSN <> 'N/A'
	  AND tbl.AffiliateID != 249 -- Not eVerifile Clients

	--SELECT '@TblNonClear_List' AS TableName, * from @TblNonClear_List

	--Only Qualify those APPS that do not have any past convinctions with old reports and are not reopens
	SELECT DISTINCT a.APNO, a.OrigCompDate,a.EnteredVia, a.ReopenDate 
		INTO #tmp
	FROM  dbo.Appl a with (nolock) 
	INNER JOIN @TblAutoClose_FinalList tmp ON tmp.APNO = a.APNO
	INNER JOIN dbo.Client c with (nolock) ON a.CLNO = c.CLNO 
	WHERE a.APNO NOT IN (SELECT APNO FROM @TblNonClear_List)
	  AND ISNULL(c.clienttypeid,-1) <> 15 
	  AND a.Apno NOT IN (SELECT Apno FROM @TblSmartStatusApps)
	  AND ISNULL(a.SSN, '') <> ''
	  AND ISNULL(a.DOB, '') <> ''
	  AND a.InUse is null

	--SELECT * FROM #tmp

	-- Qaulify reports with NO SSN for eVerifile client (AffiliateID = 249) because of non availability of CAM's
	INSERT INTO #tmp
	SELECT DISTINCT a.APNO, a.OrigCompDate,a.EnteredVia, a.ReopenDate 
	FROM  dbo.Appl a with (nolock) 
	INNER JOIN @TblAutoClose_FinalList tmp ON tmp.APNO = a.APNO and tmp.AffiliateID = 249
	INNER JOIN dbo.Client c with (nolock) ON a.CLNO = c.CLNO 
	WHERE a.APNO NOT IN (SELECT APNO FROM @TblNonClear_List)
	  AND ISNULL(c.clienttypeid,-1) <> 15 
	  AND a.Apno NOT IN (SELECT Apno FROM @TblSmartStatusApps)
	  AND a.InUse IS NULL

	-- For ZipCrim Clients, because we do not have any CAM's assigned, therefore, 
	-- process should automatically close even though there is a ReOpen Date
	SELECT DISTINCT APNO, OrigCompDate , EnteredVia, ReopenDate
	FROM (
		-- ZipCrim Process Start
		SELECT t.APNO, t.OrigCompDate, t.EnteredVia, t.ReopenDate
		FROM #tmp t 
		WHERE t.EnteredVia = 'ZipCrim' 
		-- ZipCrim Process End
		UNION ALL
		SELECT t.APNO, t.OrigCompDate, t.EnteredVia, t.ReopenDate
		FROM #tmp t 
		WHERE t.EnteredVia != 'ZipCrim' 
		  AND t.ReopenDate IS NULL
	  ) AS ToBeAutoClosedReports

	DROP TABLE #tmp;

--select distinct APNO from crim with (nolock) where APNO IN(select distinct APNO from Appl with (nolock) where SSN in (select distinct SSN from appl with (nolock) 
--where apno in (
--select APNO from @TblAutoClose_FinalList)))
--and IsNull(Clear, '') <> 'T' 

PRINT 'AutoClose - Ended ' + cast(Current_timestamp as varchar)
END







