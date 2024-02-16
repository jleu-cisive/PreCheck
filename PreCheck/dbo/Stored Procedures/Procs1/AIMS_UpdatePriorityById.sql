-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified By Radhika Dereddy on 08/02/2021 to allow update through Qrpeorts.
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_UpdatePriorityById]
	-- Add the parameters for the stored procedure here
	@JobId int,
	@IsPriority bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [ALA-SQL-05].Precheck.[dbo].[AIMS_Jobs]
	set
	[IsPriority] = @IsPriority
	,[Last_Updated] = CURRENT_TIMESTAMP
	where
	[AIMS_JobID] in (@JobId)
	and AIMS_JobStatus = 'Q' 
	and VendorAccountId in (5,9,15,16) --Restrict to only Mozenda/SCP Vendors 	
	Select * from AIMS_Jobs where AIMS_JobID = @JobId	
END
