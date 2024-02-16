-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ModifiedDate: 1/15/2018 By Amy Liu: Add all other available fields for criminal query
--[AIMS_ShowResponseAsTable] 725482 
-- =============================================


CREATE procedure [dbo].[AIMS_ShowResponseAsTable]
(@logid int)
as
declare @xml xml
declare @section varchar(20)



set @xml = (select Response from dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))
set @section = (select Section from  dbo.DataXtract_Logging (nolock) where DataXtract_LoggingId = IsNull(@logId,0))

if(@section like 'CC%' or @section like 'SBM%' or @section like 'Nursys%' or @section like 'BGNursys%' or @section like 'BGLicense%')
SELECT  
       Tbl.Col.value('Name[1]', 'varchar(50)') as Name,  
       Tbl.Col.value('First[1]','varchar(40)') as First,  
       Tbl.Col.value('Last[1]','varchar(40)') as Last,  
       Tbl.Col.value('LicenseType[1]', 'varchar(100)') as LicenseType,
       Tbl.Col.value('LicenseNumber[1]', 'varchar(30)') as LicenseNumber,
       Tbl.Col.value('IssueDate[1]', 'varchar(40)') as IssueDate,
          Tbl.Col.value('LicenseStatus[1]', 'varchar(50)') as LicenseStatus ,
          Tbl.Col.value('ExpirationDate[1]', 'varchar(40)') as ExpirationDate,
          Tbl.Col.value('MultiStateStatus[1]', 'varchar(40)') as MultiStateStatus,
          Tbl.Col.value('DisciplinaryAction[1]', 'varchar(max)') as DisciplinaryAction,
          Tbl.Col.value('NotFound[1]', 'varchar(40)') as NotFound,
          Tbl.Col.value('Licenseid[1]', 'int') as Licenseid,
          Tbl.Col.value('ProvidedFirst[1]', 'varchar(50)') as ProvidedFirst ,
          Tbl.Col.value('ProvidedLast[1]', 'varchar(50)') as ProvidedLast,
          Tbl.Col.value('ProvidedExpirationDate[1]', 'varchar(50)') as ProvidedExpirationDate,
          Tbl.Col.value('ProvidedLicenseNumber[1]', 'varchar(50)') as ProvidedLicenseNumber,
          Tbl.Col.value('ResultStatus[1]', 'varchar(50)') as ResultStatus
from @xml.nodes('//Item') Tbl(Col)

if(@section = 'Crim')
select
   Tbl.Col.value('Section[1]', 'varchar(40)') as Section,
   Tbl.Col.value('SectionID[1]', 'int') as SectionID,
   Tbl.Col.value('Apno[1]', 'int') as Apno,
   Tbl.Col.value('First[1]', 'varchar(40)') as First,
   Tbl.Col.value('Last[1]', 'varchar(40)') as Last,
   Tbl.Col.value('NoRecord[1]', 'varchar(40)') as NoRecord,
   Tbl.Col.value('Offense[1]', 'varchar(1000)') as Offense,
   Tbl.Col.value('NameOnRecord[1]', 'varchar(300)') as NameOnRecord,
   Tbl.Col.value('CaseNo[1]', 'varchar(50)') as CaseNo,
   Tbl.Col.value('Degree[1]', 'varchar(40)') as Degree,
   Tbl.Col.value('DateFiled[1]', 'varchar(40)') as DateFiled,
   Tbl.Col.value('DOB[1]', 'varchar(40)') as DOB,
   Tbl.Col.value('Disposition[1]', 'varchar(500)') as Disposition,
   Tbl.Col.value('DispositionDate[1]', 'varchar(20)') as DispositionDate,
   Tbl.Col.value('NotesCaseInformation[1]', 'varchar(max)') as NotesCaseInformation,
   Tbl.Col.value('WarrantStatus[1]', 'varchar(100)') as WarrantStatus,
   Tbl.Col.value('Sentence[1]', 'varchar(1000)') as Sentence,
   Tbl.Col.value('Fine[1]', 'varchar(50)') as Fine,
   Tbl.Col.value('DateReleased[1]', 'varchar(20)') as DateReleased,
   Tbl.Col.value('AdditionalInformation[1]', 'varchar(1000)') as AdditionalInformation
from @xml.nodes('//Item') Tbl(Col)
