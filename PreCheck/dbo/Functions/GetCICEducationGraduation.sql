CREATE FUNCTION [dbo].[GetCICEducationGraduation] 
(
	@EducatId INT
)
RETURNS bit
AS

BEGIN
	DECLARE @Result bit = NULL

	SELECT TOP 1 @Result = EE.IsGraduated	
		FROM Educat e
			JOIN Enterprise.DBO.Applicant EA
				ON e.Apno = EA.ApplicantNumber
			JOIN Enterprise.DBO.ApplicantEducation EE
				ON EA.ApplicantId = EE.ApplicantId
					AND E.School = EE.SchoolName
					AND E.Degree_A = EE.DegreeName
		WHERE E.EducatId = @EducatId
   RETURN @Result
END