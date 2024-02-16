CREATE  procedure [dbo].[Integration_Verification_GetMVRDemoGraphic]
(
	@apnos varchar(max)
)
as
select apno,IsNull(First,'') as FirstName,IsNull(Last,'') as LastName,IsNull(Middle,'') as MiddleName,IsNull(DOB,'') as DOB,IsNull(DL_State,'') as DL_STATE,IsNull(DL_Number,'') as DN_NUMBER
from dbo.Appl where APNO in (select value from dbo.fn_Split(@apnos,','))
