

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
VD:12/21/2020 - TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update. Introduced RefCrimStageID = 4 (Review Reportability Service Completed)


Modified by Humera Ahmed on 6/17/2021 - Excluding Clear crims from the Review Reportability completion requirement. 
Modified by Santosh Chapyala on 7/7/2021 - disqualifying Reports with Employment and Education having  Alert - Proof Attached as status. 

Added Fourth Set by Santosh Chapyala on 7/8/2021 - relaxing autoclose logic for Special Handling Clients - to be enhanced to use a configuration

Modified by schapyala on 07/26/2021 - First Set to exclude ALERT- SJV ALERT for Employment
Modified by schapyala on 07/26/2021 - Fourth Set (Special Handling) to exclude ALERT- SJV ALERT for Employment and Include all other ALERT combinations for education and employment
Modified by schapyala on 10/07/2021 - Qualifying Reports that has assigned PackageID where IsAutoCloseEnabled is set to True (PackageMain)
Modified by J. Simenc on 04/22/2022 - Changed table references to use with(nolock) where they wern't being used already.
Modified by J. Simenc on 04/22/2022 - Replaced the query at Line 297 with 2 sperate queries to imporve exectution time.

Modified by LOuch on 08/18/2022 - Added ZIPCRIM CREDENTIALING (17480) Client for License and SanctionCheck
Modified By LOUCH on 02/22/2023 - Added Bon Secours ZIP Affiliate (310)

 =============================================
 */
CREATE PROCEDURE [dbo].[ApplAutoClose_GetAppsToClose]
	
AS
BEGIN
SET NOCOUNT ON

PRINT 'Automation_Crim_Review_ReOrderService - Started'
	EXEC dbo.Automation_Crim_Review_ReOrderService
PRINT 'Automation_Crim_Review_ReOrderService - Ended'

PRINT 'Automation_Crim_Review_Reportability - Started ' + cast(Current_timestamp as varchar)
	EXEC [dbo].[Automation_Crim_Review_Reportability]
PRINT 'Automation_Crim_Review_Reportability - Ended ' + cast(Current_timestamp as varchar)


