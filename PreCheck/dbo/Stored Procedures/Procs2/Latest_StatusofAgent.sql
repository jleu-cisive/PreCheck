-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- exec [dbo].[Latest_StatusofAgent] 'ga-phrm'
CREATE PROCEDURE [dbo].[Latest_StatusofAgent]
	 @sectionkeyid varchar(50) =null
	
	AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT aims_jobid,SectionKeyId,AIMS_JobStatus,CreatedDate,JobStart,JobEnd,VendorAccountId from AIMS_Jobs where SectionKeyId=@sectionkeyid order by 1  desc
END
