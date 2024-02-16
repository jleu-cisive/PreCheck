-- Alter Procedure CrimsByClientInternationalTATDetail
-- =============================================
-- Author:           Radhika Dereddy
-- Create date: 03/09/2020
-- Description:      CrimsByClientInternationalTATDetail from PowerBi
-- EXEC CrimsByClientInternationalTATDetail '2019','08', 230
-- Modified by Humera Ahmed on 6/29/2020 for HDT#74419
 /* Modified By: Vairavan A
-- Modified Date: 07/12/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -55503 Velocity Q reports Part 2
*/
---Testing
/*
EXEC [dbo].[CrimsByClientInternationalTATDetail_CA] '6/11/2021','6/11/2022' ,'0','0'
EXEC [dbo].[CrimsByClientInternationalTATDetail_CA] '6/11/2019','6/11/2022' ,'0','4'
EXEC [dbo].[CrimsByClientInternationalTATDetail_CA] '6/11/2021','6/11/2022' ,'0','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[CrimsByClientInternationalTATDetail_CA]
       -- Add the parameters for the stored procedure 
       --@Year varchar(4),
       --@Month varchar(2),
	   @startdate datetime,
	   @enddate datetime,
       @clno int,
  	--@AffiliateID int,--code commented by vairavan for ticket id -53763(55503)
    @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763(55503)
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

   --code added by vairavan for ticket id -53763(55503) starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763(55503) ends

       ;WITH cteApplIds AS
(
       SELECT a.APNO
	   , a.OrigCompDate
	   , c.CLNO
	   , c.Name
       FROM dbo.Appl a WITH (nolock)
       INNER JOIN client c WITH (nolock)  ON c.clno = a.clno
       INNER JOIN dbo.ClientCertification cer with(nolock) ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	   inner join refAffiliate ra with(NOLOCK) on c.AffiliateId = ra.AffiliateID 
       --WHERE year(a.OrigCompDate) = @Year and month(a.OrigCompDate) = @Month
       --    AND c.AffiliateID IN (@AffiliateId)
       --    AND a.OrigCompDate IS NOT NULL
       WHERE (convert(date,a.OrigCompDate) between @StartDate and @EndDate)
		   and a.CLNO = IIF(@CLNO=0,a.CLNO, @CLNO)
		  -- and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId) --code commented by vairavan for ticket id -53763(55503)
		   and (@AffiliateIDs IS NULL OR ra.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(55503)




), cteCrimIds AS
(
       SELECT app.APNO
	   , cr.CrimID
	   , cr.County
       , IsInternational =  CASE WHEN ISNULL(d.refCountyTypeID, 0) = 5 THEN 1 ELSE 0 END
       , cr.Clear
   --    , RecordFound = CASE WHEN css.CrimDescription <> 'Clear' THEN 1 ELSE 0 END
       , css.CrimDescription as 'RecordStatus'
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
       , cr.Offense
	   , cr.Crimenteredtime DateCreated
	   , cr.Last_Updated LastUpdated
	   , app.OrigCompDate
	   , app.CLNO
	   , app.Name
       FROM [dbo].Crim cr WITH (nolock)
       INNER JOIN cteApplIds app
              ON cr.APNO = app.APNO
       INNER JOIN dbo.TblCounties d with(NOLOCK) 
              ON cr.CNTY_NO = d.CNTY_NO 
       INNER JOIN Crimsectstat css  with(NOLOCK) 
              ON cr.Clear = css.crimsect
       WHERE cr.IsHidden = 0 
       --AND cr.Clear IN ('F','T','P')
)
, cteChangeLogs AS
(
       SELECT cl.ID
	   , MAX(cl.ChangeDate) ChangeDate
       FROM dbo.ChangeLog cl WITH (nolock)
       INNER JOIN cteCrimIds cr
              ON cl.ID = cr.CrimID
       WHERE 
       --cl.NewValue IN ('F','T','P') AND 
       ---YEAR(ChangeDate) = @Year and month(ChangeDate) = @Month
	   (convert(date,ChangeDate) between @StartDate and @EndDate)
       GROUP BY cl.ID
), cteCrims AS
(
       SELECT cr.APNO
	   , cr.CrimID
	   , cr.County
	   , cr.IsInternational
	   , cr.Clear
	   , cr.RecordStatus
	   , cr.Degree
	   , cr.Offense
       , cr.DateCreated
       , ComponentClosingDate = CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
                     ELSE cr.LastUpdated END
       , cr.OrigCompDate
	   , cr.CLNO
	 , cr.Name
       FROM cteCrimIds cr
       LEFT JOIN cteChangeLogs cl 
              ON cl.ID = cr.CrimID
)

SELECT c.APNO as 'Report Number'
	   , c.CrimID
	   , c.County
	   , c.IsInternational as 'Is International'
	   , c.Clear as 'Record Status'
	   , c.RecordStatus as 'Record Description'
	   , c.Degree
	   , c.Offense
	   , FORMAT(c.DateCreated,			'MM/dd/yyyy hh:mm tt')	AS 'Date Created'
       , FORMAT(c.ComponentClosingDate, 'MM/dd/yyyy hh:mm tt')  AS 'Component Closing Date'
	   , FORMAT(c.OrigCompDate,			'MM/dd/yyyy hh:mm tt')	AS 'Orig Complete Date'
	   , c.CLNO as 'Client ID'
	   , c.Name as 'Client Name' 
       ,[dbo].[ElapsedBusinessDays_2](c.DateCreated,c.ComponentClosingDate)   as 'Criminal Turnaround Days'
       --,
       --[dbo].[ElapsedBusinessDays_2](c.DateCreated,c.ComponentClosingDate) as 'Criminal Turnaround Hours'
FROM cteCrims c
where ComponentClosingDate is not null


END


