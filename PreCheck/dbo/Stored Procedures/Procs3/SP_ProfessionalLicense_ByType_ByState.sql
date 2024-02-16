

CREATE procedure [dbo].[SP_ProfessionalLicense_ByType_ByState]
(@LicenseType varchar(10)='',@State char(2)='',@EmployerID int = 0,@NumericLicenseNumberOnly bit = 0)
AS
BEGIN

Declare @ExpDate varchar(30)
declare @licitem varchar(50)

     

      set  @ExpDate = cast( (cast(month(getdate()) as varchar) + '/1/' + cast(year(getdate()) as varchar)) as Datetime)

Select 'Licensing' Section,l.ProfLicID as LicenseId,ap.CLNO as EmployerId, IsNull(e.Name,e.DescriptiveName)
EmployerName,Isnull(@LicenseType,'') Type,l.State as IssuingState,

IsNull(CONVERT(varchar(10),CAST(FLOOR(CAST(l.Expire as float)) AS datetime),101),'') as ExpiresDate,

IsNull(ap.Last,'') as Last, IsNull(ap.First,'') as first,
IsNull(CONVERT(varchar(10),CAST(FLOOR(CAST(ap.DOB as float)) AS datetime),101),'') as DOB,

IsNull((Case When @NumericLicenseNumberOnly = 0 then l.lic_no else (Case When isnumeric(l.lic_no) = 0 then
MainDB.dbo.fn_StripCharacters(l.lic_no, '^0-9') else l.lic_no end) end),'') number,

ap.SSN,

Replace(ap.SSN,'-','') SSN_NoDashes,right(ap.ssn,4) SSN_Last4,left(ap.SSN,3) SSN1, Case When charindex('-',ap.SSN)>0 then
substring(ap.SSN,5,2) else substring(ap.SSN,4,2) end SSN2,right(ap.SSN,4) SSN3
--,ap.apno

from dbo.ProfLic AS l INNER JOIN dbo.Appl ap on l.APNO = ap.APNO

inner join Client e on ap.CLNO = e.CLNO

where

 l.sectstat in ('9')
 and 
ap.apstatus not in ('F' ,'M')

and
ap.clno not in (2135,3668)
and
l.lic_type in (select LicTypeAlias from LicTypes_Alias where LicType = @LicenseType)
 and l.State = @State

--AND (Case when ISNULL(@licitem,'') = '' then '1' else l.lic_type end)= (Case when ISNULL(@licitem,'') = '' then '1' else
--@licitem end)

                                          AND (Case when ISNULL(@State,'') = '' then '1' else ap.State end)= (Case when
					  ISNULL(@State,'') = '' then '1' else @State end)

                                          AND (Case when @EmployerID = 0 then 1 else e.CLNO end)= (Case when @EmployerID = 0
					  then 1 else @EmployerID end)

                                          order by ap.SSN

END

