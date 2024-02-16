-- =============================================
-- Author:		Dongmei He
-- Create date: 05/05/2015
-- Description:	Create a data source for Verification Type drop down list
-- Example [dbo].[GetVerificationType]  'Education'
-- =============================================
create PROCEDURE [dbo].[GetVerificationType] 
	-- Add the parameters for the stored procedure here
	@source varchar(20)
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT '0~0~0' AS Value, 'Choose Section' AS [Description]
	UNION ALL
	SELECT [refVerificationType] + '~' + cast([minlength] as varchar)  + '~' + cast([maxlength] as varchar) Value, [Description]    
	FROM [dbo].[refVerificationType]
	WHERE Section in ('All',@source) and isactive=1

END