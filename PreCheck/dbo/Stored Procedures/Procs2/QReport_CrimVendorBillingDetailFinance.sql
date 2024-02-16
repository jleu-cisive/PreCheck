-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	?
-- Modify Date : 01/03/2023
-- Modified By : Jeff Simenc
-- Description : Added AppAliasID to the output
-- =============================================
CREATE PROCEDURE [dbo].[QReport_CrimVendorBillingDetailFinance]
(
    @StartDate DATETIME,
    @EndDate DATETIME,
    @VendorID INT
)
AS
BEGIN
    SET NOCOUNT ON;
    --Declare   
    -- @StartDate DateTime='08/01/2022',  
    -- @EndDate DateTime='08/10/2022',  
    -- @VendorID varchar(100)=28 
    -- ,@Apno Varchar(200)='6566953'   --6717545,6696895,6718043    

    DROP TABLE IF EXISTS #Base;

    SELECT DISTINCT
           IR.R_Name AS 'VendorName',
           AL.Cnt,
           Cr.CNTY_NO,
           A.APNO,
           A.ApDate,
           A.CompDate,
           A.Investigator,
           A.DOB,
           A.CLNO,
           C.CAM,
           C.[Name],
           ra.Affiliate,
           rbc.BillingCycle,
           IR.R_Name,
           Cr.CRIM_SpecialInstr,
           Cr.Priv_Notes,
           Cr.CrimID,
           css.crimdescription,
           Cr.IsHidden,
           Cr.County,
           tc.[State],
           IRC.Researcher_Aliases_count AS [Alias Allowed Count],
           IRC.Researcher_combo,
           IRC.Researcher_other,
           IRC.Researcher_CourtFees,
           Cr.deliverymethod,
           MAX(Cr.Crimenteredtime) AS Crimenteredtime,
           MAX(cl.ChangeDate) AS 'Vendor Reviewed Date'
    INTO #Base
    FROM dbo.Appl A (NOLOCK)
        INNER JOIN dbo.Client C WITH (NOLOCK)
            ON A.CLNO = C.CLNO
        INNER JOIN dbo.refBillingCycle rbc WITH (NOLOCK)
            ON rbc.BillingCycleID = C.BillingCycleID
        INNER JOIN dbo.Crim Cr (NOLOCK)
            ON Cr.APNO = A.APNO
        INNER JOIN dbo.refAffiliate ra WITH (NOLOCK)
            ON C.AffiliateID = ra.AffiliateID
        INNER JOIN dbo.Crimsectstat css WITH (NOLOCK)
            ON css.crimsect = Cr.[Clear]
        INNER JOIN dbo.Iris_Researcher_Charges IRC (NOLOCK)
            ON IRC.Researcher_id = Cr.vendorid
               AND IRC.cnty_no = Cr.CNTY_NO
        INNER JOIN dbo.Iris_Researchers IR (NOLOCK)
            ON IR.R_id = IRC.Researcher_id
        INNER JOIN dbo.TblCounties tc WITH (NOLOCK)
            ON Cr.CNTY_NO = tc.CNTY_NO
        LEFT OUTER JOIN dbo.ChangeLog cl WITH (NOLOCK)
            ON cl.ID = Cr.CrimID
        LEFT OUTER JOIN
        (
            SELECT SectionKeyID,
                   IsActive,
                   COUNT(0) AS Cnt
            FROM dbo.ApplAlias_Sections
            WHERE IsActive = 1
            GROUP BY SectionKeyID,
                     IsActive
        ) AS AL
            ON Cr.CrimID = AL.SectionKeyID
               AND AL.IsActive = 1
    WHERE IR.R_id = @VendorID
          AND cl.ChangeDate
          BETWEEN @StartDate AND @EndDate
          AND Cr.deliverymethod <> 'OnlineDB'
          AND AL.Cnt > 0
          AND A.CLNO NOT IN ( 2135, 3468 )
          AND Cr.[Clear] NOT IN ( 'I' )
    --AND A.Apno IN (@Apno) Select * From Iris_Researchers
    GROUP BY IR.R_Name,
             AL.Cnt,
             Cr.CNTY_NO,
             A.APNO,
             A.ApDate,
             A.CompDate,
             A.Investigator,
             A.DOB,
             A.CLNO,
             C.CAM,
             C.[Name],
             ra.Affiliate,
             rbc.BillingCycle,
             IR.R_Name,
             Cr.CRIM_SpecialInstr,
             Cr.Priv_Notes,
             Cr.CrimID,
             css.crimdescription,
             Cr.IsHidden,
             Cr.County,
             tc.[State],
             IRC.Researcher_Aliases_count,
             IRC.Researcher_combo,
             IRC.Researcher_other,
             IRC.Researcher_CourtFees,
             Cr.deliverymethod;


    DROP TABLE IF EXISTS #tmpNameByAPNO;

    SELECT t.APNO,
           t.CrimID,
           S.ApplSectionID,
           S.IsActive,
           ISNULL(AA.First, '') + ' ' + ISNULL(AA.Middle, '') + ' ' + ISNULL(AA.Last, '') AS [QualifiedNames],
           S.CreatedBy AS [PRInvestigator],
           AA.ApplAliasID
    INTO #tmpNameByAPNO
    FROM #Base t (NOLOCK)
        INNER JOIN dbo.ApplAlias AA (NOLOCK)
            ON t.APNO = AA.APNO
        LEFT OUTER JOIN dbo.ApplAlias_Sections S (NOLOCK)
            ON AA.ApplAliasID = S.ApplAliasID
               AND t.CrimID = S.SectionKeyID
    WHERE AA.IsActive = 1
          AND AA.IsPublicRecordQualified = 1
          AND
          (
              S.ApplSectionID = 5
              OR S.ApplSectionID IS NULL
          )
          AND
          (
              S.IsActive = 1
              OR S.IsActive IS NULL
          );


    DROP TABLE IF EXISTS #tmpSelectedAliases;
    SELECT t.CrimID,
           t.APNO,
           t.PRInvestigator,
           QualifiedNames,
           t.ApplAliasID
    INTO #tmpSelectedAliases
    FROM #tmpNameByAPNO t (NOLOCK)
    GROUP BY t.CrimID,
             t.APNO,
             t.ApplAliasID,
             t.PRInvestigator,
             QualifiedNames;


    SELECT DISTINCT
           t.APNO AS APNO,
           K.ApplAliasID AS AppAliasID,
           t.Cnt AS NameSentCount,
           t.ApDate [App Created date],
           t.CompDate [App Completed Date],
           t.Investigator [Applicant Investigator],
           t.CAM,
           t.CLNO,
           t.[Name] AS [Client Name],
           t.Affiliate AS [Client Affiliate],
           t.BillingCycle,
           t.DOB,
           t.R_Name AS [Vendor Name],
           t.[County],
           t.[State],
           t.CrimID,
           t.IsHidden AS [UnUsed],
           t.CRIM_SpecialInstr AS [Crim Special Instructions],
           t.Priv_Notes AS [Private Notes],
           K.QualifiedNames AS [Names Selected],
           K.PRInvestigator,
           t.[Alias Allowed Count],
           t.Researcher_combo,
           t.Researcher_other,
           t.Researcher_CourtFees,
           t.[Vendor Reviewed Date],
           t.Crimenteredtime
    FROM #Base t (NOLOCK)
        LEFT OUTER JOIN #tmpSelectedAliases AS K (NOLOCK)
            ON t.CrimID = K.CrimID;


END;