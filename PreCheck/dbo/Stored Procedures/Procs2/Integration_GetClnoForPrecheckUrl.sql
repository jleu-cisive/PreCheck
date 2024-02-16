

--[Integration_GetClnoForPrecheckUrl] 2699337
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 02/06/2015
-- Description:	Gets the CLNO for the PrecheckUrl being sent back
-- =============================================
CREATE PROCEDURE [dbo].[Integration_GetClnoForPrecheckUrl] 
	-- Add the parameters for the stored procedure here
	@apno int 
	
AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Select top 1 Case When IsOneHR = 1 then ParentEmployerID else A.CLNO End 
	From DBO.Appl A left join HEVN.dbo.Facility F on A.CLNO = Isnull(F.FacilityCLNO,0)
	where Apno = @apno


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT ON
	
END

