-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 02/27/2020
-- Description:	Get Disposition List
-- Execution: EXEC PopulateDispositionList
-- =============================================
CREATE PROCEDURE [dbo].[PopulateDispositionList]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT r.Disposition, r.[Description], r.refDispositionTypeID, r.IsActive
	FROM dbo.RefDisposition	r
	WHERE r.IsActive = 1
	ORDER BY r.Disposition
END
