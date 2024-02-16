-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Student_Data_Sheets
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@StartDate datetime,
	@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
select First + ' ' + Middle + ' ' + Last as Name, First , Middle , Last, DOB, SSN, Addr_Street, City, State, ZIP  from appl where 
apno in (

SELECT APNO
FROM  ApplStudentAction
where  CLNO_Hospital = @CLNO and DateHospitalAssigned between @StartDate and @EndDate

)

END
