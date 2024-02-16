-- Alter Procedure Vendor_Aging_report
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 05/08/2017
-- Description:	Vendor Aging Report 
-- Modified By: Deepak Vodethela
-- Modified Date: 09/16/2017
-- Requested By: Joe
-- Request Description:  I need to see crims from “today” to infinity backwards in history that are in the W-Waiting and O-Ordered Status. 
-- Modified by Amy Liu on 02/12/2018: "Days Over"="VendorElapsed"  - "AverageDays "
-- Modified by Humera Ahmed on 10/19/2018: HDT#41656 to fix error - "Conversion failed when converting date and/or time from character string".
-- Modified by Doug DeGenaro on 10/19/2018: HDT#53219 to fix error changed Ordered to use IrisOrdered - "Conversion failed when converting date and/or time from character string".
-- Modified by Prasanna on 09/09/2020: HDT#77256 QReport for Vendor Aging Report -We need this time increased from 90 days from the iris ordered date to 6 months
-- Modified by Andy on 8/4/2021:  scope changed back to 90 days of history.
-- Modified bby Cameron DeCook on 1/6/2023: HDT#78101 to add CrimID to output
-- Execution: EXEC [dbo].[Vendor_Aging_report]
-- =============================================
--EXEC Vendor_Aging_Report 
CREATE PROC dbo.Vendor_Aging_report
	-- Add the parameters for the stored procedure here

