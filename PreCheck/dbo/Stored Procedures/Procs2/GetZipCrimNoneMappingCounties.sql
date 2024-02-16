-- Alter Procedure GetZipCrimNoneMappingCounties
-- ==================================================================================
-- Author:		Dongmei He
-- Create date: 10/16/2019
-- Description:	gets crim counties that are missing in the PreCheckZipCrimComponentMap
-- Modified By: Deepak Vodethela
-- Modified Date: 03/12/2020
-- Description: The logic was modifed to get the Original County ExternalID and assign it to the developed county.
-- Modified Date: 06/24/2020
-- Description: Fixed the logic for inserting into PreCheckZipCrimComponentMap table.
-- Modified Date: 08/17/2020
-- Description: Removed "PARISH" for all the counties:
--				(CASE WHEN a.A_County LIKE '% PARISH' THEN REPLACE(a.A_County, ' PARISH', '') ELSE a.A_County END) AS A_County
--		and left outer join to work properly we have added AND (m.IsActive = 1 OR M.IsActive IS NULL)  AND (m.SendAttempts < 6 OR M.SendAttempts IS NULL)
-- Modified Date: 11/11/2020
-- Description :  Added condition to get the developed leads after the report is finalized.
-- VD:12/21/2020 - TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update. Introduced RefCrimStageID = 4 (Review Reportability Service Completed)
-- schapyala 03/17/2021 - Added Rowlock to the update statement to update PartnerReferenceLeadNumber
-- ==================================================================================
CREATE PROCEDURE [dbo].[GetZipCrimNoneMappingCounties] 
AS
BEGIN
	-- Get All leads that are supossed to go out i.e. APNO based
	CREATE TABLE #tmpAllRecords(
		[APNO] [int] NOT NULL,
		[CrimID] [int] NOT NULL,
		[PartnerReferenceLeadNumber] [varchar](50) NULL,
		[RefCrimStageID] int,
		[CNTY_NO] [int] NULL,
		[A_County] [varchar](50) NULL,
		[State] [varchar](50) NULL,
		[FIPS] [varchar](25) NULL,
		[WorkOrderID] [int]  NULL,
		[PartnerReference] [varchar](20) NULL,
		[LeadTypeCode] [varchar](50) NULL,
		[IsHidden] [BIT] NULL,
		[IsSameStateDevelopedLead] bit default (0)
		)

	--Index on temp tables
	CREATE INDEX IX_tmpAllRecords_01 ON #tmpAllRecords(APNO) INCLUDE (CNTY_NO,IsHidden)
	CREATE INDEX IX_tmpAllRecords_02 ON #tmpAllRecords(CrimID) INCLUDE (PartnerReferenceLeadNumber)
	CREATE INDEX IX_tmpAllRecords_03 ON #tmpAllRecords(PartnerReferenceLeadNumber)
	CREATE INDEX IX_tmpAllRecords_04 ON #tmpAllRecords(IsHidden) INCLUDE (PartnerReferenceLeadNumber,[IsSameStateDevelopedLead])

	INSERT INTO #tmpAllRecords
	SELECT  c.APNO, c.CrimID, c.PartnerReferenceLeadNumber, c.RefCrimStageID, c.CNTY_NO, ct.A_County, ct.[state] AS [State], ct.FIPS,
			w.WorkOrderID, st.PartnerReference,
			CASE WHEN ct.refcountytypeid IN (3,9) THEN 'FEDCRM' ELSE 'FELMSD' END AS LeadTypeCode,
			c.IsHidden,0 AS [IsSameStateDevelopedLead]
	FROM dbo.Crim c(nolock) 
	INNER JOIN dbo.TblCounties ct(nolock) on c.CNTY_NO = ct.CNTY_NO
	INNER JOIN dbo.Appl a(nolock) on c.apno = a.apno 
	INNER JOIN dbo.ZipCrimWorkOrders w(nolock) on c.apno = w.APNO
	INNER JOIN dbo.ZipCrimWorkOrdersStaging st(nolock) on w.WorkOrderID = st.WorkOrderID
	WHERE w.refWorkOrderStatusID = 4  
	 AND (a.ApStatus <> 'F' OR (a.ApStatus = 'F' AND a.CompDate > CAST(CURRENT_TIMESTAMP as Date)))
	 
	 --SELECT '#tmpAllRecords' AS TableName, * FROM #tmpAllRecords AS t
	 --SELECT '#tmpAllRecords with 0' AS TableName, * FROM #tmpAllRecords AS t WHERE t.PartnerReferenceLeadNumber = '0'

	 -- Initial catchup to update all the lead numbers in Crim table from Mapping table
	 --SELECT distinct m.APNO AS MappingAPNO, m.SectionUniqueID, m.ExternalID, t.CrimID, t.PartnerReferenceLeadNumber
		UPDATE t SET t.PartnerReferenceLeadNumber = m.ExternalID
	 FROM #tmpAllRecords AS t 
	 INNER JOIN dbo.PreCheckZipCrimComponentMap m(nolock) ON t.CrimID = m.SectionUniqueID
	 WHERE t.PartnerReferenceLeadNumber = '0'

	-- Update dockets lead number
	;WITH GetDockets AS
	(
		SELECT	DISTINCT C.APNO, C.CrimID, C.CNTY_NO,T.PartnerReferenceLeadNumber
		FROM #tmpAllRecords AS t  (NOLOCK) 
		INNER JOIN dbo.Crim c (NOLOCK) on t.APNO = c.APNO AND T.CNTY_NO = C.CNTY_NO
		WHERE T.PartnerReferenceLeadNumber = '0'
		GROUP BY C.APNO, C.CrimID, C.CNTY_NO,T.PartnerReferenceLeadNumber
	) --SELECT * FROM GetDockets ORDER BY RowNumber
	, GetOriginalLeadNumber AS
	(
		SELECT	M.APNO, M.SectionUniqueID, R.CNTY_NO AS CNTY_NO, m.ExternalID AS OriginalLeadNumber
		FROM GetDockets AS R  (NOLOCK) 
		INNER JOIN dbo.PreCheckZipCrimComponentMap m(nolock) ON R.CrimID = m.SectionUniqueID
	)
	--SELECT * FROM GetOriginalLeadNumber 
	, GetRelatedReports AS
	(
		SELECT  D.APNO AS M_APNO, D.SectionUniqueID, D.CNTY_NO AS M_CNTY_NO, OriginalLeadNumber,
				C.APNO, C.CrimID, C.CNTY_NO, C.PartnerReferenceLeadNumber,
				ROW_NUMBER() OVER(PARTITION BY C.APNO, C.CNTY_NO ORDER BY C.APNO, C.CNTY_NO ) AS RowNumber
		FROM GetOriginalLeadNumber AS d  (NOLOCK) 
		INNER JOIN GetDockets AS C  (NOLOCK)  ON D.APNO = C.APNO AND D.CNTY_NO = C.CNTY_NO
	)
	--SELECT DISTINCT C.APNO, C.CrimID, C.CNTY_NO, C.PartnerReferenceLeadNumber, R.OriginalLeadNumber
		UPDATE C SET C.PartnerReferenceLeadNumber = R.OriginalLeadNumber
	FROM GetRelatedReports r  (NOLOCK) 
	INNER JOIN #tmpAllRecords AS C ON R.APNO = C.APNO AND R.CNTY_NO = C.CNTY_NO 
	WHERE RowNumber > 1
	  AND C.PartnerReferenceLeadNumber = '0'
    --GROUP BY C.APNO, C.CrimID, C.CNTY_NO,C.PartnerReferenceLeadNumber, R.OriginalLeadNumber

	-- This below logic is used to assign the Original Lead number to the developed lead if the the developed lead was from same state.
	-- Get Original LeadNumber For Developed Lead For Same State and same report
	;WITH GetOriginalLeadNumberForDevelopedLeadForSameState AS
	(
	SELECT	t.CrimID, t.PartnerReferenceLeadNumber AS [OriginalLeadNumber], t.[state], t.APNO,
			ROW_NUMBER() OVER (PARTITION BY t.APNO, t.[state] ORDER BY t.CrimID) AS RowNumber
	FROM #tmpAllRecords t  (NOLOCK) 
	INNER JOIN dbo.Crim c(nolock) ON C.APNO = t.APNO AND c.IsHidden = 0
	INNER JOIN dbo.TblCounties X(nolock) ON X.[State] = T.[state] --AND X.CNTY_NO = c.CNTY_NO 
	WHERE t.PartnerReferenceLeadNumber != '0'	
	GROUP BY t.CrimID, t.PartnerReferenceLeadNumber, t.[state], t.apno
	) SELECT g.CrimID, g.OriginalLeadNumber, g.[state], g.APNO
		INTO #tmpGetOriginalLeadNumberForEachDevelopedLead
	  FROM GetOriginalLeadNumberForDevelopedLeadForSameState g
	  WHERE g.RowNumber = 1	 
	
	 --SELECT '#tmpGetOriginalLeadNumberForEachDevelopedLead' AS TableName, * FROM #tmpGetOriginalLeadNumberForEachDevelopedLead
	 
	-- Update Developed leads Lead Number with Original lead number from same state and county for a report.
	--SELECT *
		 UPDATE d SET d.PartnerReferenceLeadNumber = t.OriginalLeadNumber,
					  d.[IsSameStateDevelopedLead] = 1
	FROM #tmpAllRecords d 
	INNER JOIN #tmpGetOriginalLeadNumberForEachDevelopedLead t  (NOLOCK) ON d.apno = t.apno AND d.[state] = T.[state] --and d.CrimID = t.CrimID
	WHERE d.PartnerReferenceLeadNumber = '0'

	Print 'Update Precheckcomponentmap table with the new active crimid'
	 -- Replace Inactive Crims with Active Crims
	 ;WITH GetInActiveLeadsFromMapping AS
	 (
	 SELECT c.APNO AS APNO, C.CrimID as CrimID, c.CNTY_NO as CNTY_NO, c.IsHidden
	 FROM #tmpAllRecords AS A  (NOLOCK) 
	 INNER JOIN dbo.PreCheckZipCrimComponentMap m(NOLOCK) ON A.CrimID = m.SectionUniqueID
	 INNER JOIN dbo.Crim AS C ON M.SectionUniqueID = C.CrimID
	 WHERE C.IsHidden = 1
	 ),GetActiveLeads AS 
	 (
		SELECT  g.APNO, g.CrimID, g.CNTY_NO, g.IsHidden, 
				c.CrimID AS CrimCrimID, c.CNTY_NO as CrimCNTY_NO, c.IsHidden AS CrimIsHidden,c.PartnerReferenceLeadNumber,
				ROW_NUMBER() OVER (PARTITION BY C.APNO, g.CNTY_NO ORDER BY C.CrimID) AS RowNumber
		FROM GetInActiveLeadsFromMapping AS g  (NOLOCK) 
		INNER JOIN dbo.Crim c ON g.CNTY_NO = C.CNTY_NO AND g.APNO = c.APNO
		WHERE C.IsHidden = 0
	 ) 
	 --SELECT 'GetInActiveLeadsFromMapping' AS TableName, g.APNO, g.CrimID, g.CNTY_NO, g.IsHidden, g.CrimCrimID, g.CrimCNTY_NO, g.CrimIsHidden, g.PartnerReferenceLeadNumber--, m.SectionUniqueID,m.CreateDate
		UPDATE M SET m.SectionUniqueID = g.CrimCrimID
	 FROM GetActiveLeads as g  (NOLOCK) 
	 INNER JOIN dbo.PreCheckZipCrimComponentMap AS M ON g.CrimID = m.SectionUniqueID
	 WHERE g.RowNumber = 1
	   AND g.CrimCrimID NOT IN (SELECT P.SectionUniqueID FROM dbo.PreCheckZipCrimComponentMap AS P  (NOLOCK) )

    --Print 'Update Crim with PartnerReferenceLeadNumber'
	--schapyala added Rowlock to prevent deadlock scenario - 03/17/2021
	-- Update Crim's PartnerReferenceLeadNumber with derived Lead Number
	--SELECT distinct 'Update Crim' AS TableName, c.APNO, C.CrimID, t.CrimID, c.PartnerReferenceLeadNumber, t.PartnerReferenceLeadNumber
	UPDATE C WITH (rowlock) SET C.PartnerReferenceLeadNumber = t.PartnerReferenceLeadNumber
	FROM #tmpAllRecords t (nolock) 
	INNER JOIN Crim C ON T.CrimID = c.CrimID
	WHERE t.PartnerReferenceLeadNumber != '0'
	 AND C.PartnerReferenceLeadNumber != t.PartnerReferenceLeadNumber -- Update only when lead numbers do not match
	 

	--Print 'Last Get'
	-- The last Get
	SELECT	a.APNO, a.CrimID, a.CNTY_NO, 
			(CASE WHEN a.A_County LIKE '% PARISH' THEN REPLACE(a.A_County, ' PARISH', '') ELSE a.A_County END) AS A_County,--a.A_County,  
			a.[state], a.FIPS, a.WorkOrderID, a.PartnerReference, 
			CASE WHEN a.PartnerReferenceLeadNumber = '0' THEN NULL
				ELSE a.PartnerReferenceLeadNumber
			END AS ExternalID, a.LeadTypeCode
	FROM #tmpAllRecords a (nolock)
	WHERE a.IsHidden = 0 
	  AND (a.PartnerReferenceLeadNumber = '0' OR [IsSameStateDevelopedLead] = 1)

	 DROP TABLE #tmpGetOriginalLeadNumberForEachDevelopedLead
	 DROP TABLE #tmpAllRecords


END
