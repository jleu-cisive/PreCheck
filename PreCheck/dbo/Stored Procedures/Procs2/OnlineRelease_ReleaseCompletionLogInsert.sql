-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.OnlineRelease_ReleaseCompletionLogInsert
	-- Add the parameters for the stored procedure here
	
	@logtime datetime,
	@clientapno varchar(50),
	@clno int,
	@browserinfo nvarchar(max),
	@ip varchar(200),
	@ssn varchar(11),
	@first varchar(50),
	@last varchar(50),
	@crimresponse nvarchar(max),
	@exception varchar(1000) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   insert into [ReleaseCompletionLog] (logtime, clno, browserinfo, ip, ssn, first, last, ClientAPNO, CrimResponse, ReleaseInsertException) 
   values (@logtime, @clno, @browserinfo, @ip, @ssn, @first, @last, @clientapno, @crimresponse, @exception)
END
