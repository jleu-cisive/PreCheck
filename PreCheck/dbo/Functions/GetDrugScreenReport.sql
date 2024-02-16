
-- =============================================  
-- Author:  Gaurav Bangia  
-- Create date: 04/12/2022  
-- Description: Returns drug test pdf report  
-- Modify By: Gaurav Bangia  
-- Modify Date: 5/4/2022  
-- Modification purpose: Bug-fix- for Paper COC records   
-- Select * from dbo.GetDrugScreenReport(6510612)  
-- modified by Lalit for 104665 on 16 aug 2023
-- =============================================  
CREATE FUNCTION [dbo].[GetDrugScreenReport]  
(  
 -- Add the parameters for the function here  
 @OrderNumber INT  
)  
RETURNS    
@DrugReport TABLE   
(  
 ReportId int,  
 PdfReport nvarchar(MAX),  
 TID INT,  
 Reason varchar(50),  
 AddedOn Datetime  
)  
AS  
BEGIN  
 ----declare @OrderNumber int=7491923--7504905--7522630 --- disable this
 DECLARE @tid INT   
 DECLARE @tid1 INT
 DECLARE @tid2 INT
   DECLARE @tidpdf int
   DECLARE @date1 datetime
   DECLARE @date2 datetime
 SELECT  
 @tid1=TID,@date1=CTE.LastUpdate 
 FROM   
 dbo.OCHS_ResultDetails CTE  
 INNER JOIN  
 (  
  SELECT  
  OrderIDOrApno=R.OrderIDOrApno,  
  LastUpdate=MAX(R.LastUpdate)  
  FROM dbo.OCHS_ResultDetails R   WITH(NOLOCK)
  WHERE ISNUMERIC(R.OrderIDOrApno)=1  
  
  GROUP BY R.OrderIDOrApno  
 ) L   
 ON CTE.OrderIDOrApno=L.OrderIDOrApno  AND CTE.LastUpdate=L.LastUpdate  
 LEFT OUTER JOIN dbo.OCHS_CandidateInfo ci   WITH(NOLOCK) 
  ON CTE.OrderIDOrApno=CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)  
 WHERE ci.APNO=@OrderNumber  

 SELECT @tidpdf=tid FROM dbo.vwDrugReport dr  WHERE dr.tid=@tid  

 IF(@tidpdf IS NULL)  
 BEGIN  
  -- Checking for possible case where it is a StudentCheck order but no scheduling (paper COC)  
  -- The solution is to look for an alternative and find the TID directly from the result details table  
  SELECT  
  @tid2=TID,@date2=CTE.LastUpdate  
  FROM   
  dbo.OCHS_ResultDetails CTE  
  INNER JOIN  
  (  
   SELECT  
   OrderIDOrApno=R.OrderIDOrApno,  
   LastUpdate=MAX(R.LastUpdate)  
   FROM dbo.OCHS_ResultDetails R   WITH(NOLOCK)
   WHERE ISNUMERIC(R.OrderIDOrApno)=1  
  
   GROUP BY R.OrderIDOrApno  
  ) L   
  ON CTE.OrderIDOrApno=L.OrderIDOrApno  AND CTE.LastUpdate=L.LastUpdate  
  INNER JOIN dbo.Appl a  WITH(NOLOCK) ON cte.OrderIDOrApno=CONVERT(VARCHAR(25),a.APNO)  AND RTRIM(LTRIM(CTE.LastName))=RTRIM(LTRIM(a.Last))  --AND CTE.CLNO=A.CLNO  
  LEFT JOIN Client c WITH(NOLOCK) ON a.CLNO=c.CLNO 
  LEFT JOIN Client c2 WITH(NOLOCK) ON cte.CLNO=c2.CLNO
  WHERE CONVERT(VARCHAR(25),@OrderNumber) = cte.OrderIDOrApno  
  AND (c.WebOrderParentCLNO=c2.WebOrderParentCLNO OR CTE.CLNO=A.CLNO)  
    END  
    if(coalesce(@date1,0)>=coalesce(@date2,0))
	  begin
	  set @tid=@tid1
	  end
	  else
	  begin
	  set @tid=@tid2
	  end   
 INSERT INTO @DrugReport(ReportId, PDFReport, TID, Reason, AddedOn)  
 SELECT DR.ID,dr.PDFReport, DR.tid, DR.Reason, DR.AddedOn  FROM dbo.vwDrugReport dr   WITH(NOLOCK) 
 WHERE dr.tid=@tid  
   
 RETURN   
  
END  
