-- =============================================    
-- Author:  Amisha & Doug    
-- Create date: 10/12/2022     
-- Description: Shows Oracle Errors by Client ID    
-- QReport_ShowOrcaleErrorsByClientID 12444,null,null,null    
-- =============================================    
CREATE PROCEDURE dbo.QReport_ShowOrcaleErrorsByClientID    
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
    
--SELECT @P1 AS [Total number of invitations ordered] ,     
--@P2 AS [Total number of invitations awaiting certifications],    
--@P3 AS [Total number of reports closed]    
    
;WITH TopFailedRecord AS (        
SELECT      
replace(SA.FirstName,',',' ') As FirstName,      
replace(SA.LastName,',',' ') As LastName,      
IOR.Partner_Reference As [Candidate ID],      
IOR.UserName As Requestor,      
IOR.Partner_Tracking_Number As [Requisition Number],      
IOR.RequestDate AS OrderDate,    
IOR.FacilityCLNO AS ChildAccountNumber,    
PRP.CreateDate As [Time/Date stamp of failure],      
IOR.APNO as ReportNumber,      
replace(PRP.ResponsePayload,',',' ') As [Error message received],      
IOR.RequestID as RequestID,      
IOR.CLNO,      
ROW_NUMBER() OVER(PARTITION BY IOR.APNO  ORDER BY PRP.CreateDate DESC) AS row_number      
From [Precheck].[dbo].[Integration_OrderMgmt_Request] IOR With (nolock)      
Inner join [Precheck].[dbo].[PartnerRequestParameters] PRP With (nolock) ON IOR.RequestID = PRP.RequestId      
Inner Join [Enterprise].Staging.vwStageApplicant SA With (nolock) ON SA.IntegrationRequestId = IOR.RequestID      
Where  HttpResponseCode not Like '2%'       
AND IOR.CLNO = @CLNO    
AND PRP.ResponsePayload like '%{%'      
and IOR.FacilityCLNO = coalesce(@ChildCLNO,IOR.FacilityCLNO)      
and PRP.CreateDate between coalesce(@FromDate,PRP.CreateDate) and coalesce(@ToDate,PRP.CreateDate)      
)      
    
SELECT FirstName,LastName,ChildAccountNumber,ReportNumber,RequestID,[Requisition Number],OrderDate,[Time/Date stamp of failure],[Error message received]       
FROM TopFailedRecord With (nolock) WHERE row_number = 1 ORDER BY [Time/Date stamp of failure] DESC ,requestid DESC      
    
END 