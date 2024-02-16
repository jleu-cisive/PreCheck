


--Modify: to add IsNeverCredentiable and handle IsCredentiable based on IsNeverCredentiable 11-30-05
--Modify: to add l.LicenseTypeID!=1 which is for EXCLUDE - CLIENT NON-CREDENTIABLE 11-01-05
--Modify: Per Steve, to use Description as Description instead of Item 11-15-05

CREATE PROCEDURE dbo.WebCredentCheckClientLicneseTypeMapping_Sel

@EmployerID int

AS

select L.LicenseTypeID,
	cast(L.LicenseTypeID as varchar) CombID ,
	cl.ClientLicenseTypeID,
	ItemValue LicenseType,
	--Item Description,
	isnull(l.Description,'') Description,
	isnull(cl.IsCredentiable,l.IsCredentiable) IsCredentiable,
	isnull(cl.IsActive,l.IsActive) IsActive,
	l.IsNeverCredentiable,
	cl.lmsLicenseTypeID,
	cl.lmsLicenseSubSpecialtyTypeID,
	cl.LicenseType ClientLicenseType,
	cl.AdditionalLicenseIndex,
isnull(cl.isPrimaryMapping, 0) IsPrimayMapping,--hz added on 5/8/06
	1 Flag, -- for LicenseType
	0 IsEdit -- for edited rows, hz added on4/26/06
  from LicenseType l, ClientLicenseType cl
 where l.LicenseTypeID*=cl.lmsLicenseTypeID
   and l.LicenseTypeID!=1 and l.LicenseTypeID !=2 and  l.LicenseTypeID is not null  --(Dongmei added l.LicenseTypeID !=2)
   and l.IsActive=1
   and cl.EmployerID=@EmployerID

union 

select  ls.LicenseSubspecialtyTypeID, 
	cast(ls.LicenseTypeID as varchar) + '-' + cast(ls.LicenseSubspecialtyTypeID as varchar) CombID,
	cl.ClientLicenseTypeID,
	ls.Abbreviation LicenseType,
	FullName Description,
	isnull(cl.IsCredentiable,l.IsCredentiable) IsCredentiable,  
	isnull(cl.IsActive,l.IsActive) IsActive, 
	l.IsNeverCredentiable,
	cl.lmsLicenseTypeID,
	cl.lmsLicenseSubSpecialtyTypeID,
	cl.LicenseType ClientLicenseType,
	cl.AdditionalLicenseIndex,
isnull(cl.isPrimaryMapping, 0) IsPrimayMapping,--hz added on 5/8/06
	0 Flag, -- for LicenseSubSpecialtyType
	0 IsEdit -- for edited rows, hz added on4/26/06
  from LicenseSubspecialtyType ls, ClientLicenseType cl,LicenseType l
 where ls.LicenseSubspecialtyTypeID*=cl.lmsLicenseSubspecialtyTypeID
   and ls.LicenseTypeID=l.LicenseTypeID
   and l.LicenseTypeID!=1 and l.LicenseTypeID !=2 and l.LicenseTypeID is not null  --(Dongmei added l.LicenseTypeID !=2)
   and l.IsActive=1
   and ls.IsActive=1
   and cl.EmployerID=@EmployerID
order by LicenseType
