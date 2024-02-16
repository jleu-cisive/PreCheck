

--[AIMS_ShowResponseAsTable_1] 495313
CREATE procedure [dbo].[AIMS_ShowResponseAsTable_1]
(@logid int)
as
declare @xml xml
declare @section varchar(20)



set @xml = (select Response from dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
set @section = (select Section from  dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))

IF(@xml IS NULL)
	BEGIN
		set @xml = (select Response from [Precheck_Archive].dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
	END

IF(@section IS NULL OR @section='')
	BEGIN
		set @section = (select Section from  [Precheck_Archive].dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
	END

IF(@xml IS NULL)
	BEGIN
		set @xml = (select Response from [Precheck_Archive].dbo.DataXtract_Logging_2016 (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
	END

IF(@section IS NULL OR @section='')
	BEGIN
		set @section = (select Section from  [Precheck_Archive].dbo.DataXtract_Logging_2016 (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
	END

if(@section like 'CC%' or @section like 'SBM%')
SELECT  
       Tbl.Col.value('Name[1]', 'varchar(20)') as Name,  
       Tbl.Col.value('First[1]','varchar(20)') as First,  
       Tbl.Col.value('Last[1]','varchar(20)') as Last,  
       Tbl.Col.value('LicenseType[1]', 'varchar(100)') as LicenseType,
       Tbl.Col.value('LicenseNumber[1]', 'varchar(30)') as LicenseNumber,
       Tbl.Col.value('IssueDate[1]', 'varchar(20)') as IssueDate,
	   Tbl.Col.value('LicenseStatus[1]', 'varchar(20)') as LicenseStatus ,
	   Tbl.Col.value('ExpirationDate[1]', 'varchar(20)') as ExpirationDate,
	   Tbl.Col.value('MultiStateStatus[1]', 'varchar(20)') as MultiStateStatus,
	   Tbl.Col.value('DisciplinaryAction[1]', 'varchar(max)') as DisciplinaryAction,
	   Tbl.Col.value('NotFound[1]', 'varchar(20)') as NotFound,
	   Tbl.Col.value('Licenseid[1]', 'int') as Licenseid,
	   Tbl.Col.value('ProvidedFirst[1]', 'varchar(50)') as ProvidedFirst ,
	   Tbl.Col.value('ProvidedLast[1]', 'varchar(50)') as ProvidedLast,
	   Tbl.Col.value('ProvidedExpirationDate[1]', 'varchar(50)') as ProvidedExpirationDate,
	   Tbl.Col.value('ProvidedLicenseNumber[1]', 'varchar(50)') as ProvidedLicenseNumber,
	   Tbl.Col.value('ResultStatus[1]', 'varchar(50)') as ResultStatus
from @xml.nodes('//Item') Tbl(Col)

if(@section = 'Crim')
select
   Tbl.Col.value('Section[1]', 'varchar(20)') as Section,
   Tbl.Col.value('SectionID[1]', 'int') as SectionID,
   Tbl.Col.value('Apno[1]', 'int') as Apno,
   Tbl.Col.value('First[1]', 'varchar(30)') as First,
   Tbl.Col.value('Last[1]', 'varchar(30)') as Last,
   Tbl.Col.value('NoRecord[1]', 'varchar(20)') as NoRecord,
   Tbl.Col.value('NameOnRecord[1]', 'varchar(50)') as NameOnRecord,
   Tbl.Col.value('CaseNo[1]', 'varchar(30)') as CaseNo,
   Tbl.Col.value('Degree[1]', 'varchar(30)') as Degree,
   Tbl.Col.value('DateFiled[1]', 'varchar(30)') as DateFiled
from @xml.nodes('//Item') Tbl(Col)

 
