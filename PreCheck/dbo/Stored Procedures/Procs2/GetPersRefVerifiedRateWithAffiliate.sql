  
-- =============================================  
-- Author:           DEEPAK VODETHELA  
-- Create date: 01/11/2018  
-- Description:      PersRef Verified Rate with Affiliate Details  
-- Modified by Humera Ahmed on 4/26/2019 Please change the date column formats to mm/dd/yyyy hh:mm AM/PM.  
-- Modified by Humera Ahmed on 10/09/2020 for HDT#79551 Add SubStatus Column: Client Verified Rate - PersRef with Affiliate  
-- Execution :       EXEC [dbo].[GetPersRefVerifiedRateWithAffiliate] 0, '03/01/2018', '03/31/2018',177  
--                         EXEC [dbo].[GetPersRefVerifiedRateWithAffiliate] 0, '12/01/2017', '12/31/2017', 147  
-- Modified By Mainak Bhadra for Ticket No.55501,modifiing Old parameter @AffiliateId int to Varchar(max) for using multiple Affiliate IDs separated with : 
-- =============================================  
CREATE PROCEDURE [dbo].[GetPersRefVerifiedRateWithAffiliate]  
       -- Add the parameters for the stored procedure here  
       @clno int,  
       @Startdate date,  
       @Enddate date,  
       --@AffiliateID INT   --code commented by Mainak for ticket id -55501
	   @AffiliateID varchar(MAX) = '0'--code added by Mainak for ticket id -55501
AS  
BEGIN  
       -- SET NOCOUNT ON added to prevent extra result sets from  
       -- interfering with SELECT statements.  
       SET NOCOUNT ON;  

	   --code added by Mainak for ticket id -55501 starts
		IF @AffiliateID = '0' 
		BEGIN  
			SET @AffiliateID = NULL  
		END
	   --code added by Mainak for ticket id -55501 ends

         
    -- Insert statements for procedure here  
       SELECT DISTINCT [t0].APNO AS [Report Number],   
                     --Humera Ahmed on 4/26/2019 Please change the date column formats to mm/dd/yyyy hh:mm AM/PM.  
                     --[t0].ApDate AS [Report Date],  
                     FORMAT([t0].ApDate,'MM/dd/yyyy hh:mm:s tt') AS [Report Date],  
                     RA.Affiliate, [t0].CLNO AS [Client Number], c.[Name] AS [ClientName],   
                     [t0].ApStatus AS [Report Status], --Modified by Humera for Request ID:28506 on 1/15/2018, Adding 2 columns  
  
                     --Humera Ahmed on 4/26/2019 Please change the date column formats to mm/dd/yyyy hh:mm AM/PM.  
                     --ISNULL(CONVERT(varchar(50),  [t0].ReopenDate ,120),'N/A') as 'Re-Open Date',  
                     ISNULL(FORMAT([t0].ReopenDate,'MM/dd/yyyy hh:mm:s tt'),'N/A') as 'Re-Open Date',  
  
                     [t0].[Last] AS [Last Name], [t0].[First] AS [First Name], [t1].[Name] AS [PersRef Name], [t1].Phone AS [PersRef Phone#],  
                     [Y].[Description] AS [Status]  
                     , isnull(sss.SectSubStatus, '') as [SubStatus],  
                     I.Amount, [X].[Description] AS ClientAdjudicationStatus  
       FROM [Appl] AS [t0](NOLOCK)  
       INNER JOIN [PersRef] AS [t1](NOLOCK) ON [t0].APNO = [t1].APNO  
       INNER JOIN Client AS C(NOLOCK) on [t0].CLNO =   C.clno  
       INNER JOIN refAffiliate AS RA (NOLOCK) on C.AffiliateID= RA.AffiliateID   
       LEFT OUTER JOIN ClientAdjudicationStatus AS X(NOLOCK) ON [t1].ClientAdjudicationStatus = X.ClientAdjudicationStatusID  
       INNER JOIN SectStat AS Y(NOLOCK) ON [t1].SectStat = Y.Code  
       LEFT OUTER JOIN InvDetail AS I(NOLOCK) ON [t1].APNO = I.APNO AND I.[Description] LIKE '%Personal Reference%'  
       Left join dbo.SectSubStatus sss (nolock) on [t1].SectStat = sss.SectStatusCode and [t1].SectSubStatusID = sss.SectSubStatusID  
       WHERE ([t1].IsOnReport = 1)  
         AND ([t1].[IsHidden] = 0)  
      AND ([t0].ApStatus = 'F')  
         --AND (CONVERT(DATE,[t1].[Last_Worked]) >= @Startdate) AND (CONVERT(DATE,[t1].[Last_Worked]) <= @Enddate)  
         AND (CONVERT(DATE,[t0].[OrigCompDate]) >= @Startdate) AND (CONVERT(DATE,[t0].[OrigCompDate]) <= @Enddate)   
         AND [t0].CLNO = IIF(@CLNO = 0, C.CLNO, @CLNO)  
         --AND RA.AffiliateID = IIF(@AffiliateID = 0, RA.AffiliateID, @AffiliateID) --code commented by Mainak for ticket id -55501
		 AND (@AffiliateID IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateID,':')))--code added by Mainak for ticket id -55501
       ORDER BY [t0].APNO,[Report Date] --[t0].ApDate  
END  