AS
BEGIN


	SET NOCOUNT ON;


	SELECT	
			C.CrimID, a.APNO AS APNO,IR.R_Name AS VendorName, A.CLNO, X.Name AS CLientName, F.Affiliate,  A.ApDate AS ApDate, C.CNTY_NO, C.County, 
			C.Crimenteredtime as CrimEnteredTime,
			C.Ordered AS CrimOrderedDate,
			C.Last_Updated AS LastUpdated,
			C.IrisOrdered,
			C.DeliveryMethod
	INTO #tmp  -- DROP TABLE #tmp
	FROM dbo.Appl AS A WITH (NOLOCK)
	INNER JOIN dbo.Crim AS C WITH (NOLOCK) ON A.Apno = C.apno
	INNER JOIN dbo.Client AS X ON A.CLNO = X.CLNO
	INNER JOIN dbo.refAffiliate AS F ON X.AffiliateID = F.AffiliateID
	LEFT OUTER JOIN dbo.iris_ws_screening AS I WITH (NOLOCK) ON C.CrimID = I.Crim_id
	LEFT OUTER JOIN dbo.CriminalVendor_Log AS CV ON C.apno = CV.Apno AND C.Cnty_no = CV.CNTY_NO
	LEFT OUTER JOIN dbo.Iris_Researchers AS IR(NOLOCK) ON C.vendorid = IR.R_id
	WHERE ISNULL(A.Apstatus,'P') IN ('P','W')
	  AND ISNULL(C.clear,'') IN ('O','W')
	  AND C.IsHidden = 0
	  AND C.IrisOrdered >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE())-90, 0)

	SELECT	AA.APNO, AA.ApplAliasID, X.SectionKeyID AS CrimID, ISNULL(Last,'') +' '+ ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Generation,'') AS QualifiedNames
			INTO #tmpAliasesSent
    FROM dbo.ApplAlias AS AA(NOLOCK) 
    LEFT OUTER JOIN dbo.ApplAlias_Sections AS X(NOLOCK) ON AA.ApplAliasID = X.ApplAliasID AND X.IsActive =1
    WHERE X.SectionKeyID IN (SELECT CrimID FROM #tmp )
        AND IsPublicRecordQualified = 1 
        AND AA.IsActive = 1

    SELECT  CrimID, 
			APNO,
            NamesSentToVendor = STUFF((SELECT '/ ' + QualifiedNames
                                        FROM #tmpAliasesSent b 
                                        WHERE b.CrimID = a.CrimID 
                                        FOR XML PATH('')), 1, 2, '') 
            INTO #tmpSelectedAliases
    FROM #tmpAliasesSent A
    GROUP BY CrimID, APNO

	-- drop table #tmpcounts
	SELECT T.APNO, T.CrimID, VendorName, ApDate, CLNO, CLientName, T.Affiliate, CrimOrderedDate, CrimEnteredTime, LastUpdated, County, NamesSentToVendor,
			CONVERT(numeric(7, 2), dbo.GETBUSINESSDAYS(convert(datetime,ApDate,1), GETDATE())) AS [ApplicationElapsed],
			CONVERT(numeric(7, 2), dbo.GETBUSINESSDAYS(convert(varchar(20),CrimOrderedDate,1), GETDATE())) AS [AgingVendor], 
			ISNULL(CONVERT(DECIMAL(10,2),P.Average/24), 0) AS [AverageDays],
			DeliveryMethod
			INTO #tmpCounts
	FROM #tmp AS T
	LEFT OUTER JOIN #tmpSelectedAliases AS A ON T.CrimID = A.CrimID
	LEFT OUTER JOIN (SELECT ROUND((AVG(CONVERT(NUMERIC(7,2), 
							( dbo.GETBUSINESSDAYS(ISNULL(C.IrisOrdered, CONVERT(DATETIME, C.Ordered)),c.Last_Updated) + ((CASE WHEN DATEDIFF(HH,ISNULL(C.IrisOrdered, CONVERT(DATETIME, C.Ordered)),c.Last_Updated) < 24 THEN DATEDIFF(HH,ISNULL(C.IrisOrdered, CONVERT(DATETIME, C.Ordered)),c.Last_Updated) ELSE 0 END)/24.0)))) * 24),0) AS Average,
							C.CNTY_NO, COUNT(C.Crimid) AS SearchCount
					FROM dbo.TblCounties AS CC(nolock) 
					LEFT OUTER JOIN dbo.Crim AS C with (nolock) on CC.CNTY_NO = C.CNTY_NO
					WHERE C.IrisOrdered  >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE())-90, 0)
					  AND ISDATE(Ordered) = 1  
					  AND isnull(ordered,'')<>''
					  AND C.IrisOrdered IS NOT NULL 
					  AND C.Last_Updated IS NOT NULL 
					GROUP BY C.CNTY_NO) P ON P.CNTY_NO = T.CNTY_NO
	GROUP BY T.APNO, T.CrimID, VendorName, ApDate, CLNO, CLientName, Affiliate, CrimOrderedDate, CrimEnteredTime, LastUpdated, County, NamesSentToVendor, P.Average, DeliveryMethod


    SELECT	T.APNO, T.CrimID, T.VendorName, T.Apdate, T.CLNO, T.CLientName, T.CrimOrderedDate, T.LastUpdated, T.County, T.NamesSentToVendor, T.ApplicationElapsed, T.AgingVendor AS [VendorElapsed], T.AverageDays,
			DeliveryMethod
			INTO #tmpAll
    FROM #tmpCounts AS T
	ORDER BY T.CrimOrderedDate

	-- Get all the Crims for the parameter [Status]
	SELECT ROW_NUMBER() OVER(ORDER BY CrimID DESC) AS CrimRowNumber, CrimID, APNO, deliverymethod AS DeliveryMethod
		INTO #tmpCrimsForWebService
	FROM #tmpAll
	WHERE DeliveryMethod = 'WEB SERVICE'

	DECLARE @TotalNumberOfCrimRecords int = (SELECT MAX(CrimRowNumber)FROM #tmpCrimsForWebService);
	DECLARE @CrimRecordRow int;
	DECLARE @Apno int;
	DECLARE @CrimID int;
	DECLARE @DeliveryMethod varchar(50)
	DECLARE @txtlast bit, @txtalias bit, @txtalias2 bit, @txtalias3 bit, @txtalias4 bit
	DECLARE @primaryName varchar(70), @alias1 varchar(70), @alias2 varchar(70), @alias3 varchar(70), @alias4 varchar(70)
	DECLARE @sentNames varchar(350)

	-- Get the true names that were actually sent out to vendors
	WHILE (@TotalNumberOfCrimRecords != 0)
	BEGIN	
			SELECT @CrimRecordRow = CrimRowNumber, @Apno = Apno, @CrimID = CrimID, @DeliveryMethod = DeliveryMethod
			FROM #tmpCrimsForWebService
			WHERE CrimRowNumber = @TotalNumberOfCrimRecords
			ORDER BY CrimRowNumber DESC		

			SELECT @apno = apno, @txtlast = txtlast, @txtalias = txtalias, @txtalias2 = txtalias2, @txtalias3 = txtalias3, @txtalias4 = txtalias4 
			FROM dbo.Crim (NOLOCK) 
			WHERE crimid = @crimid 

			IF(@txtlast = 1)
				BEGIN		
					SELECT @primaryName = CONCAT(first, ' ', middle, ' ', last, ' ', generation, ', ')	FROM APPL (NOLOCK)	WHERE APNO = @apno
				END

			IF(@txtalias = 1)
				BEGIN
					SELECT @alias1 = CONCAT(Alias1_First, ' ', Alias1_Middle, ' ', Alias1_Last, ' ', Alias1_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END
			IF(@txtalias2 = 1)
				BEGIN
					SELECT @alias2 = CONCAT(Alias2_First, ' ', Alias2_Middle, ' ', Alias2_Last, ' ', Alias2_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END
			IF(@txtalias3 = 1)
				BEGIN
					SELECT @alias3 = CONCAT(Alias3_First, ' ', Alias3_Middle, ' ', Alias3_Last, ' ', Alias3_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END
			IF(@txtalias4 = 1)
				BEGIN
					SELECT @alias4 = CONCAT(Alias4_First, ' ', Alias4_Middle, ' ', Alias4_Last, ' ', Alias4_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END

			SET @sentNames = CONCAT(@primaryName, ' / ', @alias1, ' / ', @alias2, ' / ', @alias3, ' / ', @alias4)

			SET @sentNames = ISNULL(@primaryName,'')

			UPDATE C
				SET NamesSentToVendor = @sentNames
			FROM #tmpCounts AS C
			INNER JOIN #tmpCrimsForWebService AS W ON C.CrimID = W.CrimID
			WHERE W.CrimID = @CrimID

			SET @TotalNumberOfCrimRecords = @CrimRecordRow - 1

	END
--CrimID added for HDT#78101

	SELECT	T.CrimID, T.APNO, T.VendorName, T.CLNO, T.CLientName, T.Affiliate,  T.Apdate, T.CrimOrderedDate, T.LastUpdated, T.County, T.NamesSentToVendor, 
		CAST(T.ApplicationElapsed AS DECIMAL(12,1)) AS ApplicationElapsed,
		CAST(T.AgingVendor AS DECIMAL(12,1)) AS [VendorElapsed], 
		CAST(T.AverageDays AS DECIMAL(12,1)) AS AverageDays,
		DaysOver =CAST((CAST(T.AgingVendor AS DECIMAL(12,1))-	CAST(T.AverageDays AS DECIMAL(12,1))) AS DECIMAL(12,1)),
		eta.ETADate
	FROM #tmpCounts AS T(NOLOCK)
	LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON T.APNO	= eta.Apno AND T.CrimID	= eta.SectionKeyID AND eta.ApplSectionID = 5
	ORDER BY T.Apdate

END
