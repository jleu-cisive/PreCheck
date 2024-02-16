CREATE procedure [dbo].[ReportRolodexSupervisorApprovedByDate]
(@Date Datetime) AS
BEGIN
/*
Author: Bernie Chan
CreatedDate: 2/11/2015
Returns: Counts "New Employment Entries", "Employment Entry Updates", "New Education Entries", "Education Entry Updates" for each Supervisor approved for a specific date
Purpose: QReport
-- exec [dbo].[ReportRolodexSupervisorApprovedByDate] '02/18/2013'
*/
SET NOCOUNT ON
 
CREATE TABLE #TablePivot
(
Supervisor varchar(50),
ReviewType varchar(50)
) 

INSERT INTO #TablePivot
SELECT Supervisor, CASE WHEN ReviewType='Edit' THEN 'Employment Entry Updates' ELSE 'New Employment Entries' END AS ReviewType FROM [PreCheck].[dbo].[RolodexReview]
WHERE 
Status='Approved' AND 
CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) = @Date
UNION ALL
SELECT Supervisor, CASE WHEN ReviewType='Edit' THEN 'Education Entry Updates' ELSE 'New Eductaion Entries' END AS ReviewType FROM [PreCheck].[dbo].[RolodexReviewEdu]
WHERE 
Status='Approved' AND 
CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, CreatedDate))) = @Date

SELECT
*
FROM
(SELECT Supervisor, ReviewType FROM #TablePivot) AS P
PIVOT
(
COUNT(ReviewType) FOR ReviewType IN ([New Employment Entries],[Employment Entry Updates],[New Eductaion Entries],[Education Entry Updates])
) AS pv

DROP TABLE #TablePivot

END