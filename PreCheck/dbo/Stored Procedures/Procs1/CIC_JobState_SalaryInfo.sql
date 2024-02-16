-- =============================================
-- Author:		Radhika Dereddy	
-- Create date: 07/18/2017
-- Description:	CIC-JobState & SalaryInfo - removed inline query and created a stored procedure
-- EXEC CIC_JobState_SalaryInfo 3323990
-- =============================================
CREATE PROCEDURE CIC_JobState_SalaryInfo
	-- Add the parameters for the stored procedure here
	@APNO int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
		SELECT ordernumber APNO,jobstate,OD.JobTitle,OD.JobSalaryRange
		FROM Enterprise..[Order]  O 
		INNER JOIN Enterprise..OrderJobDetail OD ON O.OrderId = OD.OrderId 
		WHERE (O.OrderNumber = @APNO OR @APNO = 0)
END
