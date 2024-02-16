-- =============================================
-- Author:		Liel Alimole
-- Create date: 1/1/2014
-- Description:	deployed on 04/25/2014
-- =============================================
CREATE  PROCEDURE [dbo].[ClientAccess_InsertIntoReportLog] 
@clno int,
@logdate datetime,
@user varchar(50),
@reportid int,
@params varchar(200)

as
BEGIN

insert into DBO.clientaccessreportlog (clno, logdate, userid, ClientAccessReportID, params) values (@clno, @logdate, @user, @reportid, @params)

END




