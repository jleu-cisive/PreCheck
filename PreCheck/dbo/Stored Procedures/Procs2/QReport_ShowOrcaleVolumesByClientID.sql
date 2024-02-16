-- =============================================    
-- Author:  Amisha & Doug    
-- Create date: 10/12/2022     
-- Description: Shows Oracle Errors by Client ID    
-- QReport_ShowOrcaleVolumesByClientID 12444,null,null,null    
-- =============================================    
Create PROCEDURE dbo.QReport_ShowOrcaleVolumesByClientID    
-- Add the parameters for the stored procedure here    
 @CLNO int = 12444,       
 @ChildCLNO int = null,    
 @FromDate DateTime = null,    
 @ToDate DateTime = null    
    
AS    
BEGIN    
Declare @TargetDate DateTime = '2022-09-30 16:33';    
Declare @RequestIDCount int = null;    
Declare @P1 int,@P2 int,@P3 int = null;    
    
IF @FromDate < @TargetDate OR @FromDate is null    
 SET @FromDate = @TargetDate     
    
IF @ToDate is null    
 SET @ToDate = getdate();    
   
SET NOCOUNT ON;      
   
SELECT @P1 = count(DISTINCT IOR.RequestID) FROM [Precheck].[dbo].[Integration_OrderMgmt_Request] IOR    
where IOR.CLNO=@CLNO and IOR.FacilityCLNO = coalesce(@ChildCLNO,IOR.FacilityCLNO)      
and IOR.RequestDate between coalesce(@FromDate,IOR.RequestDate) and coalesce(@ToDate,IOR.RequestDate)      
    
SELECT @P2 = count(DISTINCT IOR.RequestID) FROM [Precheck].[dbo].[Integration_OrderMgmt_Request] IOR    
INNER JOIN [Precheck].[dbo].[Appl] a on a.APNO = IOR.APNO    
where IOR.CLNO=@CLNO and IOR.FacilityCLNO = coalesce(@ChildCLNO,IOR.FacilityCLNO)       
and IOR.RequestDate between coalesce(@FromDate,IOR.RequestDate) and coalesce(@ToDate,IOR.RequestDate)      
AND IOR.APNO is not null and a.apdate is null    
      
SELECT @P3 = count(DISTINCT IOR.RequestID) FROM [Precheck].[dbo].[Integration_OrderMgmt_Request] IOR    
INNER JOIN [Precheck].[dbo].[Appl] a on a.APNO = IOR.APNO    
where IOR.CLNO=@CLNO and IOR.FacilityCLNO = coalesce(@ChildCLNO,IOR.FacilityCLNO)      
and IOR.RequestDate between coalesce(@FromDate,IOR.RequestDate) and coalesce(@ToDate,IOR.RequestDate)      
AND IOR.APNO is not null AND a.APSTATUS = 'F'    
    
SELECT @P1 AS [Total number of invitations ordered] ,     
@P2 AS [Total number of invitations awaiting certifications],    
@P3 AS [Total number of reports closed]    
    
END 