



create PROCEDURE [dbo].[UpdateInUseField]
@ApnoList xml
AS
SET ARITHABORT ON
update Appl set InUse = null where Inuse = 'CrimVnd' and apno in (

SELECT ParamValues.ID.value('.','VARCHAR(20)')
FROM @ApnoList.nodes('/Root/apno') as ParamValues(ID) )
SET ARITHABORT ON





