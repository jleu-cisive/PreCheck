
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardFinalData_Select]
	-- Add the parameters for the stored procedure here
(
	@StateBoardDisciplinaryRunID int
)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    -- Insert statements for procedure here
	SELECT * FROM dbo.StateBoardFinalData 
	WHERE StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
--============================================================


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
