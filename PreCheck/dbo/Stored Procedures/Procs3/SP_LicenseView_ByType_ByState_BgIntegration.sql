
-- =============================================
-- Author:		Sahithi
-- Create date:10/15/2021
-- Description:	Used to Pull the BgLicenses based on Type and State
/************************************************************************************************************************
Modified By: Jenitta Frederik
Modified Date:08/17/2023
Description: For HDT 101507 BG Automations Prof License, we just modified few condition to verify lic_no to check n/a 
************************************************************************************************************************/
--exec dbo.[SP_LicenseView_ByType_ByState_BgIntegration]'tn','rn'
--    
--declare @licensetype varchar(20)

--set @licensetype='RN'
 
--@LicenseType as FileType,
-- 'Licensing' as [Section],
--	a.APNO ,
--pl.ProfLicID as [Licenseid],
--	a.CLNO as [Employerid],
--REPLACE(c.name,',','') as [EmployerName],
--'' as [FacilityName],
--'' as [Client License Type],
--REPLACE(a.Last,',','') as [Last],
--REPLACE(a.First,',','') as [first],
----'' as [EmployeeNumber],

--a.SSN as [SSN], --full SSN
--REPLACE(a.SSN,'-','') as [SSNNoDashes], -- SSN with no Dashes

--LEFT(a.SSN,3) as [SSN1], --First 3# of SSN
--(CASE
--	WHEN CHARINDEX('-',a.SSN) > 0
--	THEN SUBSTRING(a.SSN,5,2)
--	ELSE SUBSTRING(a.SSN,4,2)
--END) as [SSN2], --Middle 2# of SSN
--RIGHT(a.SSN,4) [SSN3] -- Last 4# of SSN
-- =============================================
CREATE PROCEDURE [dbo].[SP_LicenseView_ByType_ByState_BgIntegration]
	-- Add the parameters for the stored procedure here
--declare
@State char(2)='',
@LicenseType varchar(10)='',
@EmployerID int = 0,
@NumericLicenseNumberOnly bit = 0,
@ShowLicenseStatus bit = 0,
@ForIntegration bit = 1,
@IncludeLicenseSubTypes bit = 0
--@SectionType NVARCHAR(100)=null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
--Create Table #tmpLicenseview

--	(Licenseid INT,APNO int,[type] varchar(50),issuingstate char(2),Expiresdate date,[last] varchar(100),[first] varchar(100),BirthYear int,Number varchar(50),
--	ssn varchar(11),SSN_NoDashes varchar(9),SSN_Last4 varchar(4),SSN1 varchar(3),SSN2 varchar(2),SSN3 varchar(4),

--	Address1 varchar(50),Address2 varchar(50),City varchar(50),[State] char(2) ,Zip varchar(10), 

--	FacilityCLNO INT,FacilityState char(2),FacilityZip varchar(10),

--	Hiredate Date,LicenseTypeID Int)

SELECT distinct
       pl.ProfLicID as [Licenseid]
	   --,a.Apno
       ,pl.Lic_type as [Type]
       ,pl.[State] as [IssuingState]
       ,'' as [ExpiresDate]	  	   
       ,REPLACE(pl.Lic_No,',','') as [number]
	    ,RIGHT(a.SSN,4) as [SSNLast4] --Last 4# SSN
	   ,YEAR(a.DOB) as [BirthYear]	  
       ,a.Addr_Street as [Address1] 
       ,a.Addr_Num  as [Address2]
       ,a.City 
       ,a.State
       ,a.Zip
       ,DATEADD(day,15,getdate()) as Hiredate
	   ,a.CLNO as FacilityCLNO    
       ,null as FacilityState
	   ,null as FacilityZip
       ,LicType.LicenseTypeID
FROM 
	dbo.Appl a (NOLOCK)
INNER JOIN 
	dbo.Client C (NOLOCK) 
ON 
	a.clno = c.clno
INNER JOIN 
	dbo.Proflic pl (NOLOCK) 
ON 
	a.APNO = pl.Apno
LEFT join 
	hevn.dbo.vwLicenseTypeAlias LicType 
on 
	(pl.Lic_Type =LicType.Alias OR Pl.Lic_Type  = LicType.TypeDesc)
WHERE  
	pl.Ishidden = 0 AND 
	pl.IsOnreport = 1 AND 
	pl.SectStat = '9' AND
	--AND a.Apdate >= @LastSuccessfulRun
	a.Apdate >= '01/01/2021' AND
	--(pl.Lic_No IS NOT NULL OR LTRIM(RTRIM(pl.Lic_No)) <> '' OR pl.Lic_No NOT IN ('n/a')) AND -- commented  and added new condition by Jenitta Frederik
	((pl.Lic_No IS NOT NULL) and (LTRIM(RTRIM(pl.Lic_No)) <> '') and (pl.Lic_No NOT IN ('n/a'))) AND 
	ISNULL(pl.[State],'')=@State AND  
	ISNULL(LicType.[Type], pl.Lic_Type)=@LicenseType
	 AND
		--AND CONCAT(ISNULL(pl.[State],''),'-', ISNULL(LicType.[Type], pl.Lic_Type)) = @LicenseType
	pl.Is_Investigator_Qualified = 0
	and a.CLNO <> 2167 --temporary.. testing at request of Brian Silver 08/08/2023
END
