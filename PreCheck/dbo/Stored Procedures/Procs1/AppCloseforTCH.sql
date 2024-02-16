-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AppCloseforTCH]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @CurrentDate datetime

set  @CurrentDate = getdate()
--print @CurrentDate

UPDATE Appl SET ApStatus = 'F',CompDate = @CurrentDate,OrigCompDate = @CurrentDate,IsAutoSent = 1,AutoSentDate = @CurrentDate WHERE APNO in (SELECT Apno FROM TCHAppno)

-- Run Appl Final logic on theses apps  
DECLARE @AppNo int
	
DECLARE c1 CURSOR READ_ONLY
FOR
SELECT Apno
FROM TCHAppno

OPEN c1

FETCH NEXT FROM c1
INTO @AppNo

WHILE @@FETCH_STATUS = 0
BEGIN

--	PRINT @AppNo
	exec RunApplFinalLogic @AppNo

	FETCH NEXT FROM c1
	INTO @AppNo

END

CLOSE c1
DEALLOCATE c1


Truncate table TCHAppno




END
