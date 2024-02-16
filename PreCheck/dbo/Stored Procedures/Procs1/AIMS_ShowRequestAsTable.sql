 --AIMS_ShowRequestAsTable 329148
CREATE procedure [dbo].[AIMS_ShowRequestAsTable]
(@logid int)
as
declare @xml xml
declare @section varchar(20)
set @xml = (select Request from dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
set @section = (select Section from  dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))


if(@section like 'CC%' or @section like 'SBM%') 
SELECT  
       Tbl.Col.value('Section[1]', 'varchar(20)') as Section,  
       Tbl.Col.value('Licenseid[1]','int') as Licenseid,  
       Tbl.Col.value('Employerid[1]','int') as Employerid,  
       Tbl.Col.value('EmployerName[1]', 'varchar(100)') as EmployerName,
       Tbl.Col.value('Type[1]', 'varchar(30)') as Type,
       Tbl.Col.value('IssuingState[1]', 'varchar(20)') as IssuingState,
	   case when IsNull(Tbl.Col.value('ExpiresDate[1]', 'varchar(20)'),'') = '' then Tbl.Col.value('Expiresdate[1]', 'varchar(20)') end as ExpiresDate ,
	   Tbl.Col.value('Last[1]', 'varchar(20)') as Last,
	   Tbl.Col.value('first[1]', 'varchar(20)') as First,
	   Tbl.Col.value('DOB[1]', 'varchar(max)') as DOB,
	   Tbl.Col.value('number[1]', 'varchar(20)') as LicenseNumber,
	   Tbl.Col.value('SSN[1]', 'varchar(11)') as SSN,
	   case when IsNull(Tbl.Col.value('SSN_NoDashes[1]', 'varchar(9)'),'') = '' then Tbl.Col.value('SSNNoDashes[1]', 'varchar(9)') else Tbl.Col.value('SSN_NoDashes[1]', 'varchar(9)') end  as SSN_NoDashes ,
	   case when IsNull(Tbl.Col.value('SSN_Last4[1]', 'varchar(4)'),'') = '' then Tbl.Col.value('SSNLast4[1]', 'varchar(4)') else Tbl.Col.value('SSN_Last4[1]', 'varchar(4)') end  as SSN_Last4 ,
	   Tbl.Col.value('SSN1[1]', 'varchar(5)') as SSN1,
	   Tbl.Col.value('SSN2[1]', 'varchar(5)') as SSN2,
	   Tbl.Col.value('SSN3[1]', 'varchar(5)') as SSN3
from @xml.nodes('//Item') Tbl(Col)

if(@section = 'Crim')

SELECT
	Tbl.Col.value('Section[1]', 'varchar(20)') as Section, 
	Tbl.Col.value('SectionID[1]','int') as SectionID,  
	Tbl.Col.value('Apno[1]','int') as Apno,
	Tbl.Col.value('County[1]', 'varchar(100)') as County,
	Tbl.Col.value('Cnty_No[1]', 'int') as Cnty_No,
	Tbl.Col.value('Ordered[1]', 'datetime') as Ordered,
	Tbl.Col.value('Last[1]', 'varchar(20)') as Last,
	Tbl.Col.value('First[1]', 'varchar(20)') as First,
	Tbl.Col.value('DOB[1]', 'date' ) as DOB,
	Tbl.Col.value('DOB_MM[1]', 'varchar(2)') as DOB_MM,
	Tbl.Col.value('DOB_DD[1]', 'varchar(2)') as DOB_DD,
	Tbl.Col.value('DOB_YYYY[1]', 'int') as DOB_YYYY,
	Tbl.Col.value('SSN[1]', 'varchar(11)') as SSN,
	Tbl.Col.value('SSN1[1]', 'varchar(5)') as SSN1,
	Tbl.Col.value('SSN2[1]', 'varchar(5)') as SSN2,
	Tbl.Col.value('SSN3[1]', 'varchar(5)') as SSN3,
	Tbl.Col.value('KnownHits[1]', 'varchar(max)') as KnownHits
	from @xml.nodes('//Item') Tbl(Col)
 

 