PRINT 'AutoClose - Started ' + cast(Current_timestamp as varchar)
	--DECLARE @TblSmartStatusApps AS Table( [APNO] INT );
	--DECLARE @TblAutoClose_InitialList AS Table( [APNO] INT, EnteredVia  Varchar(8), InProgressReviewed BIT, AffiliateID int,UserID varchar(8));

	CREATE TABLE #TblSmartStatusApps([APNO] INT)
	CREATE INDEX IX_TblSmartStatusApps_01 ON #TblSmartStatusApps([APNO])

	-- Get All leads that are supossed to go out i.e. APNO based
	CREATE TABLE #TblAutoClose_InitialList(
		[APNO] int NOT NULL,
		[EnteredVia] [varchar](8) NULL,
		[InProgressReviewed] BIT NULL,
		[AffiliateID] int,
		[UserID] [varchar](8) NULL,
		[PackageID] int NULL --Added by schapyala on 10/07/2021 - Qualifying Reports that has assigned PackageID where IsAutoCloseEnabled is set to True (PackageMain)
		)

	CREATE INDEX IX_TblAutoClose_InitialList_01 ON #TblAutoClose_InitialList([APNO])

	--DECLARE @TblAutoClose_List AS Table( [APNO] INT, AffiliateID int );
	CREATE TABLE #TblAutoClose_List([APNO] INT, AffiliateID int );
	CREATE INDEX IX_TblAutoClose_List_01 ON #TblAutoClose_List([APNO])

	--DECLARE @TblNonClear_List AS Table( [APNO] INT );
	CREATE TABLE #TblNonClear_List([APNO] INT)
	CREATE INDEX IX_TblNonClear_List_01 ON #TblNonClear_List([APNO])

	--DECLARE @TblAutoClose_FinalList AS Table( [APNO] INT, SSN varchar(11), AffiliateID int);
	CREATE TABLE #TblAutoClose_FinalList([APNO] INT, SSN varchar(11), AffiliateID int);
	CREATE INDEX IX_TblAutoClose_FinalList_01 ON #TblAutoClose_FinalList([APNO])

	--Get a list of SmartStatus Apps that should be eliminated from the AutoClose list
	INSERT INTO #TblSmartStatusApps([APNO])
	SELECT A.APNO
	FROM dbo.Appl A with(NOLOCK)
	LEFT JOIN dbo.clientconfiguration cc WITH (NOLOCK) ON A.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'   -- Changed to use with (nolock) 4/22
	WHERE A.ApStatus = 'P'
	  AND Isnull(A.Investigator, '') <> ''
	  AND A.userid IS NOT null
	  AND Isnull(A.CAM, '') = ''
	  AND cc.value = 'True'
	  AND A.InUse IS NULL

	--SELECT * FROM #TblSmartStatusApps

	--First Set is All Non-Zipcrim, AutoClose COnfigured that are non-adjudication client Reports
	--Including Status and substatus combinations as specified by biz per section
	--Modified by schapyala on 01/01/2021
	--Added PackageID to Select by schapyala on 10/07/2021
	INSERT INTO #TblAutoClose_InitialList
	SELECT distinct A.Apno, A.EnteredVia, A.InProgressReviewed, C.AffiliateID,A.UserID,A.[PackageID]
	FROM dbo.Appl A with (nolock)
	INNER JOIN dbo.Client C WITH(NOLOCK) ON a.CLNO = C.CLNO AND c.AffiliateID NOT IN (249,310) -- Not eVerifile Clients, Not Bon Secours ZC Clients
	LEFT JOIN dbo.clientconfiguration cc WITH(NOLOCK)on A.clno = cc.clno AND cc.configurationkey = 'AUTOCLOSE'  -- Changed to use with (nolock) 4/22
	LEFT JOIN dbo.clientconfiguration ccAdj WITH(NOLOCK) ON A.clno = ccAdj.clno AND ccAdj.configurationkey = 'AdjudicationProcess'  -- Changed to use with (nolock) 4/22
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5','7','C','U')  OR (isnull(SectStat,'') = 'U' AND isnull(SectSubStatusID,0)  NOT IN (43,44,46,48)) OR (isnull(SectStat,'') = 'C' AND isnull(SectSubStatusID,0) IN (78,92))) and IsOnReport =1 and isnull(ishidden,0) = 0 Group by Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5','7','U','C','E','A')  OR (isnull(SectStat,'') = 'U' AND isnull(SectSubStatusID,0) NOT in (31))  OR (isnull(SectStat,'') = 'C' AND isnull(SectSubStatusID,0) IN (93))) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5','U')   OR (isnull(SectStat,'') = 'U' AND isnull(SectSubStatusID,0) NOT in (35,36,39))) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock) WHERE ((isnull(SectStat,'') NOT IN ('4','5','7','C','8')   OR  (isnull(SectStat,'') = '8' AND isnull(SectSubStatusID,0) NOT in (6,8))  OR BoardActions_V = 'Yes')) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) ProfLic on A.APNO = ProfLic.APNO 
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit with (nolock) WHERE ((isnull(SectStat,'') NOT IN ('4') and RepType in ('S')) Or (isnull(SectStat,'') NOT IN ('3') and RepType in ('C')))  and isnull(ishidden,0) = 0 Group by Apno) Credit on A.APNO = Credit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock) WHERE isnull(SectStat,'') NOT IN ('3')  and isnull(ishidden,0) = 0 Group by Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL with (nolock) WHERE isnull(SectStat,'') NOT IN ('3','5')  and isnull(ishidden,0) = 0 Group by Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsNull(Clear,'')<> 'T' and IsHidden = 0 Group by Apno) Crim1 on A.APNO = Crim1.APNO
	-- [DEEPAK] - :TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update	
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsHidden = 0 and RefCrimStageID != 4 and dbo.Crim.Clear = 'F' Group by Apno) CrimCheckRRCompled on A.APNO = CrimCheckRRCompled.APNO
	WHERE A.ApStatus IN ('P', 'W')
	  AND isnull(cc.value,'False') = 'True' -- AutoClose configured clients
	  AND isnull(ccAdj.value,'False') <> 'True' -- Non-Adjudication Clients	  
	  AND (Empl.apno is null) and (Educat.apno is null) and (PersRef.apno is null)
	  AND (ProfLic.apno is null) and (Credit.apno is null)and (MedInteg.apno is null)and (DL.apno is null)
	  AND (Crim1.apno is null)
	  AND ISNULL(CrimCheckRRCompled.APNO,0) = (CASE WHEN c.AffiliateID IN (4,5,229,230,231) THEN 0 ELSE ISNULL(CrimCheckRRCompled.APNO,0) END)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL	

		

	--Second Set is All Non-Zipcrim, AutoClose COnfigured that are adjudication client Reports
	--Including Status and substatus combinations as specified by biz per section
	--Modified by schapyala on 01/01/2021
	--Added PackageID to Select by schapyala on 10/07/2021
	INSERT INTO #TblAutoClose_InitialList
	SELECT distinct A.Apno, A.EnteredVia, A.InProgressReviewed, C.AffiliateID,A.UserID,A.[PackageID]
	FROM dbo.Appl A with (nolock)
	INNER JOIN dbo.Client C WITH(NOLOCK) ON a.CLNO = C.CLNO AND c.AffiliateID NOT IN (249,310) -- Not eVerifile Clients, Not Bon Secours ZC Clients
	LEFT JOIN dbo.clientconfiguration cc WITH(NOLOCK) ON A.clno = cc.clno AND cc.configurationkey = 'AUTOCLOSE'  -- Changed to use with (nolock) 4/22
	LEFT JOIN dbo.clientconfiguration ccAdj WITH(NOLOCK) ON A.clno = ccAdj.clno AND ccAdj.configurationkey = 'AdjudicationProcess'  -- Changed to use with (nolock) 4/22
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5')   ) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5')  ) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5') ) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5')  OR  BoardActions_V ='Yes') and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) ProfLic on A.APNO = ProfLic.APNO 
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit with (nolock) WHERE ((isnull(SectStat,'') NOT IN ('4') and RepType in ('S')) Or (isnull(SectStat,'') NOT IN ('3') and RepType in ('C')))  and isnull(ishidden,0) = 0 Group by Apno) Credit on A.APNO = Credit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock) WHERE isnull(SectStat,'') NOT IN ('3')  and isnull(ishidden,0) = 0 Group by Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL with (nolock) WHERE isnull(SectStat,'') NOT IN ('3','5')  and isnull(ishidden,0) = 0 Group by Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsNull(Clear,'')<> 'T' and IsHidden = 0 Group by Apno) Crim1 on A.APNO = Crim1.APNO
	-- [DEEPAK] - :TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update		
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsHidden = 0 and RefCrimStageID != 4 and dbo.Crim.Clear= 'F' Group by Apno) CrimCheckRRCompled on A.APNO = CrimCheckRRCompled.APNO
	WHERE A.ApStatus IN ('P', 'W')
	  AND isnull(cc.value,'False') = 'True' -- AutoClose configured clients
	  AND isnull(ccAdj.value,'False') = 'True' -- Adjudication Clients	  
	  AND (Empl.apno is null) and (Educat.apno is null) and (PersRef.apno is null)
	  AND (ProfLic.apno is null) and (Credit.apno is null)and (MedInteg.apno is null)and (DL.apno is null)
	  AND (Crim1.apno is null)
	  AND ISNULL(CrimCheckRRCompled.APNO,0) = (CASE WHEN c.AffiliateID IN (4,5,229,230,231) THEN 0 ELSE ISNULL(CrimCheckRRCompled.APNO,0) END)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL

	--Third Set is All Zipcrim Reports
	-- ZipCrim Process Start
	-- Get all the Reports for Affiliate#249
	INSERT INTO #TblAutoClose_InitialList
	SELECT A.Apno, A.EnteredVia, A.InProgressReviewed, c.AffiliateID,A.UserID,A.[PackageID]
	FROM dbo.Appl A with (nolock) 
	INNER JOIN dbo.Client C WITH(NOLOCK) ON a.CLNO = C.CLNO AND c.AffiliateID = 249 AND C.CLNO != 17480 -- eVerifile Clients Only  -- Changed to use with (nolock) 4/22 - Exclude ZipCrim Credentialing 8/18
	INNER JOIN dbo.CRIM C2 WITH(NOLOCK) ON A.APNO = C2.APNO AND C2.IsHidden = 0  -- Changed to use with (nolock) 4/22
	LEFT JOIN (SELECT COUNT(1) cnt,APNO 
				FROM dbo.Crim with (nolock) 
				WHERE IsNull(Clear,'') NOT IN (SELECT c.crimsect FROM dbo.Crimsectstat c
												WHERE c.ReportedStatus_Integration = 'Completed') 
				  AND IsHidden = 0 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	-- [DEEPAK] - :TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update		
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsHidden = 0 and RefCrimStageID != 4 Group by Apno) CrimCheckRRCompled on A.APNO = CrimCheckRRCompled.APNO
	WHERE A.ApStatus IN ('P', 'W')
	  AND (Crim1.apno is null)
	  AND (CrimCheckRRCompled.apno is null)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL	

	  
