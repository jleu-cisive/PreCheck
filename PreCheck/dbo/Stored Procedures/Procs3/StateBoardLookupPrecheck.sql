-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardLookupPrecheck]
	
AS
BEGIN
	
	SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Lice N and  License Type

Select l.Apno,C.Name as Employername,(l.First +' '+ l.Middle +' '+ l.Last)empname,(s.name + ' '+ s.middle + ' ' + s.last )as NameFromBoard,DOB,'xxx-xx-' + right(ssn,4) SSN,lic_No,Lic_Type,ApDate --,facilityname,departmentname,jobtitle,jobcode 

from Appl l 
--on (l.last = s.last and l.first = s.name and left(isnull(l.middle,''),1) = left(isnull(s.middle,''),1)) or (l.first = s.last and l.last = s.name and left(isnull(l.middle,''),1) = left(isnull(s.middle,''),1)) 

inner Join ProfLic P on l.APNO = P.Apno
Inner Join Client C on l.CLNO = C.CLNO

inner join RABBIT.HEVN.dbo.sheet1 s

on ltrim(rtrim(LicenseNo)) = P.lic_No 
--And
--(ltrim(rtrim(Replace([License Type],'#',''))) = (Case P.Lic_Type When  'REGISTERED NURSE' then 'RN' 
--													when  'LIC VOCATIONAL NURSE' then 'LVN' 
--													When  'RN' then 'RN' 
--													when  'LVN' then 'LVN'						
--													end))
--where ApDate > '1/1/2007' 
order by l.Apno Desc



--last,first (swapped) with middle initial

Select l.Apno,C.Name as Employername,(l.First +' '+ l.Middle +' '+ l.Last)empname,(s.name + ' '+ s.middle + ' ' + s.last )as NameFromBoard,DOB,'xxx-xx-' + right(ssn,4) SSN,lic_No,Lic_Type,ApDate --,facilityname,departmentname,jobtitle,jobcode 

from Appl l inner join RABBIT.HEVN.dbo.sheet1 s

on (l.last = s.last and l.first = s.name and left(isnull(l.middle,''),1) = left(isnull(s.middle,''),1)) or (l.first = s.last and l.last = s.name and left(isnull(l.middle,''),1) = left(isnull(s.middle,''),1))
inner Join ProfLic P on l.APNO = P.Apno
Inner Join Client C on l.CLNO = C.CLNO
 --where ApDate > '1/1/2007'
order by l.Apno Desc
--last,first (swapped) with out  middle initial

Select l.Apno,C.Name as Employername,(l.First +' '+ l.Middle +' '+ l.Last)empname,(s.name + ' '+ s.middle + ' ' + s.last )as NameFromBoard,DOB,'xxx-xx-' + right(ssn,4) SSN,lic_No,Lic_Type,ApDate --,facilityname,departmentname,jobtitle,jobcode 

from Appl l inner join RABBIT.HEVN.dbo.sheet1 s


on (l.last = s.last and l.first = s.name ) or (l.first = s.last and l.last = s.name )
inner Join ProfLic P on L.APNO = P.Apno
Inner Join Client C on l.CLNO = C.CLNO

 --where ApDate > '1/1/2007'
order by l.Apno Desc

 SET TRANSACTION ISOLATION LEVEL READ COMMITTED   
END
