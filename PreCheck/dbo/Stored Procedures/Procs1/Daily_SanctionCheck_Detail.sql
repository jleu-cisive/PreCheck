-- =============================================
-- Author:		Prasanna
-- Create date: 11/8/2016
-- Description:	pull the information about the daily SanctionChecks we run in Controller each day
-- Exec [dbo].[Daily_SanctionCheck_Detail] '',''
-- =============================================
CREATE PROCEDURE  [dbo].[Daily_SanctionCheck_Detail] 
	@UserID varchar(20) = null,
	@CreatedDate datetime = null
AS
BEGIN
	select distinct mILog.APNO, client.Name,mILog.[Status],mILog.Username,sLog.hitcount,sLog.createddate as CreatedDate from medIntegLog mILog
    inner join Appl appl on appl.APNO = mILog.APNO
    inner join Client client on client.CLNO = appl.CLNO
	inner join SanctionCheckLog sLog on sLog.APNO = mILog.APNO
    where (mILog.Username = @UserID or @UserID = '') and (convert(date,mILog.ChangeDate) = @CreatedDate or @CreatedDate = '') and sLog.hitcount >0
	order by sLog.createddate desc
END
