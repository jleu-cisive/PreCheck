

-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 04/22/2014
-- Description:	Get All Current Types from Log
-- [dbo].[dbo.AIMS_GetAllCurrentTypes]
-- =============================================
CREATE PROCEDURE [dbo].[dbo.AIMS_GetAllCurrentTypes] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select	distinct Section 
	from dbo.AIMS_Jobs j 
END



