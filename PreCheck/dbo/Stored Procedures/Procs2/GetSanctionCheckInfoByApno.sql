-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 10/25/2013
-- Description:	Gets the hits, and the count for a sanction check run
-- =============================================
CREATE PROCEDURE dbo.GetSanctionCheckInfoByApno 
	-- Add the parameters for the stored procedure here
	@apno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if (@apno <> 0)
		
    -- Insert statements for procedure here
	SELECT     
      [first]
      ,[middle]
      ,[last]
      ,[createdby]
      ,[createddate]
      ,[hitcount]
      ,[searchtypes]
      ,[searchoptions]    
      ,[aliases]
      ,[hitlist]
  FROM [SanctionCheckLog] where apno = @apno
END
