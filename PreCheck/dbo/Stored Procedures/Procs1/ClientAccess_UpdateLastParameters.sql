

-- =============================================
create PROCEDURE [dbo].[ClientAccess_UpdateLastParameters]
@params varchar(200),
@mapid int
AS

SET NOCOUNT ON


update DBO.[ClientAccessReportMap] set [LastParameters] = @params where ClientAccessReportMapID = @mapid


SET ANSI_NULLS ON


SET NOCOUNT OFF



