-- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 09/26/2016  
-- Description: When billing is run at the beginning of each month there are multiple items which fail which requires a CAM to go in and fix,  
-- and holds up the billing dept.    
-- Modified by Radhika Dereddy on 08/31/2021 to change the Apdate from 2016 to 2019 and add linked server.  
-- =============================================  
 CREATE PROCEDURE [dbo].[ClientServices_Billing]  
 -- Add the parameters for the stored procedure here  
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  
 DROP TABLE IF EXISTS #tmpBilling  
 DROP TABLE IF EXISTS #tmpClientBilling  
  
 UPDATE a  
 SET a.PackageID = cp.PackageID  
 FROM [ALA-SQL-05].Precheck.[dbo].appl a  
 INNER JOIN [ALA-SQL-05].Precheck.[dbo].ClientPackages cp on cp.clno = a.clno  
 WHERE a.Apstatus = 'F'   
 AND a.Billed =0   
 AND a.PackageID IS NULL   
 AND a.apdate > '01/01/2020'   
 AND a.CLno in (select cp.clno from [ALA-SQL-05].Precheck.[dbo].ClientPackages cp where clno not in (2135,3468,3668,12922,11870)  
     group by cp.clno  
     having count(distinct cp.PackageID)=1  
       )  
  
    -- Insert statements for procedure here  
 SELECT Apno, Apdate, CompDate, CLNO, UserID, Investigator, PackageID, 'NO Package Assigned' as 'Description'  
 INTO #tmpBilling  
 FROM Precheck.[dbo].Appl   
 WHERE Apstatus = 'F'   
 and Billed = 0   
 and PackageID IS NULL   
 and apdate > '01/01/2020'   
 and Clno not in (2135,3468,3668,12922,11870)  
  
  
    SELECT a.Apno, a.Apdate, a.CompDate, a.CLNO, a.UserID, a.Investigator, a.PackageID, 'Application does not have a required package' as 'Description'   
 INTO #tmpClientBilling  
 FROM Precheck.[dbo].Appl a  
 LEFT JOIN Precheck.[dbo].clientpackages cp on cp.clno = a.clno and a.packageid = cp.PackageID  
 WHERE a.Apstatus = 'F'   
 AND a.Billed =0   
 AND (a.PackageID not in (select PackageID from Precheck.[dbo].ClientPackages where ClNo = a.clno))  
 AND (a.PackageID  not in (select PackageID from Precheck.[dbo].ClientPackages  where ClNo in (select ParentCLNO from Precheck.[dbo].clienthierarchyByService where clno = a.clno and refHierarchyServiceID = 3)))   
 and a.PackageID is not null  
 and a.clno not in (2135, 3468, 3668,12922,11870)  
 and a.Apdate > '01/01/2020'  
  
 SELECT * FROM #tmpBilling   
 UNION ALL  
 SELECT * FROM #tmpClientBilling  
   
  
  
END  

--SELECT * 
--FROM [ALA-SQL-05].Precheck.[dbo].appl a  
-- INNER JOIN [ALA-SQL-05].Precheck.[dbo].ClientPackages cp on cp.clno = a.clno  
-- WHERE a.Apstatus = 'F'   
-- AND a.Billed =0   
-- AND a.PackageID IS NULL   
-- AND a.apdate > '01/01/2020'   
-- AND a.CLno in (select cp.clno from [ALA-SQL-05].Precheck.[dbo].ClientPackages cp where clno not in (2135,3468,3668,12922,11870)  
--     group by cp.clno  
--     having count(distinct cp.PackageID)=1  
--       )  