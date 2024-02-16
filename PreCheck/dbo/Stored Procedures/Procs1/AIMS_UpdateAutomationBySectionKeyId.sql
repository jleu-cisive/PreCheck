-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_UpdateAutomationBySectionKeyId]
	-- Add the parameters for the stored procedure here
	@SectionKeyId varchar(100),
	@IsAutomationEnabled bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Update [dbo].[DataXtract_RequestMapping]
	Set
		IsAutomationEnabled = @IsAutomationEnabled
	where SectionKeyId = @SectionKeyId
	select * from DataXtract_RequestMapping where SectionKeyId = @SectionKeyId
END
