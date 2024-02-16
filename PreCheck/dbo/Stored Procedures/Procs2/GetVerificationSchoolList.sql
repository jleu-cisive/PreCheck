-- =============================================
-- Author:		Dongmei He
-- Create date: 05/05/2015
-- Description:	Create a data source for Verification Type drop down list
-- Example [dbo].[GetVerificationType]  'Education'
-- =============================================
CREATE PROCEDURE [dbo].[GetVerificationSchoolList] --'Purdue University'
	-- Add the parameters for the stored procedure here
	@school varchar(100)
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT schoolname, schoolcode FROM [dbo].[NCHListwPrice]
	where schoolname like '%' + @school + '%'
	and ActivationDate is not null
--	WHERE (SELECT top 1 count(*)
--FROM dbo.fnSplit(schoolname,' ') sentence1
--INNER JOIN dbo.fnSplit('school',' ') sentence2 ON sentence1.data = sentence2.data
--group by sentence1.data, sentence2.data having count(*)>0)>0

END



