/*************************************************************
-- Author:		Gaurav Bangia
-- Create date: 03/24/2022
-- Description:	Table function to return list of Student APNOs 
 with summary of assignments
 SELECT * FROM [StudentCheck].[GetReportRotationSummary](3668,NULL, NULL)
**************************************************************/
CREATE FUNCTION [StudentCheck].[GetRotationSummary]
(
	@SchoolId INT = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@HospitalId INT = null
)

RETURNS 
@Result TABLE 
(
	APNO int,
	TotalRotations int,
	InReview int,
	Accepted int,
	PreAdverse INT,
	Adverse INT,
	NoPosition int
)
AS
BEGIN
	INSERT INTO @Result(APNO, TotalRotations, InReview, Accepted, PreAdverse, Adverse, NoPosition)
	SELECT
	ASA.APNO,
	COUNT(*),
	Sum(CASE WHEN asa.StudentActionID=0 THEN 1 ELSE 0 END), -- IN REVIEW
	Sum(CASE WHEN asa.StudentActionID=1 THEN 1 ELSE 0 END), -- ACCEPTED
	Sum(CASE WHEN asa.StudentActionID=2 THEN 1 ELSE 0 END), -- preadverse
	Sum(CASE WHEN asa.StudentActionID=3 THEN 1 ELSE 0 END), -- adverse
	Sum(CASE WHEN asa.StudentActionID=4 THEN 1 ELSE 0 END) -- no position
	FROM dbo.ApplStudentAction ASA WITH (NOLOCK)
	 INNER JOIN dbo.Appl A WITH (NOLOCK) ON A.APNO = ASA.APNO
	WHERE A.CLNO = COALESCE(@SchoolId, A.CLNO)
	AND ASA.CreateDate BETWEEN COALESCE(@StartDate,ASA.CreateDate) AND COALESCE(@EndDate,CURRENT_TIMESTAMP)
	AND ASA.CLNO_Hospital = COALESCE(@HospitalId, ASA.CLNO_Hospital)
	AND asa.IsActive=1
	GROUP BY ASA.APNO
	RETURN
END
