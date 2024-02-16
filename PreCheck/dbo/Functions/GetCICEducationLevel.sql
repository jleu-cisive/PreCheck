/*
	SELECT [dbo].[GetCICEducationLevel] (3833556,1)
	SELECT [dbo].[GetCICEducationLevel] (3833557,1)
*/
CREATE FUNCTION [dbo].[GetCICEducationLevel] 
(
	@EducatId INT,
	@IsPreCheckType BIT
)
RETURNS VARCHAR(50)
AS

BEGIN
DECLARE @Result VARCHAR(50) = NULL

	IF @IsPreCheckType = 0
	BEGIN
       		SELECT TOP 1 @Result = 
						CASE 
			 WHEN DA.DynamicAttributeId = 24 THEN 'H'
			 WHEN DA.DynamicAttributeId = 25 THEN 'C'
             WHEN DA.DynamicAttributeId = 26 THEN 'G'
             WHEN DA.DynamicAttributeId = 27 THEN 'G'
			 WHEN DA.DynamicAttributeId = 120 THEN 'H'
			 WHEN DA.DynamicAttributeId = 121 THEN '2'
			 WHEN DA.DynamicAttributeId = 122 THEN 'T'
			 WHEN DA.DynamicAttributeId = 123 THEN 'O'
             ELSE ''
			 END
			  FROM Educat E
			  JOIN Appl A
			    ON E.Apno = A.Apno
              JOIN Enterprise.DBO.Applicant EA
			    ON A.Apno = EA.ApplicantNumber
			  JOIN Enterprise.DBO.ApplicantEducation EE
			    ON EA.ApplicantId = EE.ApplicantId
				and substring(ee.SchoolName, 0, 101) = e.School and substring(ee.DegreeName,0,26) = e.Degree_A
			   --AND E.School = EE.SchoolName
			   --AND E.Degree_A = EE.DegreeName
              JOIN Enterprise.DBO.DynamicAttribute DA
			    ON EE.DAEducationLevelId = DA.DynamicAttributeId
             WHERE E.EducatId = @EducatId
    		   AND DA.DynamicAttributeTypeId = 3
			   --AND A.EnteredVia = 'CIC'
	END
	ELSE
	BEGIN
	SELECT TOP 1 @Result = DA.ShortName
			
			  FROM Educat E
			  JOIN Appl A
			    ON E.Apno = A.Apno
              JOIN Enterprise.DBO.Applicant EA
			    ON A.Apno = EA.ApplicantNumber
			  JOIN Enterprise.DBO.ApplicantEducation EE
			    ON EA.ApplicantId = EE.ApplicantId
				and substring(ee.SchoolName, 0, 101) = e.School and substring(ee.DegreeName,0,26) = e.Degree_A
			   --AND E.School = EE.SchoolName
			   --AND E.Degree_A = EE.DegreeName
              JOIN Enterprise.DBO.DynamicAttribute DA
			    ON EE.DAEducationLevelId = DA.DynamicAttributeId
             WHERE E.EducatId = @EducatId
    		   AND DA.DynamicAttributeTypeId = 3
			   --AND A.EnteredVia = 'CIC'
	END

   RETURN @Result

END
