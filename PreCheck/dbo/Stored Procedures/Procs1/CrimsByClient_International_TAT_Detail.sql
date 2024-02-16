-- =============================================  
-- Author: Radhika Dereddy  
-- Create date: 05/29/2019  
-- Description: New Q-Report Name: Crims by Client_International&TAT Details  
-- Modified by Radhika Dereddy on 05/31/2019 to add new columns Search Vendor,Name On Record,CaseNo,Date_Filed,Offense,Degree,Sentence,Fine,Disp_Date,Disposition  
-- select Clno from dbo.client where weborderparentCLNO = 15355  
-- Modified by Humera Ahmed on 6/29/2020 for HDT #74419  
-- Modified by Humera Ahmed on 10/06/2020 for HDT #74419  
-- Modified by Prasanna on 02/08/2021 for HDT#83362   
-- Modified by James Norton on 08/05/2021 for SQL Optimization   
-- EXEC [CrimsByClient_International_TAT_Detail] '01/01/2021','01/31/2021',15392, 230  

/* Modified By: YSharma 
-- Modified Date: 07/01/2022
-- Description: Ticketno-#54480 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*
EXEC CrimsByClient_International_TAT_Detail '08/01/2019','06/30/2022',0,'30:4:8'
EXEC CrimsByClient_International_TAT_Detail '01/01/2021','01/31/2021',15392,'230'  
EXEC CrimsByClient_International_TAT_Detail '01/01/2021','01/31/2021',15392,'0'  
*/
-- =============================================  
CREATE PROC dbo.CrimsByClient_International_TAT_Detail
(
    @startdate DATETIME,
    @enddate DATETIME,
    @clno INT,
    @AffiliateID VARCHAR(MAX) -- Added on the behalf for HDT #54480
-- @AffiliateID int  		 -- Comnt for HDT #54480
)
AS
BEGIN

    /* Radhika Dereddy - commenting the below on 02/04/2021 to match the PowerBi logic but this logic does not meet Misty's requirement so i had to comment it back*/
    /*  
;WITH cteApplIds AS  
(  
       SELECT a.APNO ReportNumber, a.OrigCompDate, c.CLNO, c.Name, c.State ClientState,ra.Affiliate, a.First ApplicantFirstName,   
  a.Last  ApplicantLastName,a.DOB, a.ApDate CreatedDate, a.ApStatus ReportStatus  
       FROM dbo.Appl a WITH (nolock)  
       INNER JOIN client c WITH (nolock) ON c.clno = a.clno  
       INNER JOIN dbo.ClientCertification cer (nolock) ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'  
    INNER JOIN refAffiliate ra on c.AffiliateID =ra.AffiliateID  
       WHERE (convert(date,a.OrigCompDate) between @StartDate and @EndDate)  
       AND a.CLNO = IIF(@CLNO=0,a.CLNO, @CLNO)  
       AND c.AffiliateID = IIF(@affiliateId=0,c.affiliateId, @affiliateId)   
       AND a.OrigCompDate IS NOT NULL  
),   
cteCrimIds AS  
(  
   SELECT app.ReportNumber, cr.CrimID, cr.County, d.a_county ApplicantCounty  
    , d.state State  
    , d.country Country  
       , IsInternational =  CASE WHEN ISNULL(d.refCountyTypeID, 0) = 5 THEN 1 ELSE 0 END  
       , cr.Clear, css.crimdescription RecordStatus  
       , RecordFound = CASE WHEN css.CrimDescription <> 'Clear' THEN 1 ELSE 0 END  
       , Degree = CASE   
              WHEN cr.Degree = '1' THEN 'Petty Misdemeanor'  
              WHEN cr.Degree = '2' THEN 'Traffic Misdemeanor'  
              WHEN cr.Degree = '3' THEN 'Criminal Traffic'  
              WHEN cr.Degree = '4' THEN 'Traffic'  
              WHEN cr.Degree = '5' THEN 'Ordinance Violation'  
              WHEN cr.Degree = '6' THEN 'Infraction'  
              WHEN cr.Degree = '7' THEN 'Disorderly Persons'  
              WHEN cr.Degree = '8' THEN 'Summary Offense'  
              WHEN cr.Degree = '9' THEN 'Indictable Crime'  
              WHEN cr.Degree = 'F' THEN 'Felony'  
              WHEN cr.Degree = 'M' THEN 'Misdemeanor'  
              WHEN cr.Degree = 'O' THEN 'Other'  
    WHEN cr.Degree = 'U' THEN 'Unknown'  
       END  
       ,cr.Crimenteredtime DateCreated, cr.Last_Updated LastUpdated,cr.Name NameOnRecord,cr.CaseNo,   
    cr.Date_Filed, cr.Offense,cr.Sentence ,  
       cr.Fine,   
       cr.Disp_Date ,  
       cr.Disposition,  
    app.OrigCompDate, app.CLNO, app.Name,app.ClientState, app.Affiliate, app.ApplicantFirstName,   
    app.ApplicantLastName,app.DOB, app.CreatedDate, app.ReportStatus  
       FROM [dbo].Crim cr WITH (nolock)  
       INNER JOIN cteApplIds app ON cr.APNO = app.ReportNumber  
       INNER JOIN dbo.TblCounties d (NOLOCK) ON cr.CNTY_NO = d.CNTY_NO   
       INNER JOIN Crimsectstat css  ON cr.Clear = css.crimsect  
    WHERE cr.IsHidden = 0         
)  
, cteChangeLogs AS  
(  
       SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate  
       FROM dbo.ChangeLog cl WITH (nolock)  
       INNER JOIN cteCrimIds cr  
              ON cl.ID = cr.CrimID  
       WHERE         
       convert(date,ChangeDate) between @StartDate and @EndDate  
       GROUP BY cl.ID  
), cteCrims AS  
(  
       SELECT cr.ReportNumber, cr.CrimID, cr.County,cr.ApplicantCounty  
    , cr.State  
    , cr.Country, cr.IsInternational, cr.Clear,cr.RecordStatus,cr.RecordFound, cr.Degree  
       , cr.DateCreated  
       , ComponentClosingDate = CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate  
        ELSE cr.LastUpdated END  
    , cr.NameOnRecord,cr.CaseNo   
    , cr.Date_Filed, cr.Offense,cr.Sentence  
       , cr.Fine   
       , cr.Disp_Date  
       , cr.Disposition  
    , cr.OrigCompDate, cr.CLNO, cr.Name,cr.ClientState,cr.Affiliate, cr.ApplicantFirstName   
    , cr.ApplicantLastName,cr.DOB, cr.CreatedDate, cr.ReportStatus  
       FROM cteCrimIds cr  
       LEFT JOIN cteChangeLogs cl ON cl.ID = cr.CrimID  
)  
SELECT *,   
       [dbo].[ElapsedBusinessDays_2](c.DateCreated,c.ComponentClosingDate)   as 'Criminal Turnaround Days'       
FROM cteCrims c  
where ComponentClosingDate is not null  
*/


    /* Radhika Dereddy commenting the below on 12/08/2020 to match the PowerBi logic */

    --SELECT c.CrimID,c.IrisOrdered into #crimsbydaterange   
    --FROM crim c(NOLOCK)  
    --inner join appl a(NOLOCK)  on c.apno = a.apno   
    --inner join dbo.TblCounties d(NOLOCK) on c.CNTY_NO = d.CNTY_NO    
    --inner join client cc(NOLOCK) on a.clno = cc.clno   
    --inner join refAffiliate ra(NOLOCK) on cc.AffiliateId = ra.AffiliateID   
    --where (convert(date,a.OrigCompDate) between @StartDate and @EndDate)  
    --       and a.CLNO = IIF(@CLNO=0,a.CLNO, @CLNO)  
    --       and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId)   
    --        --and c.Clear IN ('F','T','P')  

    ---- Get the most recent closed component from the changelog  
    --SELECT cdr.CrimID, c.ChangeDate, c.NewValue, cdr.IrisOrdered, ROW_NUMBER() over(PARTITION BY c.ID ORDER BY c.ChangeDate desc) as [Row]  
    --into #changelogfoundclosed   
    --from #crimsbydaterange cdr (NOLOCK)  
    --left JOIN ChangeLog c on c.ID = cdr.CrimID  
    ----where C.NewValue IN ('F','T','P')  
    --select   
    --       a.apno as 'Report Number',  
    --       cl.name as 'Client Name',  
    --       a.clno as 'Client ID',  
    --       cl.State as 'Client State',  
    --       ra.Affiliate as 'Affiliate',        
    --       a.First as 'Applicant First Name',   
    --       a.Last as 'Applicant Last Name',  
    --       FORMAT(a.DOB,'MM/dd/yyyy hh:mm tt') as 'DOB',   
    --       FORMAT(a.Apdate, 'MM/dd/yyyy hh:mm tt') as 'Created Date',  
    --       c.county as 'County',    
    --       d.a_county as 'Applicant County',  
    --       d.state as 'State',  
    --       d.country as 'Country' ,  
    --       CAST(DATEDIFF(d,c.IrisOrdered,clf.ChangeDate) as varchar)  as 'Criminal Turnaround Days',  
    --       CAST(DATEDIFF(HOUR,c.IrisOrdered,clf.ChangeDate) as varchar) as 'Criminal Turnaround Hours',  
    --       FORMAT(c.IrisOrdered, 'MM/dd/yyyy hh:mm tt') as 'Component Order Date',  
    --       FORMAT(clf.ChangeDate,'MM/dd/yyyy hh:mm tt') as 'Component Complete Date',  
    --       css.CrimDescription as 'Record Status',  
    --       a.ApStatus as 'ReportStatus',  
    --       case when d.refCountyTypeID = 5 then 'Yes' else 'No' end  as 'Is International',  
    --    a.OrigCompDate as [Original Closing Date],  
    --       ir.R_Name as 'Search Vendor',  
    --       CASE WHEN c.IsHidden = 1 THEN 'UnUsed'   
    --           WHEN C.IsHidden = 0 THEN 'On Report' End AS [Unused Crim],  
    --       C.Name as 'Name On Record',  
    --       c.CaseNo as 'CaseNo',   
    --       c.Date_Filed as 'Date_Filed',  
    --    c.Offense as 'Offense',   
    --       --K.Description as 'Degree',   
    --       case when c.Degree = '1' then 'Petty Misdemeanor'  
    --              WHEN c.Degree = '2' THEN 'Traffic Misdemeanor'  
    --              WHEN c.Degree = '3' THEN 'Criminal Traffic'  
    --              WHEN c.Degree = '4' THEN 'Traffic'  
    --              WHEN c.Degree = '5' THEN 'Ordinance Violation'  
    --              WHEN c.Degree = '6' THEN 'Infraction'  
    --              WHEN c.Degree = '7' THEN 'Disorderly Persons'  
    --              WHEN c.Degree = '8' THEN 'Summary Offense'  
    --              WHEN c.Degree = '9' THEN 'Indictable Crime'  
    --              WHEN c.Degree = 'F' THEN 'Felony'  
    --              WHEN c.Degree = 'M' THEN 'Misdemeanor'  
    --              WHEN c.Degree = 'O' THEN 'Other'  
    --              WHEN c.Degree = 'U' THEN 'Unknown'  
    --       END AS  'Degree',  
    --       c.Sentence as 'Sentence',  
    --       c.Fine as 'Fine',   
    --       c.Disp_Date as 'Disp_Date',  
    --       c.Disposition as 'Disposition'  
    --from crim c (NOLOCK)  
    --inner join appl a(NOLOCK)  on c.apno = a.apno   
    --inner join Client cl(NOLOCK) on a.CLNO = cl.CLNO  
    --inner join dbo.TblCounties d(NOLOCK)  on c.CNTY_NO = d.CNTY_NO   
    --inner join refAffiliate ra(NOLOCK) on cl.AffiliateId = ra.AffiliateID   
    --inner join #changelogfoundclosed clf on c.CrimID = clf.CrimID  
    --INNER JOIN Crimsectstat AS css  ON c.Clear = css.crimsect  
    --INNER JOIN IRIS_Researcher_Charges irc WITH (NOLOCK) ON C.vendorid = irc.Researcher_id AND C.CNTY_NO = irc.cnty_no AND irc.Researcher_Default = 'Yes'  
    --INNER JOIN dbo.Iris_Researchers ir WITH (nolock) ON irc.Researcher_id = ir.R_id  
    ----LEFT OUTER JOIN RefCrimDegree  AS K (NOLOCK) ON c.Degree = K.refCrimDegree  
    --where  (convert(date,a.OrigCompDate) between @StartDate and @EndDate)  
    --and a.CLNO = IIF(@CLNO=0,a.CLNO, @CLNO)  
    --and (clf.Row = 1 OR (clf.ChangeDate IS NULL and clf.NewValue IS NULL))  
    --and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId)  
    ----and c.Clear IN ('F','T','P')  
    --ORDER BY C.APNO  


    DROP TABLE IF EXISTS #crimsbydaterange;

    IF (
           @AffiliateID = ''
           OR LOWER(@AffiliateID) = 'null'
           OR @AffiliateID = '0'
       ) -- Added on the behalf for HDT #54480
    BEGIN
        SET @AffiliateID = NULL;
    END;


    IF (@clno = '' OR LOWER(@clno) = 'null' OR @clno = '0' OR @clno IS NULL) -- Added on the behalf for HDT #54480
    BEGIN
        SET @clno = 0;
    END;

    SELECT c.CrimID,
           c.IrisOrdered,
           a.APNO AS 'Report Number',
           cl.Name AS 'Client Name',
           a.CLNO AS 'Client ID',
           cl.State AS 'Client State',
           ra.Affiliate AS 'Affiliate',
           a.First AS 'Applicant First Name',
           a.Last AS 'Applicant Last Name',
           FORMAT(a.DOB, 'MM/dd/yyyy hh:mm tt') AS 'DOB',
           FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Created Date',
           c.County AS 'County',
           d.A_County AS 'Applicant County',
           d.State AS 'State',
           d.Country AS 'Country',
           (
               SELECT MAX(cl.ChangeDate)
               FROM ChangeLog cl (NOLOCK)
               WHERE cl.ID = c.CrimID
           ) AS ChangeDate,
           FORMAT(c.IrisOrdered, 'MM/dd/yyyy hh:mm tt') AS 'Component Order Date',
           css.crimdescription AS 'Record Status',
           a.ApStatus AS 'ReportStatus',
           CASE
               WHEN d.refCountyTypeID = 5 THEN
                   'Yes'
               ELSE
                   'No'
           END AS 'Is International',
           a.OrigCompDate AS [Original Closing Date],
           ir.R_Name AS 'Search Vendor',
           CASE
               WHEN c.IsHidden = 1 THEN
                   'UnUsed'
               WHEN c.IsHidden = 0 THEN
                   'On Report'
           END AS [Unused Crim],
           c.Name AS 'Name On Record',
           c.CaseNo AS 'CaseNo',
           c.Date_Filed AS 'Date_Filed',
           c.Offense AS 'Offense',
           CASE
               WHEN c.Degree = '1' THEN
                   'Petty Misdemeanor'
               WHEN c.Degree = '2' THEN
                   'Traffic Misdemeanor'
               WHEN c.Degree = '3' THEN
                   'Criminal Traffic'
               WHEN c.Degree = '4' THEN
                   'Traffic'
               WHEN c.Degree = '5' THEN
                   'Ordinance Violation'
               WHEN c.Degree = '6' THEN
                   'Infraction'
               WHEN c.Degree = '7' THEN
                   'Disorderly Persons'
               WHEN c.Degree = '8' THEN
                   'Summary Offense'
               WHEN c.Degree = '9' THEN
                   'Indictable Crime'
               WHEN c.Degree = 'F' THEN
                   'Felony'
               WHEN c.Degree = 'M' THEN
                   'Misdemeanor'
               WHEN c.Degree = 'O' THEN
                   'Other'
               WHEN c.Degree = 'U' THEN
                   'Unknown'
           END AS 'Degree',
           c.Sentence AS 'Sentence',
           c.Fine AS 'Fine',
           c.Disp_Date AS 'Disp_Date',
           c.Disposition AS 'Disposition'
    INTO #crimsbydaterange
    FROM Crim c WITH (NOLOCK)
        INNER JOIN Appl a WITH (NOLOCK)
            ON c.APNO = a.APNO
        INNER JOIN dbo.TblCounties d WITH (NOLOCK)
            ON c.CNTY_NO = d.CNTY_NO
        INNER JOIN Client cl WITH (NOLOCK)
            ON a.CLNO = cl.CLNO
        INNER JOIN refAffiliate ra WITH (NOLOCK)
            ON cl.AffiliateID = ra.AffiliateID
        INNER JOIN Crimsectstat AS css WITH (NOLOCK)
            ON c.Clear = css.crimsect
        INNER JOIN Iris_Researcher_Charges irc WITH (NOLOCK)
            ON c.vendorid = irc.Researcher_id
               AND c.CNTY_NO = irc.cnty_no
               AND irc.Researcher_Default = 'Yes'
        INNER JOIN dbo.Iris_Researchers ir WITH (NOLOCK)
            ON irc.Researcher_id = ir.R_id
    WHERE (CONVERT(DATE, a.OrigCompDate)
          BETWEEN @startdate AND @enddate
          )
          AND a.CLNO = IIF(@clno = 0, a.CLNO, @clno)
          AND
          (
              @AffiliateID IS NULL
              OR ra.AffiliateID IN
                 (
                     SELECT value FROM fn_Split(@AffiliateID, ':')
                 )
          ); -- Added on the behalf for HDT #54480
    --and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId) 						-- Comnt for HDT #54480	   
    --and c.Clear IN ('F','T','P')  


    SELECT c.[Report Number],
           c.[Client Name],
           c.[Client ID],
           c.[Client State],
           c.Affiliate,
           c.[Applicant First Name],
           c.[Applicant Last Name],
           c.DOB,
           c.[Created Date],
           c.County,
           c.[Applicant County],
           c.[State],
           c.[Country],
           CAST(DATEDIFF(d, c.IrisOrdered, c.ChangeDate) AS VARCHAR) AS 'Criminal Turnaround Days',
           CAST(DATEDIFF(HOUR, c.IrisOrdered, c.ChangeDate) AS VARCHAR) AS 'Criminal Turnaround Hours',
           c.[Component Order Date],
           FORMAT(c.ChangeDate, 'MM/dd/yyyy hh:mm tt') AS 'Component Complete Date',
           c.[Record Status],
           c.ReportStatus,
           c.[Is International],
           c.[Original Closing Date],
           c.[Search Vendor],
           c.[Unused Crim],
           c.[Name On Record],
           c.CaseNo,
           c.Date_Filed,
           c.Offense,
           c.[Degree],
           c.Sentence,
           c.Fine,
           c.Disp_Date,
           c.Disposition
    FROM #crimsbydaterange c (NOLOCK)
    ORDER BY c.[Report Number];


    DROP TABLE IF EXISTS #crimsbydaterange;
--drop table IF exists #changelogfoundclosed  



END;

