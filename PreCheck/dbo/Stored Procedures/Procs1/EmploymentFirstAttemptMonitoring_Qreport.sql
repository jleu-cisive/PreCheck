-- =============================================
-- Author:           Humera Ahmed
-- Create date:      09/1/2020
-- Description:      A Q-report that can pull by client or affiliate to show details of the Employments First Attempt made.  
-- =============================================
CREATE PROCEDURE [dbo].[EmploymentFirstAttemptMonitoring_Qreport]
       -- Add the parameters for the stored procedure here
       @StartDate DateTime,
       @EndDate DateTime,
       @CLNO VARCHAR(500) = '0',
       @AffiliateID int = 0
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure here
       IF(@CLNO = ' ' OR @CLNO IS NULL OR @CLNO = 'null')
       BEGIN
              SET @CLNO = '0'
       END

       DROP TABLE IF EXISTS #Automation
       DROP TABLE IF EXISTS #PubNotes
       DROP TABLE IF EXISTS #FirstAttempts
    

       SELECT  REPLACE(USERID, '-empl','') UserID,id, dbo.empl.Employer, dbo.empl.Apno, dbo.ChangeLog.TableName, dbo.ChangeLog.OldValue, newvalue, dbo.ChangeLog.ChangeDate
       INTO #Automation
       FROM dbo.ChangeLog 
       INNER JOIN empl ON dbo.ChangeLog.ID = dbo.empl.EmplID
       where TableName like  'Empl.web_status'
       and ChangeDate>=@StartDate and ChangeDate<dateadd(d,1,@EndDate)
       AND (oldvalue = '0' OR oldvalue = '92')
       AND NewValue = '69'
  

       SELECT  REPLACE(USERID, '-empl','') userid,id,Employer,Apno,TableName,OldValue,NewValue,ChangeDate
       INTO #PubNotes
       FROM dbo.ChangeLog 
       INNER JOIN empl ON dbo.ChangeLog.ID = dbo.empl.EmplID
       where TableName like  'Empl.pub_notes'
       and ChangeDate>=@StartDate and ChangeDate<dateadd(d,1,@EndDate)
       AND isnull(oldvalue,'') = '' 
       AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(newvalue, CHAR(10), CHAR(32)),CHAR(13), CHAR(32)),CHAR(160), CHAR(32)),CHAR(9),CHAR(32)))) <>'' 


       SELECT DISTINCT tbl.userid [Investigator], id, tbl.Employer, tbl.Apno, tbl.ChangeDate
       INTO #FirstAttempts
       from
       (
       SELECT userid,id,Employer,Apno,oldvalue, newvalue, ChangeDate FROM #Automation 
       UNION ALL
       SELECT userid,id,Employer,Apno,oldvalue, newvalue, ChangeDate FROM #PubNotes
       )tbl

       SELECT 
              fa.Apno [Report #]
              , fa.Employer [Employer Name]
              , fa.Investigator
              , format(a.ApDate, 'MM/dd/yyyy HH:mm') [Report Date]
              , 'Yes' [First Attempt]
              , a.CLNO [Client ID]
              , c.Name [Client Name]
              , c.AffiliateID
              , ra.Affiliate 
       FROM #FirstAttempts fa
              INNER JOIN dbo.Appl a ON fa.Apno = a.APNO
              INNER JOIN dbo.Client c ON a.CLNO = c.CLNO
              INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID
       WHERE 
              (ISNULL(@CLNO,'0') = '0' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))
              AND ra.AffiliateID = IIF(@AffiliateID =0, RA.AffiliateID, @AffiliateID)
       ORDER BY fa.Apno, fa.id
END
