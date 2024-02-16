-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.Job_RemoveDuplicate_VendorOrder_Log
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    WITH cte
	AS (
		select i.*,
		ROW_NUMBER() OVER(PARTITION BY i.OrderId,i.StatusReceived
				   ORDER BY CreatedDate desc) AS DuplicateCount
		from dbo.Integration_VendorOrder_Log i
		where (i.ProcessedDate is null)
		and i.StatusReceived = 'InProgress'
		AND i.IsProcessed = 0
	)

	UPDATE i SET i.IsProcessed = 1
	from cte c
	inner join dbo.Integration_VendorOrder_Log i WITH (nolock) on c.Integration_VendorOrder_LogId = i.Integration_VendorOrder_LogId
	where 1 = 1
	and c.DuplicateCount > 1
	and i.IsProcessed = 0


END
