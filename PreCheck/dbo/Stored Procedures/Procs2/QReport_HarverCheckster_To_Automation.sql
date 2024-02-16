

-- =============================================  
-- Author:  Arindam Mitra  
-- Requested by: Michelle Paz HDT:124404  
-- Description: This Qreport will show the total number of employment records that were passed through The HarverCheckster Automation along with the details  
-- Create date: 01/30/2024  
-- Execution: EXEC [QReport_HarverCheckster_To_Automation] '01/01/2024', '01/31/2024'  
-- =============================================  
create PROCEDURE [dbo].[QReport_HarverCheckster_To_Automation]  
 -- Add the parameters for the stored procedure here  
 @StartDate DateTime,   
 @EndDate DateTime  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
  
 SELECT pr.Apno, pr.Name AS [Employer Name], S.[Description] AS [Status],WSS.[description] AS [Web Status],   
   (CASE WHEN LEN(LTRIM(RTRIM(USERID))) <=8 THEN LTRIM(RTRIM(UserID)) ELSE  SUBSTRING ( LTRIM(RTRIM(UserID)) ,1 , LEN(LTRIM(RTRIM(UserID))) -5) END) AS UserID,  
   lg.ChangeDate AS [Date]  
 FROM dbo.ChangeLog AS lg (NOLOCK)   
 INNER JOIN dbo.persRef AS pr (NOLOCK) ON lg.ID = pr.PersRefID  
 INNER JOIN dbo.SectStat AS S(NOLOCK) ON pr.SectStat = S.Code  
 INNER JOIN dbo.Websectstat AS WSS(NOLOCK) ON pr.web_status = WSS.code  
 WHERE lg.TableName = 'PersRef.web_status'   
  AND lg.NewValue = '104'  
  AND lg.changedate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))  
 ORDER BY lg.ChangeDate DESC  
  
  
END  