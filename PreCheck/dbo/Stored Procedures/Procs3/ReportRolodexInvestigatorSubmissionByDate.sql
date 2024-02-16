CREATE procedure [dbo].[ReportRolodexInvestigatorSubmissionByDate]
(@Date Datetime) AS
BEGIN
/*
Author: Bernie Chan
CreatedDate: 2/11/2015
Returns: Counts "New Employment Entries", "Employment Entry Updates", "New Education Entries", "Education Entry Updates" for each Investigator submit for a specific date
Purpose: QReport
-- exec [dbo].[ReportRolodexInvestigatorSubmissionByDate] '02/18/2013'
*/
SET NOCOUNT ON


CREATE TABLE #TblPivot
(
CreatedBy varchar(50),
ReviewType varchar(50)
) 

INSERT INto #TblPivot
SELECT CreatedBy, CASE WHEN ReviewType='Edit' THEN 'Employment Entry Updates' ELSE 'New Employment Entries' END AS ReviewType FROM [PreCheck].[dbo].[RolodexReview]
WHERE 
CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) = @Date
UNION ALL
SELECT CreatedBy, CASE WHEN ReviewType='Edit' THEN 'Education Entry Updates' ELSE 'New Eductaion Entries' END AS ReviewType FROM [PreCheck].[dbo].[RolodexReviewEdu]
WHERE 
CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) = @Date

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