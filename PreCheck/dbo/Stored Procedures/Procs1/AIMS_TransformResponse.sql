
create procedure dbo.AIMS_TransformResponse
(@logid int)
as
declare @xml xml


set @xml = (select Response from dbo.DataXtract_Logging where DataXtract_LoggingId = IsNull(@logId,0))

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

 
