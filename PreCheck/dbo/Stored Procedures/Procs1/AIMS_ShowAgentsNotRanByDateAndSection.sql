-- Alter Procedure AIMS_ShowAgentsNotRanByDateAndSection
-- =============================================
-- Author:		Johnny Keller
-- Create date: 9/25/2019
-- Description:	Will show which agents had not run on the given date,
--				parameters will be date (09/25/2019) and section (CC)
-- =============================================

CREATE PROCEDURE [dbo].[AIMS_ShowAgentsNotRanByDateAndSection] 
	-- Add the parameters for the stored procedure here
	@date varchar(10),
    @section varchar(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(@date is not null)
	BEGIN
		IF(@section = 'CC' or @section = 'SBM')
		BEGIN
			select distinct SectionKeyId 
			from aims_jobs 
			where AIMS_JobStatus not in ('C', 'Z') and datediff(day, JobEnd, @date) = 0 and Section = @section
		END
		IF(@section = 'crim')
		BEGIN
			select TblCounties.County, TblCounties.CNTY_NO as SectionKeyID
			from dbo.TblCounties 
			join (select distinct aims_jobs.SectionKeyId 
				  from aims_jobs 
				  where AIMS_JobStatus not in ('C', 'Z') and datediff(day, aims_jobs.JobEnd, @date) = 0 and aims_jobs.section = 'crim') AS secKey 
				  ON secKey.SectionKeyId = TblCounties.cnty_no
		END
	END
END
