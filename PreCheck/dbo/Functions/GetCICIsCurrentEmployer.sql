/*
SELECT [dbo].[GetCICIsCurrentEmployer](6726561)
*/
CREATE FUNCTION [dbo].[GetCICIsCurrentEmployer]
	(@emplId int)
RETURNS bit
AS
BEGIN
	DECLARE @result bit = NULL
	select @result = ae.IsPresentEmployer 
	from empl e
	inner join Enterprise.dbo.applicant a on e.apno = a.applicantNumber
	inner join Enterprise.dbo.ApplicantEmployment ae on ae.ApplicantId = a.ApplicantId 
					AND SUBSTRING(ae.EmployerName,1,30) = SUBSTRING(e.Employer,1,30) 
					AND (SUBSTRING(ae.StartDesignation,1,50) = SUBSTRING(e.Position_A,1,50) )
	where e.EmplID = @emplId

	RETURN @result
END