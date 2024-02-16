
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
 */
create PROCEDURE [dbo].[ApplAutoClose_GetAppsToClose_bkp6162020]
	
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
DECLARE @TblAutoClose_InitialList AS Table( [APNO] INT, EnteredVia  Varchar(8), InProgressReviewed BIT);
DECLARE @TblAutoClose_List AS Table( [APNO] INT );
DECLARE @TblNonClear_List AS Table( [APNO] INT );
DECLARE @TblAutoClose_FinalList AS Table( [APNO] INT, SSN varchar(11));

--Get a list of SmartStatus Apps that should be eliminated from the AutoClose list
INSERT INTO @TblSmartStatusApps([APNO])
SELECT A.APNO
		FROM dbo.Appl A with (nolock)  
			left join clientconfiguration cc on A.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
	WHERE A.ApStatus = 'P'
		AND   Isnull(A.Investigator, '') <> ''
		AND A.userid IS NOT null
		AND   Isnull(A.CAM, '') = ''
		and cc.value = 'True'
		and A.InUse is null;

--select * from @TblSmartStatusApps

--Get the initial Qualified list of Apps that can be AutoClosed	based of the config setting	
insert into @TblAutoClose_InitialList
Select A.Apno, A.EnteredVia, A.InProgressReviewed
FROM dbo.Appl A with (nolock)  
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl with (nolock)   WHERE SectStat NOT IN ('4','5') and IsOnReport =1 Group by Apno) Empl on A.APNO = Empl.APNO
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat with (nolock)   WHERE SectStat NOT IN ('4','5') and IsOnReport =1Group by Apno) Educat on A.APNO = Educat.APNO
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat NOT IN ('4','5')and IsOnReport =1 Group by Apno) PersRef on A.APNO = PersRef.APNO
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock)   WHERE SectStat NOT IN ('4','5') and IsOnReport =1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO 
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit with (nolock)   WHERE (SectStat NOT IN ('4') and RepType in ('S')) Or (SectStat NOT IN ('3') and RepType in ('C')) Group by Apno) Credit on A.APNO = Credit.APNO
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)   WHERE SectStat NOT IN ('3') Group by Apno) MedInteg on A.APNO = MedInteg.APNO
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL with (nolock)   WHERE SectStat NOT IN ('5') Group by Apno) DL on A.APNO = DL.APNO
LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock)   WHERE IsNull(Clear,'')<> 'T' and IsHidden = 0 Group by Apno) Crim1 on A.APNO = Crim1.APNO
LEFT JOIN clientconfiguration cc on A.clno = cc.clno and cc.configurationkey = 'AUTOCLOSE'
WHERE A.ApStatus IN ('P', 'W')
  AND cc.value = 'True' -- AutoClose configured clients
  AND (Empl.apno is null) and (Educat.apno is null) and (PersRef.apno is null)
  AND (ProfLic.apno is null) and (Credit.apno is null)and (MedInteg.apno is null)and (DL.apno is null)
  AND (Crim1.apno is null)
  AND A.InUse is null 
  AND Isnull(A.Investigator, '') <> '' AND A.userid IS NOT null AND   Isnull(A.CAM, '') = '' 
  AND A.Packageid IS NOT NULL	
ORDER BY A.apno;
	
--select * from @TblAutoClose_InitialList

-- Get all the App's that are entered via 'StuWeb' and also
-- the Report#'s that DO NOT Qualify for 'StuWeb' but are Selected by CAM's via (InProgressReviewed) --
insert into @TblAutoClose_List
SELECT DISTINCT --TOP 100 -- VD: 02/21/2020 --Commented to execute HCA Educat Re-verications and MHHS BULK AUTO CLOSE Reports
		T.Apno FROM
(
	SELECT APNO
	FROM @TblAutoClose_InitialList
	WHERE EnteredVia = 'StuWeb'

	UNION ALL

	SELECT APNO
	FROM @TblAutoClose_InitialList
	WHERE EnteredVia != 'StuWeb'
	  AND InProgressReviewed = 1
) AS T
ORDER BY T.APNO


--Only Qualify those APPS that do not have the Self-disclosed records and Self-disclosed indicator 
Insert into @TblAutoClose_FinalList
SELECT DISTINCT A.APNO,A.SSN
FROM  dbo.Appl A with (nolock) 
INNER JOIN @TblAutoClose_List IL ON A.APNO = IL.APNO 
LEFT JOIN ApplAdditionalData AD with (nolock)  on (A.Apno = Isnull(AD.Apno,0) OR (A.CLNO = AD.CLNO AND A.SSN = AD.SSN))
LEFT JOIN ApplicantCrim ac with (nolock)  on A.Apno = ac.Apno
WHERE Isnull(Crim_SelfDisclosed,0) = 0 AND (ac.Apno is NULL )
ORDER BY A.Apno;

--Find all APNOs in @TblAutoClose_FinalList that have history (based on SSN) that do not qualify for Autoclose, meaning: past APNOs with non-clear Crims
INSERT INTO @TblNonClear_List
SELECT DISTINCT tbl.APNO
FROM @TblAutoClose_FinalList tbl
INNER JOIN dbo.Appl a ON tbl.SSN = a.SSN
INNER JOIN dbo.Crim crim ON crim.APNO = a.APNO AND ISNULL(crim.Clear, '') <> 'T' AND crim.IsHidden = 0
WHERE ISNULL(tbl.SSN, '') <> '' AND tbl.SSN <> 'N/A'

--Only Qualify those APPS that do not have any past convinctions with old reports and are not reopens
SELECT   distinct a.APNO, a.OrigCompDate
FROM  dbo.Appl a with (nolock) 
INNER JOIN @TblAutoClose_FinalList tmp ON tmp.APNO = a.APNO
INNER JOIN dbo.Client c with (nolock) ON a.CLNO = c.CLNO 
where a.APNO NOT IN (SELECT APNO FROM @TblNonClear_List)
AND ISNULL(c.clienttypeid,-1) <> 15 
AND a.Apno not in(select Apno from @TblSmartStatusApps)
AND ISNULL(a.SSN, '') <> ''
AND ISNULL(a.DOB, '') <> ''

--AND (a.Apno in(select APNO from Crim where Apno in(select Apno from @TblAutoClose_FinalList))or appl.Apno in (select APNO from DL where Apno in(select Apno from @TblAutoClose_FinalList)))                --added on  04/17/2014 for auto-close change

--and client.CLNO not in (2135,3468,3668,7380,9334,5723,6544,5116,5337,3995,9004,6476,5651) 
--And (DATEDIFF(day, Appl.ApDate, getdate()))> 1 
and a.InUse is null
AND a.ReopenDate is NULL
order by a.APNO;

--select distinct APNO from crim with (nolock) where APNO IN(select distinct APNO from Appl with (nolock) where SSN in (select distinct SSN from appl with (nolock) 
--where apno in (
--select APNO from @TblAutoClose_FinalList)))
--and IsNull(Clear, '') <> 'T' 

PRINT 'AutoClose - Ended ' + cast(Current_timestamp as varchar)
END







