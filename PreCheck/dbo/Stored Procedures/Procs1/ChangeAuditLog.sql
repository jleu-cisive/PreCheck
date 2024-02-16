CREATE PROCEDURE DBO.ChangeAuditLog ( @APNO int)
AS
BEGIN

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select * from changelog (nolock) where id=@APNO order by 1 desc

--select * from [dbo].[IRIS_ResultLog] (nolock) where apno =@APNO

select 'IRIS_Result',* from changelog (nolock) where id in (select crimid from [dbo].[IRIS_ResultLog] where apno =@APNO)

--select * from  [dbo].[Crim_Web_History] where apno =@APNO

select 'IRIS_crim',* from changelog (nolock) where id in (select crimid from [dbo].Crim_Web_History where apno =@APNO)

--select * from  	[dbo].[CriminalVendor_Log] where apno =@APNO

--select 'crim_vendor',* from changelog (nolock) where id in (select crimid from [dbo].CriminalVendor_Log where apno =@APNO)

select * from  	Web_status_history where history_appno =@APNO

select 'Empl',* from changelog (nolock) where id in (select emplid from [dbo].Web_status_history where history_appno =@APNO)

--select * from  	[dbo].[Web_Edu_History] where history_appno =@APNO

select 'Educat',* from changelog (nolock) where id in (select Educatid from [dbo].Web_Edu_History where History_apno =@APNO)

--select * from  	[Web_lic_History] where history_appno =@APNO

select 'License',* from changelog (nolock) where id in (select proflicid from [dbo].Web_lic_History where History_apno =@APNO)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SET NOCOUNT OFF

END

