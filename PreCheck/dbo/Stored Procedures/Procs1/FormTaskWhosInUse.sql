CREATE PROCEDURE [dbo].[FormTaskWhosInUse] AS

	SET NOCOUNT OFF;
SELECT Top 1 InUse FROM Task WHERE InUse is not null