
-- =============================================
-- Date: 05/07/2018
-- Author: Gaurav Bangia
-- Description: Function returns rotation summary
-- =============================================

CREATE FUNCTION [Enterprise].[GetReportRotationSummary] 
(@APNO INT, @ActionId INT=NULL)

Returns @Result Table
(ReportNumber INT,
ActionId INT,
ActionName VARCHAR(100),
TotalCount INT)

AS
BEGIN

INSERT INTO @Result
        ( ReportNumber, ActionId, ActionName, TotalCount)
SELECT
	asa.APNO,
	asa.StudentActionID,
	a.StudentAction,
	COUNT(*)	
FROM dbo.ApplStudentAction asa
	INNER JOIN dbo.refStudentAction a ON asa.StudentActionID=a.StudentActionID
	INNER JOIN dbo.Client c ON asa.CLNO_Hospital=c.CLNO AND ISNULL(c.IsInactive,0)=0
WHERE ISNULL(asa.IsActive,1)=1 AND asa.APNO=@APNO
AND asa.StudentActionID = CASE WHEN @ActionId IS NULL THEN asa.StudentActionID ELSE @ActionId END
	GROUP BY ASA.APNO, asa.StudentActionID, a.StudentAction

  RETURN
END



