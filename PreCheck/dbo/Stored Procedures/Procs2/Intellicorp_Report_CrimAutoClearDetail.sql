/*
-- =============================================
-- Modified By: Vairavan A
-- Modified Date: 08/19/2022
-- Description: Ticketno-59921 Add colulmn to Qreport: Intellicorp Criminal Auto Clear Detail
-- EXEC [dbo].[Intellicorp_Report_CrimAutoClearDetail] '07/28/2022','08/19/2022'
-----------------------------------------------
-- =============================================
*/
CREATE   PROCEDURE [dbo].[Intellicorp_Report_CrimAutoClearDetail] @StartDate datetime, @EndDate datetime
AS
BEGIN

SET @EndDate = DATEADD(DAY, +1, @EndDate)

SELECT c.Crimid as [Crim Id],--code added for ticket id - 59921
 FORMAT(PLS.CreatedDate, 'd') AS Date
,C.APNO
,AA.first + ' ' + coalesce(AA.middle,'') + ' ' + AA.last as Name
,CN.A_County AS Jurisdiction
,CN.State AS State
,case when CS.crimdescription IS NULL then 'Incomplete' else CS.crimdescription end AS Status
  FROM [dbo].[Partner_LogStatus] AS PLS
  Join 	Crim C WITH (NOLOCK)  on  C.crimid = pls.sectionId
	INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
	INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = PLS.[ApplAliasID]
    INNER JOIN dbo.[TblCounties] as cn on cn.cnty_no = c.CNTY_NO
	LEFT JOIN [Crimsectstat] as cs on cs.crimsect = PLS.CrimStatus
WHERE PLS.PartnerID = 4
	AND PLS.SectionId = C.CrimId
	AND C.CNTY_NO = CN.CNTY_NO
	AND PLS.CreatedDate >= @StartDate
	AND PLS.CreatedDate < @EndDate
ORDER BY FORMAT(PLS.CreatedDate, 'd')
	,CN.State
	,CN.A_County

END
