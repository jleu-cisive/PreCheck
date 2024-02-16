-- =============================================  
-- Author:  <YSharma>  
-- Create date: <12-16-2022>  
-- Description: <Created for new Qreport As per HDT #71836 , Merged logics from multipule reports for fulfill requirement>  
-- Execution : Exec dbo.QReport_NamesSentToCrimVendor '2022-11-03','2022-11-05'
-- =============================================  
-- =============================================  
-- Modify By:  <YSharma>  
-- Modify date: <01-06-2023>  
-- Description: <Created for new Qreport As per HDT #71836 , Introduce @Cnty_No AND @Vendor_Id as parameter for performance>  
-- Execution : Exec dbo.QReport_NamesSentToCrimVendor '2022-11-03','2022-11-05',557,''
-- =============================================  
CREATE PROCEDURE dbo.QReport_NamesSentToCrimVendor 
(
@StartDate DateTime
,@EndDate DateTime
,@Cnty_No INTEGER
,@Vendor_Id INTEGER
)
AS 
BEGIN 
--DECLARE --6995101
--@StartDate DateTime ='2022-11-03'   
--,@EndDate DateTime ='2022-11-05'
--,@Cnty_No INTEGER=3667;
IF @Cnty_No='' Or @Cnty_No=0
BEGIN
SET @Cnty_No =Null
END
IF @Vendor_Id='' Or @Vendor_Id=0
BEGIN
SET @Vendor_Id =Null
END
	DROP TABLE IF EXISTS #Base1    
        SELECT A.Apno
            ,a.First [Applicant First]
            ,a.Last [Applicant Last]
            ,Cr.CrimID
            ,Cr.County
            ,Cr.CNTY_NO,Cr.vendorid
            ,IRC.Researcher_Aliases_Count AS [Aliases Allowed in IRIS]
            ,Cr.Priv_Notes
            INTO #Base1
         FROM dbo.Appl A WITH(NOLOCK)  
         INNER JOIN dbo.Crim Cr WITH(INDEX(IX_Crim_APNO_CntyNo),NOLOCK) ON A.APNO=Cr.APNO
         INNER JOIN dbo.Iris_Researcher_Charges IRC (NOLOCK) ON IRC.Researcher_id =Cr.vendorid AND IRC.cnty_no =Cr.CNTY_NO    
         WHERE Cr.CNTY_NO=ISNULL(@Cnty_No,Cr.CNTY_NO) AND Cr.vendorid=ISNULL(@Vendor_Id,Cr.vendorid) AND 
		 A.CreatedDate >=@StartDate AND A.CreatedDate <= @EndDate
		  

         DROP TABLE IF EXISTS #Base
         SELECT A.*
         ,(SELECT COUNT(0) FROM dbo.ApplAlias (NOLOCK) WHERE APNO = A.APNO AND IsPublicRecordQualified = 1 AND IsActive = 1) AS [QualifiedNames]
            ,(SELECT COUNT(0) FROM dbo.ApplAlias_Sections (NOLOCK) WHERE SectionKeyID = A.CrimID AND IsActive = 1) AS [SentNames]
         INTO #Base 
         FROM #Base1 A

	DROP TABLE IF EXISTS #tmpNameByAPNO    
    
	  SELECT t.Apno, t.CrimId,  S.ApplSectionId,S.IsActive,    
		ISNULL(AA.First,'') +' '+ ISNULL(AA.Middle,'') +' '+ ISNULL(AA.Last,'') as [QualifiedNames],     
		s.CreatedBy as [PRInvestigator]    
	  INTO #tmpNameByAPNO    
	  FROM #Base t (NOLOCK)    
	  INNER JOIN dbo.ApplAlias AA(NOLOCK) ON t.APNO = AA.APNO     
	  LEFT OUTER JOIN dbo.ApplAlias_Sections S(NOLOCK) ON  AA.ApplAliasID = S.ApplAliasID AND t.CrimID = s.SectionKeyID    
	  WHERE AA.IsActive = 1     
		AND AA.IsPublicRecordQualified = 1    
		AND (S.ApplSectionId = 5 OR S.ApplSectionId IS NULL)    
		AND (S.IsActive = 1 OR S.IsActive IS NULL)    
    
    
	DROP TABLE IF EXISTS #tmpSelectedAliases    
		SELECT  t.CrimID, t.APNO,    
		t.PRInvestigator,QualifiedNames     
		INTO #tmpSelectedAliases    
		FROM #tmpNameByAPNO t (NOLOCK)    
		GROUP BY t.CrimID, t.APNO, t.PRInvestigator, QualifiedNames   


	SELECT 
	   B.*,
	   STUFF((SELECT '; ' + N.QualifiedNames 
			  FROM #tmpSelectedAliases N
			  WHERE N.APNO = B.APNO AND N.CrimID = B.CrimID 
			  FOR XML PATH('')), 1, 1, '') [Names/Sent]
	FROM #Base B 
	ORDER BY B.APNO,B.CrimID

END