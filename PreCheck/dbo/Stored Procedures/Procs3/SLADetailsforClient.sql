

-- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 01/01/2016  
-- Description: SLA details for client  
-- Modified by Radhika dereddy - Add a new parameter CAM  
-- Modified By: Deepak Vodethela   
-- Description: Add "Is OneHR" parameter   
-- Modified by : Radhika Dereddy on 09/17/2018 to fix IsOneHr results  
-- Modified by: Humera Ahmed on 12/19/2018 to remove IsOneHr parameter and add 3 new columns  
-- Modified by: Humera Ahmed on 4/26/2019 - Please change the date column formats to "mm/dd/yyyy hh:mm AM/PM.  
-- Modified by: Deepak Vodethela on 05/22/2019 - Req#51689  
-- Modified by : Doug DeGenaro on 07/16/2019 - Ticket 54639 to add Admitted Crim column and if SSN has prior report in system

-- Modified By Radhika Dereddy on 03/03/2020 - Per Valerie all the Additional Columns for Release date, MCIC, Additional Charges, Total spend,
-- HROC Straight hours, Elapsed hours, Formatting date, formatting Bit fields, Client certification.
-- EXEC [dbo].[SLADetailsforClient] '0','11/01/2020', '11/30/2020', 177, NULL
-- Modified by Radhika Dereddy on 12/07/2020 since the INNER JOIN on ClientCertification is not pulling all the records for 8914 and so changed it to LEFT JOIN 
-- Modified by Radhika Dereddy on 12/17/2020 to fix the ApplAdditional Data for the APP's showing duplicate entries in the table - this is CDC issue yet to be fixed.
-- Modified by James Norton on 09/21/2121 to refactor code for performace.
-- Modified by James Norton on 11/21/2121 .. changes as per Valerie.. (reporting month based on Origial Comp date.. totals columns moved to follow refchages.. and ReOpen TAT change
/* Modified By: Vairavan A
-- Modified Date: 06/28/2022
-- Description: Main Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Subticket id -54476 Update AffiliateID Parameter 130-429
*/
---Testing
/*
EXEC SLADetailsforClient  '01/01/2018','01/30/2018',0,'0',0
EXEC SLADetailsforClient 0, '06/01/2019','06/30/2019','30',0
EXEC SLADetailsforClient  '06/01/2019','06/30/2019',0,'30:10',0
*/
-- =============================================  
CREATE PROCEDURE [dbo].[SLADetailsforClient]
    @CLNO VARCHAR(MAX),  -- = '1307',  
    @StartDate DATETIME, --= '06/01/2019' ,  
    @EndDate DATETIME,   --='06/30/2019',  
   -- @AffiliateID INT = 0,--code commented by vairavan for ticket id -54476
	 @AffiliateIDs VARCHAR(MAX) = '0',--code added by vairavan for ticket id -54476
    @CAM VARCHAR(8) = NULL
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
    --Declare @CLNO VARCHAR(100) = null
    --Declare @StartDate DateTime = '07/10/2021'
    --Declare @EndDate DateTime ='09/17/2021' 
    --Declare @AffiliateID int = 4  
    --Declare @CAM varchar(8) = null  


    IF (@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null')
    BEGIN
        SET @CLNO = NULL;
    END;

    IF (@CAM = '0' OR @CAM = '' OR LOWER(@CAM) = 'null')
    BEGIN
        SET @CAM = NULL;
    END;

    DROP TABLE IF EXISTS #temp1;
    DROP TABLE IF EXISTS #temp2;
    DROP TABLE IF EXISTS #tempResult1;
    DROP TABLE IF EXISTS #tempResult2;
    DROP TABLE IF EXISTS #tempResult3;
    DROP TABLE IF EXISTS #tempResult4;
    DROP TABLE IF EXISTS #tempResult5;
    DROP TABLE IF EXISTS #tmpSSN;
    DROP TABLE IF EXISTS #tempAdditionalData;
    DROP TABLE IF EXISTS #tempDates;

	
	--code added by vairavan for ticket id -54476 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -54476 ends


	
	 SELECT 
	 a.APNO, a.CLNO, a.PackageID,a.DeptCode, cast(AffiliateID as varchar) as AffiliateID,

           DATENAME(MONTH, a.OrigCompDate) [Report Month],
           a.CLNO [Client ID],
           Name [Client Name],
           c.[State] AS [Client State],
           a.ClientApplicantNO AS [CandidateID],
           Attn AS [Contact Name],
           a.APNO AS [Report Number],
           FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Report Create Date',
           FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Closed Date',
           FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
           FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date',
           CASE
               WHEN a.ApStatus = 'F' THEN
                   'Complete'
               WHEN a.ApStatus = 'P' THEN
                   'InProgress'
               WHEN a.ApStatus = 'M' THEN
                   'OnHold'
               WHEN a.ApStatus = 'W' THEN
                   'Wait On Money'
           END AS [Report Status],
           a.EnteredVia AS 'Submitted Via',
           c.CAM,
           a.Pos_Sought AS [PositionSought],
           a.Last [Applicant Last],
a.First [Applicant First],
           a.SSN,
           a.DOB,
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 0, NULL) [Package Price],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 1, NULL) [Pass through Fees],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 2, 'crimpassthru') [Criminal Cost],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 2, 'crim') [Crim Addtl Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 3, NULL) [Civil Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 4, 'social') [Social Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 4, 'credit') [Credit Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 5, NULL) [MVR Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 6, NULL) [Emp Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 7, NULL) [Edu Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 8, NULL) [Lic Charges],
           [dbo].[GetInvoiceDetailPerSection_Doug](a.APNO, 9, NULL) [Reference Charges],
           (dbo.ElapsedBusinessDays_2(a.ApDate, a.OrigCompDate)) AS [Turnaround],
		   (dbo.ElapsedBusinessDays_2(a.ReopenDate, a.CompDate)) AS [Reopen Turnaround],
		   --(dbo.ElapsedBusinessDays_2(a.ApDate, a.OrigCompDate) + dbo.ElapsedBusinessDays_2(a.ReopenDate, a.CompDate)) AS [Reopen Turnaround],
           (dbo.ElapsedBusinessHours_2(a.ApDate, a.OrigCompDate)) AS [Business Hours],
           DATEDIFF(HOUR, a.ApDate, a.OrigCompDate) AS [Calendar Time Hours],
           DATEDIFF(DAY, a.ApDate, a.OrigCompDate) AS [Calendar Time Days]
    INTO #temp1    
	FROM dbo.Appl A with (NOLOCK)
        INNER JOIN Client C  with (NOLOCK)  ON A.CLNO = C.CLNO
    WHERE (
              @CLNO IS NULL
              OR A.CLNO IN
                 (
                     SELECT * FROM [dbo].[Split](':', @CLNO)
                 )
          )
          AND A.OrigCompDate  BETWEEN @StartDate AND DATEADD(d, 1, @EndDate)
          AND A.CLNO NOT IN ( 3468 /*Bad apps*/, 2135 /*demo account*/, 3079 /*demo account*/ )
         -- AND C.AffiliateID = IIF(@AffiliateID = 0, C.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -54476.
		  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -54476
          AND C.CAM = IIF(@CAM IS NULL, C.CAM, @CAM);
		   
		   
		   
		
   --select * from #temp1;
   
   
   
    SELECT DISTINCT
           APNO,
           CNTY_NO
    INTO #temp2
    FROM Crim with(NOLOCK)
    WHERE APNO IN
          (
              SELECT APNO FROM #temp1
          )
          AND IsHidden = 0;

    -- to see if the person has multiple applications (with same SSN) we will obviously need a valid SSN, otherwise it will not be a multiple application for same person!
    SELECT b.[SSN],
           COUNT(*) [NoOfSSNs]
    INTO #tmpSSN
    FROM
    (
        SELECT [SSN]
        FROM [dbo].[Appl] a with(nolock)
        WHERE a.[SSN] IN
              (
                  SELECT DISTINCT -- We can safely eliminate any invalid SSNs here!
                         CASE
                             WHEN [SSN] IS NULL
                                  OR LTRIM(RTRIM([SSN])) = ''
                                  OR LEN([SSN]) <> 11 THEN
                                 NULL
                             ELSE
                                 [SSN]
                         END [SSN]
                  FROM [dbo].[Appl] with(nolock)
                  WHERE [APNO] IN
                        (
                            SELECT APNO FROM #temp1
                        )
              )
    ) b
    GROUP BY b.[SSN];


    SELECT ad.APNO,
           Crim_SelfDisclosed,
           DateUpdated
    INTO #tempAdditionalData
    FROM ApplAdditionalData ad   with (NOLOCK) 
    WHERE ad.APNO IN
          (
              SELECT APNO FROM #temp1
          )
          AND DateUpdated =
          (
              SELECT MAX(DateUpdated)FROM ApplAdditionalData WHERE APNO = ad.APNO
          )
    ORDER BY DateUpdated DESC;

-- optomization changes -- 
 IF OBJECT_ID('tempdb..#tempcrimcount') IS NOT NULL
 DROP TABLE #tempcrimcount

CREATE TABLE #tempcrimcount
(
   Apno INT 
  ,crimcount INT
)
		INSERT INTO #tempcrimcount
		 SELECT APNO, COUNT(1) crimcount FROM #temp2 GROUP BY APNO

--	Select count(*) from #tempcrimcount	

 IF OBJECT_ID('tempdb..#tempEmplcount') IS NOT NULL
 DROP TABLE #tempEmplcount

CREATE TABLE #tempEmplcount
(
   Apno INT 
  ,Emplcount INT
)
		INSERT INTO #tempEmplcount	
		   SELECT Empl.Apno,  COUNT(1) Emplcount
			FROM Empl with(NOLOCK) join #temp1 a on Empl.apno= a.apno
			WHERE Empl.IsOnReport = 1
			  AND Empl.IsHidden = 0
			GROUP BY Empl.Apno order by APno

--	Select count(*) from #tempEmplcount	


 IF OBJECT_ID('tempdb..#tempEducatcount') IS NOT NULL
 DROP TABLE #tempEducatcount

CREATE TABLE #tempEducatcount
(
   Apno INT 
  ,Educatcount INT
)
INSERT INTO #tempEducatcount
			  
			  SELECT Educat.APNO, COUNT(1) Educatcount
				FROM Educat with(NOLOCK) join #temp1 a on Educat.apno= a.apno
				WHERE Educat.IsOnReport = 1
					  AND Educat.IsHidden = 0
				GROUP BY Educat.APNO
 
  IF OBJECT_ID('tempdb..#tempLicensecount') IS NOT NULL
 DROP TABLE #tempLicensecount

CREATE TABLE #tempLicensecount
(
   Apno INT 
  ,Licensecount INT
)
INSERT INTO #tempLicensecount  
		SELECT ProfLic.Apno, COUNT(1) Licensecount
				FROM ProfLic with (NOLOCK) join #temp1 a on ProfLic.apno= a.apno
				WHERE ProfLic.IsOnReport = 1
					  AND ProfLic.IsHidden = 0
				GROUP BY ProfLic.Apno




 IF OBJECT_ID('tempdb..#tempSocialcount') IS NOT NULL
 DROP TABLE #tempSocialcount

CREATE TABLE #tempSocialcount
(
   Apno INT 
  ,Socialcount INT
)
INSERT INTO #tempSocialcount

		SELECT Credit.APNO, COUNT(1) Socialcount
				FROM Credit with(NOLOCK) join #temp1 a on Credit.apno= a.apno
				WHERE Credit.RepType = 'S'
				GROUP BY Credit.APNO
	
	
	
	

 IF OBJECT_ID('tempdb..#tempMVRcount') IS NOT NULL
 DROP TABLE #tempMVRcount

CREATE TABLE #tempMVRcount
(
   Apno INT 
  ,MVRcount INT
)
INSERT INTO #tempMVRcount			 
		SELECT DL.APNO, COUNT(1) MVRcount FROM DL with(NOLOCK)  join #temp1 a on DL.apno= a.apno  GROUP BY DL.APNO
 

--	Select count(*) from #tempMVRcount

 
 IF OBJECT_ID('tempdb..#tempMedicarecount') IS NOT NULL
 DROP TABLE #tempMedicarecount

CREATE TABLE #tempMedicarecount
(
   Apno INT 
  ,Medicarecount INT
)
INSERT INTO #tempMedicarecount


		  SELECT MedInteg.APNO, COUNT(1) MedicareCount
				FROM MedInteg with (NOLOCK) join #temp1 a on MedInteg.apno= a.apno
				GROUP BY MedInteg.APNO

--	Select count(*) from #tempMedicarecount;		
	
 IF OBJECT_ID('tempdb..#tempCreditcount') IS NOT NULL
 DROP TABLE #tempCreditcount

CREATE TABLE #tempCreditcount
(
   Apno INT 
  ,Creditcount INT
)
INSERT INTO #tempCreditcount
	
			 
		  SELECT credit.APNO, COUNT(1) Creditcount
				FROM Credit with (NOLOCK) join #temp1 a on credit.apno= a.apno
				WHERE RepType = 'C'
				GROUP BY credit.APNO


 IF OBJECT_ID('tempdb..#tempReferencecount') IS NOT NULL
 DROP TABLE #tempReferencecount

CREATE TABLE #tempReferencecount
(
   Apno INT 
  ,Referencecount INT
)
INSERT INTO #tempReferencecount
	 
 
   SELECT APNO, COUNT(1) Referencecount
				FROM PersRef with (NOLOCK)
				WHERE PersRef.IsOnReport = 1
					  AND PersRef.IsHidden = 0
				GROUP BY APNO
--Select count(*) from #tempReferencecount;			 

 IF OBJECT_ID('tempdb..#tempCivilcount') IS NOT NULL
 DROP TABLE #tempCivilcount

CREATE TABLE #tempCivilcount
(
   Apno INT 
  ,Civilcount INT
)
INSERT INTO #tempCivilcount
	  SELECT APNO, COUNT(1) Civilcount
				FROM Civil with (NOLOCK)
				GROUP BY APNO;
	
	
IF OBJECT_ID('tempdb..#tempEnterprise') IS NOT NULL
 DROP TABLE #tempEnterprise

CREATE TABLE #tempEnterprise
(
   Apno INT ,
   [IsMCICOrder] bit
)
INSERT INTO #tempEnterprise			
SELECT OrderNumber, [IsMCICOrder]
  FROM [Enterprise].[Report].[InvitationTurnaround]  with (NOLOCK)
  

    SELECT DISTINCT
           [Report Month],
           [Client ID],
           [Client Name],
           [Client State],
           ra.Affiliate,
           [CandidateID],
           [Contact Name],
           [Report Number],
           [Report Create Date],
           [Original Closed Date],
           [Reopen Date],
           [Complete Date],
           [Report Status],
           [Submitted Via],
           CAM,
           [PositionSought],
           [Applicant Last],
           [Applicant First],
           a.SSN,
           a.DOB,
           CASE WHEN ISNULL(apd.Crim_SelfDisclosed, 0) = 0 THEN  'False'  ELSE 'True' END AS [Admitted Crim],
           ISNULL(crimcount, 0) [Crim Count],
           ISNULL(Emplcount, 0) [Emp Count],
           ISNULL(Educatcount, 0) [Edu Count],
           ISNULL(Licensecount, 0) [Lic Count],
           ISNULL(Socialcount, 0) PID,
           ISNULL(MedicareCount, 0) [Sanctions],
           ISNULL(MVRcount, 0) [MVR Count],
           ISNULL(Creditcount, 0) [Credit],
           ISNULL(Referencecount, 0) [Reference Count],
           ISNULL(Civilcount, 0) [Civil Count],
           SUBSTRING(Description, 10, LEN(Description)) PackageDesc,
           PackageDesc [SelectedPackage],
           [Package Price],
           [Pass through Fees],
           [Criminal Cost],
           [Crim Addtl Charges],
           [Civil Charges],
           [Social Charges],
           [Credit Charges],
           [MVR Charges],
           [Emp Charges],
           [Edu Charges],
           [Lic Charges],
           [Reference Charges],
           [Turnaround],
           [Reopen Turnaround],
           [Business Hours],
           [Calendar Time Hours],
           [Calendar Time Days] ,
           CASE  WHEN ISNULL(F.IsOneHR, 0) = 0 THEN 'False' ELSE 'True' END  AS IsOneHR,
           CASE  WHEN t.NoOfSSNs > 1 THEN 'True' ELSE 'False' END AS [SSN Has prior report],
           CASE  WHEN ISNULL(IT.IsMCICOrder, 0) = 0 THEN 'False' ELSE 'True' END AS MCIC

    INTO #tempResult1

    FROM #temp1 a (NOLOCK)
         INNER JOIN refAffiliate ra with (NOLOCK)
            ON a.AffiliateID = ra.AffiliateID -- changed the affiliate of Client and refAffiliate left to right

		left join #tempcrimcount crim  with (NOLOCK) ON a.APNO = crim.APNO
		left join #tempEmplcount Empl  with (NOLOCK) ON a.APNO = Empl.Apno
		left join #tempEducatcount Educat  with (NOLOCK) ON a.APNO = Educat.APNO
		left join #tempLicensecount ProfLic  with (NOLOCK)  ON a.APNO = ProfLic.Apno
		left join #tempSocialcount Social with (NOLOCK)  ON a.APNO = Social.APNO
		left join #tempMedicarecount MedInteg with (NOLOCK)   ON a.APNO = MedInteg.APNO
		left join #tempMVRcount DL with (NOLOCK)  ON a.APNO = DL.APNO
		left join #tempCreditcount Credit  with (NOLOCK)  ON a.APNO = Credit.APNO
		left join #tempReferencecount PersRef  with (NOLOCK) ON a.APNO = PersRef.APNO
		left join #tempCivilcount Civil   with (NOLOCK) ON a.APNO = Civil.APNO
	    LEFT JOIN InvDetail Inv with (NOLOCK)
            ON a.APNO = Inv.APNO
               AND Type = 0 -- changed the APNO of APPL and InvDetail left to right
        LEFT JOIN PackageMain p with(NOLOCK)
            ON a.PackageID = p.PackageID
        LEFT JOIN HEVN.dbo.Facility F with(NOLOCK)
            ON ISNULL(a.DeptCode, 0) = F.FacilityNum
               AND ISNULL(a.CLNO, 0) = F.FacilityCLNO
        LEFT JOIN #tempAdditionalData apd 
            ON a.APNO = apd.APNO
        LEFT JOIN #tmpSSN t 
            ON t.SSN = a.SSN  
		LEFT JOIN #tempEnterprise	 AS IT 
            ON a.APNO = IT.APNO



    SELECT *,
           ([Pass through Fees] + [Criminal Cost] + [Crim Addtl Charges] + [Civil Charges] + [Social Charges]
            + [Credit Charges] + [MVR Charges] + [Emp Charges] + [Edu Charges] + [Lic Charges] + [Reference Charges]
           ) AS [Total Additional Charges]
    INTO #tempResult3
    FROM #tempResult1;


   SELECT    [Report Month],
           [Client ID],
           [Client Name],
           [Client State],
           Affiliate,
           [CandidateID],
           [Contact Name],
           [Report Number],
           [Report Create Date],
           [Original Closed Date],
           [Reopen Date],
           [Complete Date],
           [Report Status],
           [Submitted Via],
           CAM,
           [PositionSought],
           [Applicant Last],
           [Applicant First],
           SSN,
           DOB,
           [Admitted Crim],
           [Crim Count],
           [Emp Count],
           [Edu Count],
           [Lic Count],
           PID,
           [Sanctions],
           [MVR Count],
           [Credit],
           [Reference Count],
           [Civil Count],
           PackageDesc,
           [SelectedPackage],
           [Package Price],
           [Pass through Fees],
           [Criminal Cost],
           [Crim Addtl Charges],
           [Civil Charges],
           [Social Charges],
           [Credit Charges],
           [MVR Charges],
           [Emp Charges],
           [Edu Charges],
           [Lic Charges],
           [Reference Charges],
		   [Total Additional Charges],
		   ([Total Additional Charges] + [Package Price]) AS [Total Spend],
           [Turnaround],
           [Reopen Turnaround],
           [Business Hours],
           [Calendar Time Hours],
           [Calendar Time Days] ,
		   IsOneHR,
		   [SSN Has prior report],
		   MCIC
		   
		   
    INTO #tempResult4
    FROM #tempResult3;


    SELECT 'Total' [Report Month],
           '' [Client ID],
           '' [Client Name],
           '' [Client State],
           '' Affiliate,
           '' AS [CandidateID],
           '' AS [Contact Name],
           '' [Report Number],
           '' [Report Create Date],
           '' [Original Closed Date],
           '' [Reopen Date],
           '' [Complete Date],
           '' [Report Status],
           '' AS 'Submitted Via',
           '' CAM,
           '' [PositionSought],
           '' [Applicant Last],
           '' [Applicant First],
           '' SSN,
           '' DOB,
           '' [Admitted Crim],
           SUM([Crim Count]) AS [Crim Count],
           SUM([Emp Count]) [Emp Count],
           SUM([Edu Count]) [Edu Count],
           SUM([Lic Count]) [Lic Count],
           SUM(PID) PID,
           SUM([Sanctions]) [Sanctions],
           SUM([MVR Count]) [MVR Count],
           SUM([Credit]) [Credit],
           SUM([Reference Count]) [Reference Count],
           SUM([Civil Count]) [Civil Count],
           '' PackageDesc,
           '' [SelectedPackage],
           SUM([Package Price]) [Package Price],
           SUM([Pass through Fees]) [Pass Through Fees],
           SUM([Criminal Cost]) [Crim Service Charge],
           SUM([Crim Addtl Charges]) [Crim Addtl Charges],
           SUM([Civil Charges]) [Civil Charges],
           SUM([Social Charges]) [Social Charges],
           SUM([Credit Charges]) [Credit Charges],
           SUM([MVR Charges]) [MVR Charges],
           SUM([Emp Charges]) [Emp Charges],
           SUM([Edu Charges]) [Edu Charges],
           SUM([Lic Charges]) [Lic Charges],
           SUM([Reference Charges]) [Reference Charges],
		   SUM([Total Additional Charges]) AS [Total Additional Charges],
           SUM([Total Spend]) AS [Total Spend],
           SUM([Turnaround]) AS [Turnaround],
           SUM([Reopen Turnaround]) AS [Reopen Turnaround],
           SUM([Business Hours]) AS [Business Hours],
           SUM([Calendar Time Hours]) AS [Calendar Time Hours],
           SUM([Calendar Time Days]) AS [Calendar Time Days],
           -- ,'' AS [Straight Hours based on HROC’s 24/7/365 operating hours]
           -- ,'' AS [Elapsed Business Hours]
           '' AS IsOneHR,
           '' [ReportHasPriorSSN],
           '' MCIC

    INTO #tempResult5
    FROM #tempResult4;

--select * from #tempResult4;
--select * from #tempResult5;

    SELECT DISTINCT
           *
    FROM
    (SELECT * FROM #tempResult4 UNION ALL SELECT * FROM #tempResult5) AS Y
    ORDER BY [Report Month],
             [Client ID];

END


