-- =============================================  
-- Author:  MAINAK BHADRA  
-- Create date: <07/29/2022>  
-- Description: <Search for SJV Response ALL from apno or EmplID or OrderID for project: IntranetModule-Status-SubStatus phase2 UAT test >  
-- parameters: '0' for all apnos; 0 for all OrderID; 0 for all emplID.  
-- exec [dbo].[QReport_GetSJVAllOrderStatusFromOrderIDAPNO_rollback] @APNO=5200723,@OrderID='0'  
-- exec [dbo].[QReport_GetSJVAllOrderStatusFromOrderIDAPNO_rollback] @APNO=5331982,@OrderID='0' 
-- exec [dbo].[QReport_GetSJVAllOrderStatusFromOrderIDAPNO_rollback] @APNO=6699639,@OrderID='0'
  
-- =============================================  
  
CREATE PROCEDURE [dbo].[QReport_GetSJVAllOrderStatusFromOrderIDAPNO_rollback]  
@APNO int = 0,  
@OrderID varchar(20) = ''  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
     
 DECLARE   
  @OrderIDs TABLE   
  (   
    OrderID VARCHAR(20)   
   ,APNO INT  
   ,EmplID INT  
  )  
 IF (ISNULL(NULLIF(@OrderID,'0'),'')='' AND ISNULL(NULLIF(@APNO,'0'),'')<>'')  
 BEGIN  
  
  INSERT INTO @OrderIDs  
  SELECT    
    e.OrderID   
   ,e.Apno  
   ,e.EmplID  
  FROM   
   empl e WITH(NOLOCK)  
  INNER JOIN   
   appl a WITH(NOLOCK)   
   ON a.Apno =e.apno  
  WHERE  
   (e.APNO=@APNO)   
  AND e.OrderId IS NOT NULL  
     
  SELECT  
    ord.APNO  
   ,ord.EmplID  
   ,ord.OrderID  
   ,ivord.Integration_VendorOrderId  
   ,ivord.VendorName  
   ,ivord.VendorOperation  
   ,ivord.Request  
   ,ivord.Response  
   ,ivord.CreatedDate  
  FROM   
   Integration_VendorOrder ivord WITH(NOLOCK)   
   inner join
	   (
		select max(Integration_VendorOrderId) Integration_VendorOrderId,o.OrderID 
		from Integration_VendorOrder ivo WITH(NOLOCK)   inner join @OrderIDs o on response.value('(//SubjectCtyID)[1]','varchar(max)') = o.OrderID 
		WHERE ivo.VendorName='SJV' AND ivo.CreatedDate>= DATEADD(YEAR,-1,GETDATE()) 
		group by o.OrderID
	   ) a on ivord.Integration_VendorOrderId=a.Integration_VendorOrderId
	inner join @OrderIDs ord on ord.OrderID=a.OrderID  
  ORDER BY   
   ivord.Integration_VendorOrderId DESC  
 END  
 ELSE  
 BEGIN  
	  SELECT   
		e.APNO  
	   ,e.EmplID  
	   ,e.OrderID  
	   ,ivord.Integration_VendorOrderId  
	   ,ivord.VendorName  
	   ,ivord.VendorOperation  
	   ,ivord.Request  
	   ,ivord.Response  
	   ,ivord.CreatedDate  
	  FROM   
	   Integration_VendorOrder ivord WITH(NOLOCK)   
	   inner join
		   (
			select max(Integration_VendorOrderId) Integration_VendorOrderId,@OrderID OrderID 
			from Integration_VendorOrder ivo 
			WHERE response.value('(//SubjectCtyID)[1]','varchar(max)') = @OrderID
			and ivo.VendorName='SJV' AND ivo.CreatedDate>= DATEADD(YEAR,-1,GETDATE()) 
		   ) a on ivord.Integration_VendorOrderId=a.Integration_VendorOrderId 
	  INNER JOIN  
	   empl e   
	   ON  a.OrderID = e.OrderID  
	  ORDER BY   
	   ivord.Integration_VendorOrderId DESC    
 END  
  
END  
   