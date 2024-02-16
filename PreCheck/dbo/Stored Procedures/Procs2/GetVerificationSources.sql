-- =============================================
-- Author:		Bernie Chan
-- Create date: 10/17/2014
-- Description:	Create a data source for Verification Source drop down list
-- Example [dbo].[GetVerificationSources]  'Empl'
-- =============================================
create PROCEDURE [dbo].[GetVerificationSources] 
	-- Add the parameters for the stored procedure here
	@source varchar(20)
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT '0~0~0' AS Value, 'Choose Section' AS [Description]
	UNION ALL
	SELECT [refVerificationSource] + '~' + cast([minlength] as varchar)  + '~' + cast([maxlength] as varchar) Value, [Description]    
	FROM [dbo].[refVerificationSources]
	WHERE Section in ('All',@source) and isactive=1

END