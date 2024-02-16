
/************************************************************************************************************

*************************************************************************************************************
Author: Arindam Mitra
Date: 07/17/2023
Purpose: This report shows how many orders per jurisdiction went through auto order and Order Management. HDT#101514

***************************************************************************************************************/

/*	
exec [dbo].[QReport_usp_OrderVolume_ByCounty] '01/01/2023', '03/31/2023', 'HARRIS, TX'
*/

CREATE PROCEDURE [dbo].[QReport_usp_OrderVolume_ByCounty]
@StartDate date,  
@EndDate date,
@County VARCHAR(100)

AS

BEGIN

	SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @StartDT AS DATEtime,
	@EndDT AS DATEtime

	SET @StartDT = CONVERT(datetime, @StartDate )
	SET @EndDT = CONVERT(datetime, @EndDate) + ' 23:59:59.000'

	;WITH CTE_AUTO AS
	(
	SELECT cnt.county, cnt.state, COUNT(L.CrimID) AS AutoOrderVolume
	FROM dbo.IrisAliasUpdate_Autocheck_log l WITH(NOLOCK)
	INNER JOIN Crim c WITH(NOLOCK) on l.crimid = c.Crimid 
	INNER JOIN dbo.Appl a WITH(NOLOCK) ON a.Apno = c.APNO
	INNER JOIN dbo.Counties cnt WITH(NOLOCK) ON C.CNTY_NO  = cnt.CNTY_NO 
	INNER JOIN dbo.Iris_Researchers AS r(NOLOCK) ON C.vendorid = R.R_id
	WHERE c.IsHidden = 0 AND c.Crimenteredtime between @StartDT and @EndDT 
	AND cnt.county like '%' + @County + '%' 
	GROUP BY cnt.county, cnt.state
	)

	SELECT County, State, AutoOrderVolume AS [Auto Order Volume], (ISNULL(TOTAL,0) - AutoOrderVolume) AS [Order Management Volume]
	FROM
	(
	SELECT cnt.county,  cnt.state, COUNT(C.CrimID) AS TOTAL, ISNULL(CTE_AUTO.AutoOrderVolume,0) AS AutoOrderVolume
	FROM dbo.Crim c WITH(NOLOCK)
	INNER JOIN dbo.Appl a WITH(NOLOCK) ON a.Apno = c.APNO
	INNER JOIN dbo.Counties cnt WITH(NOLOCK) ON C.CNTY_NO  = cnt.CNTY_NO 
	LEFT JOIN CTE_AUTO AS CTE_AUTO ON CNT.County = CTE_AUTO.county AND CNT.State=CTE_AUTO.State
	WHERE c.IsHidden = 0 AND c.Crimenteredtime between @StartDT and @EndDT 
	AND cnt.county like '%' + @County + '%' 
	GROUP BY cnt.state, cnt.county, AutoOrderVolume
	) ABC
	Order by County



	SET NOCOUNT OFF

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END


