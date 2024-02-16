-- =============================================
-- Author:		Humera Ahmed
-- Create date: 2/24/2020
-- Description:	Fix Q-Report: Client List with Revenue By Date - replacing old stored procedure [dbo].[Client_List_with_Revenue_ByDate]
-- Exec [dbo].[Client_List_with_Revenue_ByDate_Revised] '01/01/2020','01/31/2020','0','8'
-- =============================================
CREATE PROCEDURE [dbo].[Client_List_with_Revenue_ByDate_Revised]
	-- Add the parameters for the stored procedure here
	@StartDate datetime = '01/01/2019',
	@EndDate datetime = '12/31/2019',
	@CLNO varchar(MAX) = 0,
	@AffiliateIDs varchar(MAX) = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF OBJECT_ID('tempdb..#Revenue') IS NOT NULL DROP TABLE #Revenue
	IF OBJECT_ID('tempdb..#Revenue_NoPassThruFees') IS NOT NULL DROP TABLE #Revenue_NoPassThruFees
	IF OBJECT_ID('tempdb..#Package_Revenue') IS NOT NULL DROP TABLE #Package_Revenue
	IF OBJECT_ID('tempdb..#AppCount') IS NOT NULL DROP TABLE #AppCount

	IF(@CLNO = 0 OR @CLNO IS NULL OR LOWER(@CLNO) = 'null' OR @CLNO='')
	BEGIN
	  SET @CLNO = 0
	END

	IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' ) 
	BEGIN  
		SET @AffiliateIDs = 0  
	END

	select 
		im.CLNO [Client Number],
		Sum(i.Amount) [Revenue] 
	INTO #Revenue
	from invmaster im 
	inner join invdetail i on  i.invoicenumber = im.invoicenumber
	INNER JOIN client c ON im.CLNO = c.CLNO
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	LEFT JOIN dbo.refClientType rct ON c.ClientTypeID = rct.ClientTypeID
	WHERE 
		im.invdate >=@STARTDATE 
		and im.invdate <DATEADD(DAY, 1, @EndDate) 
		AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))
		AND (@AffiliateIDs = 0 OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	group BY im.CLNO

	--SELECT * FROM #Revenue r ORDER BY r.[Client Number]

	select 
		im.CLNO [Client Number],
		Sum(i.Amount) [Revenue_NoPassThruFees] 
	INTO #Revenue_NoPassThruFees
	from invmaster im 
	inner join invdetail i on  i.invoicenumber = im.invoicenumber
	INNER JOIN client c ON im.CLNO = c.CLNO
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	LEFT JOIN dbo.refClientType rct ON c.ClientTypeID = rct.ClientTypeID
	WHERE 
		im.invdate >=@STARTDATE 
		and im.invdate <DATEADD(DAY, 1, @EndDate) 
		AND i.Type <> 1 
		AND i.Description NOT LIKE '%service charge%'
		AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))
		AND (@AffiliateIDs = 0 OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	group BY im.CLNO

	--SELECT * FROM #Revenue_NoPassThruFees rnptf ORDER BY rnptf.[Client Number]

	select 
		im.CLNO [Client Number],
		Sum(i.Amount) [Package Revenue] 
	INTO #Package_Revenue
	from invmaster im 
	inner join invdetail i on  i.invoicenumber = im.invoicenumber
	INNER JOIN client c ON im.CLNO = c.CLNO
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	LEFT JOIN dbo.refClientType rct ON c.ClientTypeID = rct.ClientTypeID
	WHERE 
		im.invdate >=@STARTDATE 
		and im.invdate <DATEADD(DAY, 1, @EndDate) 
		AND i.Type = 0
		AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))
		AND (@AffiliateIDs = 0 OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	group BY im.CLNO

	--SELECT * FROM #Package_Revenue pr ORDER BY pr.[Client Number]

	select 
		im.CLNO [Client Number],
		count(i.APNO) [AppCount] 
	INTO #AppCount
	from invmaster im 
	inner join invdetail i on  i.invoicenumber = im.invoicenumber
	INNER JOIN client c ON im.CLNO = c.CLNO
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	LEFT JOIN dbo.refClientType rct ON c.ClientTypeID = rct.ClientTypeID
	WHERE 
		im.invdate >=@STARTDATE 
		and im.invdate <DATEADD(DAY, 1, @EndDate) 
		AND i.Type = 0
		AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))
		AND (@AffiliateIDs = 0 OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	group BY im.CLNO

	--SELECT * FROM #AppCount ac ORDER BY ac.[Client Number], ac.AppCount

	select 
		c.CLNO [Client Number],
		c.Name [Client Name],
		rct.ClientType [Client Type],
		RA.AffiliateID, 
		RA.Affiliate [Affiliate Name],
		c.Addr1 [Address],
		c.City [City],
		c.[State],
		case when c.[IsInactive] = 0 THEN 'True' ELSE 'False' end [Is Client Active],
		r.Revenue,
		rnptf.Revenue_NoPassThruFees [Revenue w/o Pass Thru Fees],
		pr.[Package Revenue],
		ac.AppCount [Report Count]
	from client c
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	Left JOIN #Revenue r ON c.clno = r.[Client Number]
	LEFT JOIN #Revenue_NoPassThruFees rnptf ON c.clno = rnptf.[Client Number]
	LEFT JOIN #Package_Revenue pr ON c.clno = pr.[Client Number]
	LEFT JOIN #AppCount ac ON c.CLNO = ac.[Client Number]
	left JOIN dbo.refClientType rct ON c.ClientTypeID = rct.ClientTypeID
	WHERE
		(@CLNO = 0 OR c.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))
		AND (@AffiliateIDs = 0 OR ra.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	ORDER BY c.CLNO

END
