/******************************************************
-- exec [dbo].[ReportRolodexInvestigatorSubmissionByDateRange] '02/18/2013','02/19/2013'
--CreatedBy:Amy Liu on 03/28/2018 the report is similar with Rolodex Investigator Submission By Date except for date range
*******************************************************/
CREATE procedure [dbo].[ReportRolodexInvestigatorSubmissionByDateRange]
(
@StartDate Datetime,
@EndDate datetime	
) AS
BEGIN

SET NOCOUNT ON


CREATE TABLE #TblPivot
(
CreatedBy varchar(50),
ReviewType varchar(50)
) 

INSERT INto #TblPivot
SELECT CreatedBy, CASE WHEN ReviewType='Edit' THEN 'Employment Entry Updates' ELSE 'New Employment Entries' END AS ReviewType FROM [PreCheck].[dbo].[RolodexReview]
WHERE 
CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) >=@StartDate AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate)))<@EndDate
UNION ALL
SELECT CreatedBy, CASE WHEN ReviewType='Edit' THEN 'Education Entry Updates' ELSE 'New Eductaion Entries' END AS ReviewType FROM [PreCheck].[dbo].[RolodexReviewEdu]
WHERE 
CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) >= @StartDate AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) < @EndDate

SELECT
*
FROM
(SELECT CreatedBy, ReviewType FROM #TblPivot) AS P
PIVOT
(
COUNT(ReviewType) FOR ReviewType IN ([New Employment Entries],[Employment Entry Updates],[New Eductaion Entries],[Education Entry Updates])
) AS pv

DROP TABLE #TblPivot

END
