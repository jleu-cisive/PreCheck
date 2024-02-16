-- =============================================
-- Author:		Prasanna
-- Create date: 09/10/2018
-- Description:	New Hire Licenses by DatRange Report 
-- Requested By: Marc Salinas
-- Request Description: Report to pull new hire licenses received by date ranges
-- Execution: [dbo].[NewHireLicenses_byDateRange] 2569, '08/25/2018', '09/02/2018'
-- =================================================

CREATE PROCEDURE [dbo].NewHireLicenses_byDateRange
(
	@EmployerID varchar(50),
	@StartDate datetime,
	@EndDate datetime
)
AS
	SET NOCOUNT OFF;

BEGIN

   	Select er.EmployerID,er.First,er.Last, l.RecordDate,l.IssuingState as [License State],l.Type as [License Type] from EmployeeRecord er
	inner join License l on er.SSN = l.SSN and er.EmployerID = l.Employer_ID 
	where er.EmployerID=@EmployerID and InitialRecord=1 and l.RecordDate >= @StartDate AND l.RecordDate <= DateAdd(day, 1,@EndDate)
	and l.duplicatelicense=0 and l.DoNotCredential=0 AND (l.EndDate is Null) and CredentialingStatus Not in (6,8,10)	
	order by l.RecordDate desc

END
