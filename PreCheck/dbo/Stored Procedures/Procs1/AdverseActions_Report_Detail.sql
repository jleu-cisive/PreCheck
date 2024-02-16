
/******************************************************************
Procedure Name : [dbo].[AdverseActions_Report_Detail]
Requested By:Maximiliana Senkbeil
Developer: Amy Liu
Description: 06/19/2018 HDT34799:Create Compliance Q-Report
Execution : EXEC [dbo].[AdverseActions_Report_Detail] 'Memorial Hermann','06/01/2018','06/05/2018'
******************************************************************/

CREATE PROCEDURE [dbo].[AdverseActions_Report_Detail]
@AffiliateName varchar(100) =NULL,
@FromDate datetime = null,
@ToDate datetime = null
AS
BEGIN
	IF OBJECT_ID('tempdb..#TempAffiliateAPNOList') IS NOT NULL
		DROP TABLE #TempAffiliateAPNOList
	IF OBJECT_ID('tempdb..#TempAdverseActionList') IS NOT NULL
		DROP TABLE #TempAdverseActionList
	IF OBJECT_ID('tempdb..#TempPreAdverseActionList') IS NOT NULL
		DROP TABLE #TempPreAdverseActionList

			SET NOCOUNT ON;
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--DECLARE @AffiliateName varchar(100) ='Memorial Hermann',
--		@FromDate datetime = '06/01/2018',
--		@ToDate datetime ='06/05/2018'
SELECT ra.AffiliateID, ra.Affiliate ,c.Name, a.* INTO #TempAffiliateAPNOList
FROM appl a with(nolock)
INNER JOIN client c with(nolock) ON a.CLNO = c.CLNO
INNER JOIN dbo.refAffiliate ra	with(nolock) ON c.AffiliateID = ra.AffiliateID	
WHERE (ra.Affiliate=@AffiliateName OR isnull(@AffiliateName, '')='') 
AND ra.AffiliateID IS NOT NULL
--AND COALESCE(a.ApDate, a.CreatedDate)>=@FromDate AND COALESCE(a.ApDate, a.CreatedDate)<=@ToDate
AND (COALESCE(a.ApDate, a.CreatedDate)>=@FromDate OR COALESCE(@FromDate,COALESCE(a.ApDate, a.CreatedDate))=COALESCE(a.ApDate, a.CreatedDate) )
AND (COALESCE(a.ApDate, a.CreatedDate)<=@ToDate OR COALESCE(@ToDate, COALESCE(a.ApDate, a.CreatedDate))= COALESCE(a.ApDate, a.CreatedDate))


--SELECT * FROM #TempAffiliateAPNOList

SELECT aa.*, ras.Status AS AdverseActionStatus INTO #TempAdverseActionList
FROM #TempAffiliateAPNOList a with(nolock)
INNER JOIN dbo.AdverseAction aa	with(nolock) ON aa.APNO = a.APNO
INNER JOIN dbo.refAdverseStatus ras ON aa.StatusID	=ras.refAdverseStatusID 

SELECT aa.apno,aah.*, ras2.Status PreAverseActionStatus into #TempPreAdverseActionList
FROM  #TempAdverseActionList aa
INNER JOIN dbo.AdverseActionHistory aah with(nolock) ON aah.AdverseActionID = aa.AdverseActionID AND aah.StatusID IN (29,30,34)
INNER JOIN dbo.refAdverseStatus ras2 ON aa.StatusID	=ras2.refAdverseStatusID 

SELECT a.Affiliate,a.CLNO,a.apno, a.CreatedDate, a.apdate, a.First, a.last, aa.ClientEmail, aa.Name, 
	(aa.address1 +' '+ isnull(aa.Address2,'')+ ' ' +aa.city +' '+aa.zip) AS Address, aa.ApplicantEmail, aa.AdverseActionStatus, NULL AS PreAdverseActionStatus, NULL AS Date
	FROM #TempAffiliateAPNOList  a with(nolock)
	INNER JOIN #TempAdverseActionList aa with(nolock) ON a.apno= aa.apno 
Union 
SELECT a.Affiliate,a.clno,a.apno, a.CreatedDate, a.apdate, a.First, a.last, null as ClientEmail, paa.UserID AS Name, 
	null AS Address, null as ApplicantEmail, NULL as AdverseActionStatus, paa.PreAverseActionStatus AS PreAdverseActionStatus, paa.Date AS Date
	 FROM #TempAffiliateAPNOList  a with(nolock)
	 INNER JOIN	#TempPreAdverseActionList paa with(nolock) ON a.apno= paa.apno
ORDER BY apno, apdate, createddate, Date 

	IF OBJECT_ID('tempdb..#TempAffiliateAPNOList') IS NOT NULL
		DROP TABLE #TempAffiliateAPNOList
	IF OBJECT_ID('tempdb..#TempAdverseActionList') IS NOT NULL
		DROP TABLE #TempAdverseActionList
	IF OBJECT_ID('tempdb..#TempPreAdverseActionList') IS NOT NULL
		DROP TABLE #TempPreAdverseActionList

	SET NOCOUNT OFF
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END