--Fourth Set is All Bon Secours Zipcrim Reports
	-- ZipCrim Process Start
	-- Get all the Reports for Affiliate#310
	INSERT INTO #TblAutoClose_InitialList
	SELECT A.Apno, A.EnteredVia, A.InProgressReviewed, c.AffiliateID,A.UserID,A.[PackageID]
	FROM dbo.Appl A with (nolock) 
	INNER JOIN dbo.Client C WITH(NOLOCK) ON a.CLNO = C.CLNO AND c.AffiliateID = 310 -- Bon Secour ZC Clients Only 
	INNER JOIN dbo.CRIM C2 WITH(NOLOCK) ON A.APNO = C2.APNO AND C2.IsHidden = 0
	LEFT JOIN (SELECT COUNT(1) cnt,APNO 
				FROM dbo.Crim with (nolock) 
				WHERE IsNull(Clear,'') NOT IN (SELECT c.crimsect FROM dbo.Crimsectstat c
												WHERE c.ReportedStatus_Integration = 'Completed') 
				  AND IsHidden = 0 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	--PreCheck: Lead sent to ZipCrim before ReOrder Servce Completed
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsHidden = 0 and RefCrimStageID not in (2,4) Group by Apno) CrimCheckRRCompled on A.APNO = CrimCheckRRCompled.APNO
	WHERE A.ApStatus IN ('P', 'W')
	  AND (Crim1.apno is null)
	  AND (CrimCheckRRCompled.apno is null)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL	

	  --Added by LOUCH 8/18/2022
	  --ALL ZIPCRIM CREDENTIALING (PROFLIC & MEDINTEG)
	  --GET ALL THE REPORTS FOR CLNO 17480 - ZIPCRIM CREDENTIALING
		DECLARE @ProcessLeadsServiceTime INT = (select ServiceTimeValue from winserviceschedule where servicename = 'ZipCrimProcessLeads') + 2
		Insert into #TblAutoClose_InitialList(Apno, EnteredVia, InProgressReviewed, AffiliateID, UserID, [PackageID])
		SELECT A.Apno, A.EnteredVia, A.InProgressReviewed, c.AffiliateID,A.UserID,A.[PackageID]
		FROM dbo.Appl A with (nolock) 
		INNER JOIN Client C WITH(NOLOCK) ON a.CLNO = C.CLNO AND c.CLNO = 17480-- ZIPCRIM CREDENTIALING Client Only
		INNER JOIN [dbo].[ZipCrimWorkOrders] WO WITH(NOLOCK) ON WO.APNO = A.APNO
		LEFT JOIN (SELECT  COUNT(1) cnt, APNO
					FROM dbo.ProfLic L with (nolock) 
					WHERE ( isnull(SectStat,'') NOT IN (SELECT SS.Code FROM dbo.Sectstat SS	WHERE SS.ReportedStatus_Integration = 'Completed'))
					OR SectSubStatusId IN (11, 7, 10)
					and isnull(ishidden,0) = 0
					GROUP BY Apno) Prof ON A.APNO = Prof.APNO
		LEFT JOIN (SELECT  COUNT(1) cnt, APNO
					FROM dbo.MedInteg M with (nolock) 
					WHERE (isnull(SectStat,'') NOT IN (SELECT SS.Code FROM dbo.Sectstat SS	WHERE SS.ReportedStatus_Integration = 'Completed'))
					and isnull(ishidden,0) = 0
					GROUP BY Apno) Med ON A.APNO = Med.APNO
		WHERE A.ApStatus IN ('P', 'W')
		  AND A.InUse is null 
		  AND Isnull(A.Investigator, '') <> '' 
		  AND A.userid IS NOT null 
		  AND Isnull(A.CAM, '') = '' 
		  AND A.Packageid IS NOT NULL	
		  AND current_timestamp > DATEADD(minute, @ProcessLeadsServiceTime, A.CreatedDate)
		  AND (Prof.apno is null) and (Med.apno is null)
		  AND WO.refWorkOrderStatusID = 4 --READY TO SEND RESULTS

	-- ZipCrim Process End

	--Fourth Set is Special Handling Clients, AutoClose COnfigured that are non-adjudication client Reports
	--Including Status and substatus combinations as specified by biz per section
	--Including all Unverified regardless of substatus for Employment and Education - Currently HCA ONLY
	--Added by schapyala on 07/08/2021
	--Added PackageID to Select by schapyala on 10/07/2021
	INSERT INTO #TblAutoClose_InitialList
	SELECT distinct A.Apno, A.EnteredVia, A.InProgressReviewed, C.AffiliateID,A.UserID,A.[PackageID]
	FROM dbo.Appl A with (nolock)
	INNER JOIN dbo.Client C WITH(NOLOCK) ON a.CLNO = C.CLNO AND c.AffiliateID IN (4,5) --Special Handling Clients  -- Changed to use with (nolock) 4/22
	LEFT JOIN dbo.clientconfiguration cc WITH(NOLOCK) ON A.clno = cc.clno AND cc.configurationkey = 'AUTOCLOSE'  -- Changed to use with (nolock) 4/22
	LEFT JOIN dbo.clientconfiguration ccAdj WITH(NOLOCK) ON A.clno = ccAdj.clno AND ccAdj.configurationkey = 'AdjudicationProcess'  -- Changed to use with (nolock) 4/22
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5','7','C','U')   OR (isnull(SectStat,'') = 'C' AND isnull(SectSubStatusID,0) IN (78))) and IsOnReport =1 and isnull(ishidden,0) = 0 Group by Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5','7','U','C','E','A')   ) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock) WHERE (isnull(SectStat,'') NOT IN ('4','5','U')   OR (isnull(SectStat,'') = 'U' AND isnull(SectSubStatusID,0) NOT in (35,36,39))) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock) WHERE ((isnull(SectStat,'') NOT IN ('4','5','7','C','8')   OR  (isnull(SectStat,'') = '8' AND isnull(SectSubStatusID,0) NOT in (6,8))  OR BoardActions_V = 'Yes')) and IsOnReport =1  and isnull(ishidden,0) = 0 Group by Apno) ProfLic on A.APNO = ProfLic.APNO 
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit with (nolock) WHERE ((isnull(SectStat,'') NOT IN ('4') and RepType in ('S')) Or (isnull(SectStat,'') NOT IN ('3') and RepType in ('C')))  and isnull(ishidden,0) = 0 Group by Apno) Credit on A.APNO = Credit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock) WHERE isnull(SectStat,'') NOT IN ('3')  and isnull(ishidden,0) = 0 Group by Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL with (nolock) WHERE isnull(SectStat,'') NOT IN ('3','5')  and isnull(ishidden,0) = 0 Group by Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsNull(Clear,'')<> 'T' and IsHidden = 0 Group by Apno) Crim1 on A.APNO = Crim1.APNO
	LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock) WHERE IsHidden = 0 and RefCrimStageID != 4 and dbo.Crim.Clear = 'F' Group by Apno) CrimCheckRRCompled on A.APNO = CrimCheckRRCompled.APNO
	WHERE A.ApStatus IN ('P', 'W')
	  AND isnull(cc.value,'False') = 'True' -- AutoClose configured clients
	  AND isnull(ccAdj.value,'False') <> 'True' -- Non-Adjudication Clients	  
	  AND (Empl.apno is null) and (Educat.apno is null) and (PersRef.apno is null)
	  AND (ProfLic.apno is null) and (Credit.apno is null)and (MedInteg.apno is null)and (DL.apno is null)
	  AND (Crim1.apno is null)
	  AND ISNULL(CrimCheckRRCompled.APNO,0) = (CASE WHEN c.AffiliateID IN (4,5) THEN 0 ELSE ISNULL(CrimCheckRRCompled.APNO,0) END)
	  AND A.InUse is null 
	  AND Isnull(A.Investigator, '') <> '' 
	  AND A.userid IS NOT null 
	  AND Isnull(A.CAM, '') = '' 
	  AND A.Packageid IS NOT NULL	

	  --Special Handling Clients Logic END
	  --schapyala on 01/28/2021 added logic to exclude any reports being reviewed by Compliance - BSilver instructions
	  Delete #TblAutoClose_InitialList
	  Where userID = 'Complian'

	--SELECT '#TblAutoClose_InitialList' AS TableName, * from #TblAutoClose_InitialList

	-- Get all the App's that are entered via 'StuWeb' and also
	-- the Report#'s that DO NOT Qualify for 'StuWeb' but are Selected by CAM's via (InProgressReviewed) 
	-- the Reports that are entered via ZipCrim
	-- Modified by schapyala on 10/07/2021 - Qualifying Reports that has assigned PackageID where IsAutoCloseEnabled is set to True (PackageMain regardless of IPR
	INSERT INTO #TblAutoClose_List
	SELECT DISTINCT --TOP 100 -- VD: 02/21/2020 --Commented to execute HCA Educat Re-verications and MHHS BULK AUTO CLOSE Reports
			T.Apno, T.AffiliateID 
		FROM
	(
		SELECT APNO, AffiliateID
		FROM #TblAutoClose_InitialList
		WHERE EnteredVia = 'StuWeb'

		UNION ALL

		-- ZipCrim Process Start
		SELECT I.APNO, AffiliateID
		FROM #TblAutoClose_InitialList AS I
		WHERE I.AffiliateID IN (249,310) -- eVerifile Clients and Bon Secours ZC Clients only
		-- ZipCrim Process End

		UNION ALL

		SELECT APNO, AffiliateID
		FROM #TblAutoClose_InitialList
		WHERE EnteredVia != 'StuWeb'
		  AND InProgressReviewed = 1

       UNION ALL --Added by schapyala on 10/07/2021

		SELECT APNO, AffiliateID
		FROM #TblAutoClose_InitialList A INNER JOIN dbo.PackageMain P on A.PackageID = P.PackageID
		WHERE EnteredVia != 'StuWeb'
		  AND InProgressReviewed = 0
		  AND A.[PackageID] IS NOT NULL
		  AND IsAutoCloseEnabled = 1



	) AS T
	ORDER BY T.APNO

	--SELECT '#TblAutoClose_List' AS TableName, * from #TblAutoClose_List


	--******	BELOW SECTION REPLACED WITH THE NEXT 2 SECTIONS  *******  
	----Only Qualify those APPS that do not have the Self-disclosed records and Self-disclosed indicator 
	--INSERT INTO #TblAutoClose_FinalList
	--SELECT DISTINCT A.APNO,A.SSN, IL.AffiliateID
	--FROM  dbo.Appl A with (nolock) 
	--INNER JOIN #TblAutoClose_List IL ON A.APNO = IL.APNO 
	--LEFT JOIN ApplAdditionalData AD with (nolock)  on (A.Apno = Isnull(AD.Apno,0) OR (A.CLNO = AD.CLNO AND A.SSN = AD.SSN))
	--LEFT JOIN ApplicantCrim ac with (nolock)  on A.Apno = ac.Apno
	--WHERE Isnull(Crim_SelfDisclosed,0) = 0 
	--   AND (ac.Apno is NULL )
	--   AND IL.AffiliateID != 249 -- Not eVerifile Clients
	--  ************************************************************************



	--Only Qualify those APPS that do not have the Self-disclosed records and Self-disclosed indicator 
	INSERT INTO #TblAutoClose_FinalList
	SELECT DISTINCT A.APNO,A.SSN, IL.AffiliateID
	FROM  dbo.Appl A with (nolock) 
	INNER JOIN #TblAutoClose_List IL ON A.APNO = IL.APNO 
	LEFT JOIN ApplAdditionalData AD with (nolock)  on A.Apno = ad.APNO
	LEFT JOIN ApplicantCrim ac with (nolock)  on A.Apno = ac.Apno
	WHERE (Crim_SelfDisclosed IS NULL OR AD.Crim_SelfDisclosed = 0)  -- Isnull(Crim_SelfDisclosed,0) = 0 
	   AND (ac.Apno is NULL )
	   AND IL.AffiliateID NOT IN (249,310) -- Not eVerifile Clients, Not Bon Secours ZC Clients


	INSERT INTO #TblAutoClose_FinalList
	SELECT DISTINCT A.APNO,A.SSN, IL.AffiliateID
	FROM  dbo.Appl A with (nolock) 
	INNER JOIN #TblAutoClose_List IL ON A.APNO = IL.APNO 
	LEFT JOIN ApplAdditionalData AD with (nolock)  on A.CLNO = AD.CLNO AND A.SSN = AD.SSN
	LEFT JOIN ApplicantCrim ac with (nolock)  on A.Apno = ac.Apno
	WHERE (Crim_SelfDisclosed IS NULL OR AD.Crim_SelfDisclosed = 0) --ISNULL(Crim_SelfDisclosed,0) = 0 
	   AND (ac.Apno is NULL )
	   AND IL.AffiliateID NOT IN (249,310) -- Not eVerifile Clients, Not Bon Secours ZC Clients


	--SELECT '#TblAutoClose_FinalList' AS TableName, * from #TblAutoClose_FinalList

	-- ZipCrim Process Start
	-- Kiran - This is to include All everifile clients reports. 
	INSERT INTO #TblAutoClose_FinalList
	SELECT DISTINCT A.APNO,A.SSN, IL.AffiliateID
	FROM  dbo.Appl A with (nolock) 
	INNER JOIN #TblAutoClose_List IL ON A.APNO = IL.APNO 
	WHERE IL.AffiliateID IN (249,310) -- eVerifile Clients and Bon Secours ZC Clients
	-- ZipCrim Process End

	--SELECT '#TblAutoClose_FinalList' AS TableName, * from #TblAutoClose_FinalList

	--Find all APNOs in #TblAutoClose_FinalList that have history (based on SSN) 
	--that do not qualify for Autoclose, meaning: past APNOs with non-clear Crims
	INSERT INTO #TblNonClear_List
	SELECT DISTINCT tbl.APNO
	FROM #TblAutoClose_FinalList tbl
	INNER JOIN dbo.Appl a WITH(NOLOCK) ON tbl.SSN = a.SSN  -- Changed to use with (nolock) 4/22
	INNER JOIN dbo.Crim crim WITH(NOLOCK) ON tbl.APNO = crim.APNO AND ISNULL(crim.Clear, '') <> 'T' AND crim.IsHidden = 0  -- Changed to use with (nolock) 4/22
	WHERE ISNULL(tbl.SSN, '') <> '' 
	  AND tbl.SSN <> 'N/A'
	  AND tbl.AffiliateID NOT IN (249,310) -- Not eVerifile Clients, Not Bon Secours ZC Clients

	--SELECT '#TblNonClear_List' AS TableName, * from #TblNonClear_List

	--Only Qualify those APPS that do not have any past convinctions with old reports and are not reopens
	SELECT DISTINCT a.APNO, a.OrigCompDate,a.EnteredVia, a.ReopenDate 
		INTO #tmp
	FROM  dbo.Appl a with (nolock) 
	INNER JOIN #TblAutoClose_FinalList tmp ON tmp.APNO = a.APNO
	INNER JOIN dbo.Client c with (nolock) ON a.CLNO = c.CLNO 
	WHERE a.APNO NOT IN (SELECT APNO FROM #TblNonClear_List)
	  AND ISNULL(c.clienttypeid,-1) <> 15 
	  AND a.Apno NOT IN (SELECT Apno FROM #TblSmartStatusApps)
	  AND ISNULL(a.SSN, '') <> ''
	  AND ISNULL(a.DOB, '') <> ''
	  AND a.InUse is null

	--SELECT * FROM #tmp

	-- Qaulify reports with NO SSN for eVerifile client (AffiliateID = 249) because of non availability of CAM's
	INSERT INTO #tmp
	SELECT DISTINCT a.APNO, a.OrigCompDate,a.EnteredVia, a.ReopenDate 
	FROM  dbo.Appl a with (nolock) 
	INNER JOIN #TblAutoClose_FinalList tmp ON tmp.APNO = a.APNO and tmp.AffiliateID IN (249,310) -- eVerifile Clients, Bon Secours ZC Clients
	INNER JOIN dbo.Client c with (nolock) ON a.CLNO = c.CLNO 
	WHERE a.APNO NOT IN (SELECT APNO FROM #TblNonClear_List)
	  AND ISNULL(c.clienttypeid,-1) <> 15 
	  AND a.Apno NOT IN (SELECT Apno FROM #TblSmartStatusApps)
	  AND a.InUse IS NULL

	-- For all Clients , because we do not have any CAM's assigned, therefore, 
	-- process should automatically close even though there is a ReOpen Date
	SELECT DISTINCT APNO, OrigCompDate , EnteredVia, ReopenDate
	FROM #tmp t 
	--FROM (
	--	-- ZipCrim Process Start
	--	SELECT t.APNO, t.OrigCompDate, t.EnteredVia, t.ReopenDate
	--	FROM #tmp t 
	--	WHERE t.EnteredVia = 'ZipCrim' 
	--	-- ZipCrim Process End
	--	UNION ALL
	--	SELECT t.APNO, t.OrigCompDate, t.EnteredVia, t.ReopenDate
	--	FROM #tmp t 
	--	WHERE t.EnteredVia != 'ZipCrim' 
	--	  AND t.ReopenDate IS NULL
	--  ) AS ToBeAutoClosedReports

	DROP TABLE #tmp;

--select distinct APNO from crim with (nolock) where APNO IN(select distinct APNO from Appl with (nolock) where SSN in (select distinct SSN from appl with (nolock) 
--where apno in (
--select APNO from #TblAutoClose_FinalList)))
--and IsNull(Clear, '') <> 'T' 

DROP TABLE #TblSmartStatusApps
DROP TABLE #TblNonClear_List
DROP TABLE #TblAutoClose_List
DROP TABLE #TblAutoClose_InitialList
DROP TABLE #TblAutoClose_FinalList
	

PRINT 'AutoClose - Ended ' + cast(Current_timestamp as varchar)
END
