/*Example: SELECT [dbo].[GetCICEducationGraduationDate](3600648)*/
CREATE FUNCTION [dbo].[GetCICEducationGraduationDate]
	(@educatId int)
RETURNS varchar(30)
AS
BEGIN
    declare @graduationDate varchar(30);
    select @graduationDate = coalesce(convert(varchar,ae.GraduationYear), convert(varchar,ae.attendedTo,25)) from Educat as e
    inner join Enterprise.dbo.Applicant a on a.ApplicantNumber = e.APNO
    inner join Enterprise.dbo.ApplicantEducation ae on a.ApplicantId = ae.ApplicantId and substring(ae.SchoolName, 0, 101) = e.School and substring(ae.DegreeName,0,26) = e.Degree_A
    where e.EducatID = @educatId

    return @graduationDate
END
