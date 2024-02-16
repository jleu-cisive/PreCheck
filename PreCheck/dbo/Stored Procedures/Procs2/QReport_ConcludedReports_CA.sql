  
-- =============================================  
-- Author:  James Norton  
-- Create date: 10/14/20121  
-- Description: PENDING REOPENDED REPORTS/UPDATED REPORTS  
-- Execution: EXEC QReport_ConcludedReports_CA '09/01/2018', '09/30/2019',0,0,0
-- Modified By Mainak Bhadra for Ticket No.55501,modifiing Old parameter @AffiliateId int to Varchar(max) for using multiple Affiliate IDs separated with : 
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_ConcludedReports_CA]  
 -- Add the parameters for the stored procedure here  
 @CLNO INT,  
 --@AffiliateID INT, --code commented by Mainak for ticket id -55501
 @AffiliateID varchar(MAX) = '0',--code added by Mainak for ticket id -55501 
 @StartDate datetime,  
 @EndDate datetime  
AS  
BEGIN  
  
 SET ANSI_WARNINGS OFF   
  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED  
  
 --code added by Mainak for ticket id -55501 starts
	IF @AffiliateID = '0' 
	BEGIN  
		SET @AffiliateID = NULL  
	END
 --code added by Mainak for ticket id -55501 ends
  
 --DECLARE temp tables (helps to maintain the same plan regardless of stats change)  
 CREATE TABLE #tmp(  
  [APNO] [int] NOT NULL,  
  [CLNO] [smallint] NOT NULL,  
  [ClientName] [varchar](100) NULL,  
  [AffiliateName] [varchar](100) NULL,  
  [Applicant First Name] [varchar](20) NOT NULL,  
  [Applicant Last Name] [varchar](20) NOT NULL,  
  [Report Create Date] [datetime] NULL,    --Original Close Dat  
  [Original Closed Date] [datetime] NULL,    --Original Close Dat  
  [Reopen Date] [datetime] NULL,    --Original Close Dat  
  [Complete Date] [datetime] NULL)   --Original Close Date);  
   
   
  
  --Index on temp tables  
 CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp(APNO)  
  
  
 -- Get all the "Finalized" reports  
 INSERT INTO #tmp  
 SELECT APNO, A.CLNO, C.Name AS ClientName, RA.Affiliate, A.First AS [Applicant First Name], A.Last AS [Applicant Last Name]  
  ,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Report Create Date'  
        ,FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Closed Date'  
        ,FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'  
        ,FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'  
 FROM dbo.Appl(NOLOCK) AS A  
 INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO  
 INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID  
 WHERE  ApStatus = 'F'   
   AND A.CLNO NOT IN (2135,3468) AND (@CLNO IS NULL OR C.CLNO = @CLNO)  
   AND cast(CompDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
   --AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID) --code commented by Mainak for ticket id -55501
   AND (@AffiliateID IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateID,':')))--code added by Mainak for ticket id -55501   
  
 Select * from #tmp;  
  
  DROP TABLE #tmp  
  
  
END  
  