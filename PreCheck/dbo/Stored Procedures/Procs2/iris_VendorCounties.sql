
/*

Example:		EXEC iris_VendorCounties 513806
Modified By:	Joshua Ates
Modified Date:	2/10/2021
Modification:	Moved Subquery in the select statment to a CTE to reduce number of table calls.  Cleaned up the procedure.
--iris_VendorCounties 513806
--iris_VendorCounties 97700
*/

CREATE PROCEDURE [dbo].[iris_VendorCounties] 
	@Researcher_id int
AS
Set NoCount On

BEGIN
 /* #NCount Table */
	DROP TABLE IF EXISTS #CountNCount
	DROP TABLE IF EXISTS #T1


	CREATE TABLE #CountNCount
	(
		 CNTY_NO	INT
		,VendorID	INT
		,ncount		INT
	)
	INSERT INTO #CountNCount(CNTY_NO,VendorID,ncount)
			SELECT
				 C.CNTY_NO
				,C.VendorID
				,COUNT(crimid) AS ncount
			FROM 
				dbo.Crim C WITH (NOLOCK) 
			WHERE 
				C.ishidden = 0 
			AND (C.VendorID = @Researcher_id) 
			AND (C.Clear in('O','W'))
			GROUP BY 
				C.CNTY_NO
				,C.VendorID


CREATE TABLE #T1
	(
		cnty_no int,
		county char(100),
		ncount int,
		R_Name char(100) 
	)

INSERT INTO #T1 
	(
		 cnty_no
		,county
		,ncount
		,R_Name
	)
SELECT 
	 iris_Researcher_Charges.cnty_no
	,c.A_County + ', ' + c.[State]  AS Researcher_county
	,ncount 
	,iris_Researchers.R_Name AS R_Name   
FROM 
	iris_Researcher_Charges WITH (NOLOCK) 
LEFT OUTER JOIN
	iris_Researchers WITH (NOLOCK) 
	ON iris_Researcher_Charges.Researcher_id = iris_Researchers.R_id 
INNER JOIN 
	dbo.TblCounties c WITH (NOLOCK) 
	ON iris_Researcher_Charges.cnty_no = c.CNTY_NO
LEFT JOIN
	#CountNCount 
	ON 	#CountNCount.CNTY_NO	=	iris_Researcher_Charges.cnty_no
WHERE 
	iris_Researcher_Charges.Researcher_id = @Researcher_id


SELECT 
	 county+'('+ISNULL(CAST([ncount] AS varChar),'0')+')' As Researcher_county 
	,cnty_no
	,R_Name 
FROM 
	#T1  AS T1
ORDER BY 
	ncount DESC

END