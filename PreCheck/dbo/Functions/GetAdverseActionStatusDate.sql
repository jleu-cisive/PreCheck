
--SELECT [dbo].[GetAdverseActionStatusDate](4386404, '5,30',3654)
CREATE FUNCTION [dbo].[GetAdverseActionStatusDate]
(
	@APNO INT,
	@StatusIds varchar(100),
	@CLNO INT = null
)
RETURNS DateTime
AS
BEGIN
DECLARE @StartDate DateTime

		SELECT @StartDate = 
		ISNULL(MIN(AH.date),DATEADD(DAY,1, GETDATE()))
		  FROM AdverseAction AA INNER JOIN AdverseActionHistory AH
			ON AA.AdverseActionID=AH.AdverseActionID
		INNER JOIN Split(',',@StatusIds) SI on AH.StatusID=SI.Item
		 WHERE AA.APNO=@APNO AND ISNULL(aa.Hospital_CLNO,ISNULL(@CLNO,aa.Hospital_CLNO))=ISNULL(@CLNO,aa.Hospital_CLNO)
	Return @StartDate
END

