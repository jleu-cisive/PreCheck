

-- =============================================
-- Author:		Veena Ayyagari
-- Create date: 01/23/08
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[WindowsServiceSuccessLog] 
	@servicename varchar(50),
	@date datetime,
	@success bit

AS
BEGIN
	
SET NOCOUNT ON;
if(Select count(1) from [WinServiceSuccessLog] where servicename=@servicename and convert(varchar,rundate,101)=convert(varchar,@date,101))>0

    update [WinServiceSuccessLog] set success=@success where servicename=@servicename and convert(varchar,rundate,101)=convert(varchar,@date,101)
else
	insert into [WinServiceSuccessLog] (servicename,success) values(@servicename,@success)
SET NOCOUNT OFF;
END


