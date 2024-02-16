
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardLog_Select]
	-- Add the parameters for the stored procedure here
	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	SELECT * FROM dbo.StateBoardLog

	SET NOCOUNT OFF

--=================================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
