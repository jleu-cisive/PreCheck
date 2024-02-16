-- =============================================
-- Author:		Johnny Keller
-- Create date: 11/20/2019
-- Description:	This will pull all files that have not completed processing successfully.
--				This is being determined via the IsProcessSuccess flag in FtpFileProcess 
--				table that is located in the HEVN db. It will pull the file name from 
--				FtpFileQueue by joining on FtpFileProcess based on the FileQueueID, 
--				IsProcessSuccess flag value, and the date in which we are auditing
-- =============================================
CREATE PROCEDURE [dbo].[ViewFailedFiles]

	@dateToAudit varchar(10) = null
AS
BEGIN

	SET NOCOUNT ON;

	IF(@dateToAudit is null or @dateToAudit = '')
	BEGIN
		SELECT [ftpFileName] AS Errored_Files
			FROM [HEVN].[dbo].[FtpFileQueue]
			inner join [HEVN].[dbo].[ftpFileProcess] ON [ftpFileProcess].[FtpFileQueueID] = [FtpFileQueue].[FtpFileQueueID] 
									 and [FtpFileProcess].[IsProcessSuccess] = 0 
									 and datediff(day, [ftpfileprocess].[ProcessStartDateTime], getdate()) = 0 ORDER BY 1 DESC
	END
	ELSE 
	BEGIN
		IF(IsDate(try_convert(dateTime, @dateToAudit, 101)) = 1)
		BEGIN
			SELECT [ftpFileName] AS Errored_Files
				FROM [HEVN].[dbo].[FtpFileQueue]
				inner join [HEVN].[dbo].[ftpFileProcess] ON [ftpFileProcess].[FtpFileQueueID] = [FtpFileQueue].[FtpFileQueueID] 
										 and [FtpFileProcess].[IsProcessSuccess] = 0 
										 and datediff(day, [ftpfileprocess].[ProcessStartDateTime], convert(datetime, @dateToAudit, 101)) = 0 ORDER BY 1 DESC
		END
		ELSE
		BEGIN
			PRINT 'Parameter must be either empty or in valid xx/xx/xxxx date format'
		END
	END
END
