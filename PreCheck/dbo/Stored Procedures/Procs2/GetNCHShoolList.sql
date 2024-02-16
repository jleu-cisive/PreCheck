-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 03/08/2017
-- Description:	Get a list of NCH schools from the db
-- =============================================
CREATE PROCEDURE dbo.GetNCHShoolList 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select SchoolName,replace(SchoolCode,'_','') as SchoolCode from dbo.NCHListWPrice where ActivationDate is not null  order by SchoolName
END
