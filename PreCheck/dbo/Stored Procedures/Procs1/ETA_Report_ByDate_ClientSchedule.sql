
-- =============================================
-- Author: Dongmei He
-- Create date: 04-18-2018
-- Description: Gets pending reports that contain the estimated completion date 
-- Modified By : Radhika Dereddy on 08/08/2018
-- Modified Reason: In Client Access, always look for WeborderParentCLno and CLNO, because WebOrderParentCLno is the Parent Account.
-- Modified Reason : Radhika Dereddy on 02/04/2019 - Brian Silver 
-- HDT 46072 - When running the ETA report available for clients in Client Access, 
-- I am coming across reports which are in a reopened status.  My recollection is that this report is only supposed to pull in reports that are pending first close. 
-- An example is report 4426575 is currently showing for HCA (7519) when we run the report. 
-- EXEC [ETA_Report_ByDate] 12143
-- EXEC [ETA_Report_ByDate] 7519
-- EXEC [ETA_Report_ByDate] 3115
-- =============================================================================
CREATE PROCEDURE [dbo].[ETA_Report_ByDate_ClientSchedule]
@CLNO  INT
       
As         

   --SELECT @count = count(CLNO) FROM Client WHERE ParentClno = @CLNO --commented by Radhika Dereddy on 08/08/2018 We need to use WeborderparentCLno and CLNO
	 DECLARE @count INT
      SELECT @count = count(CLNO) FROM Client WHERE CLNO =@clno OR WebOrderParentCLNO = @clno

      DECLARE @ETADate TABLE
       (
         Apno int, 
         ETADate DateTime,
         CertDate DateTime
       )

       INSERT INTO @ETADate (Apno, ETADate, CertDate)   
       SELECT ETA.Apno, Max(ETADate) AS ETADate, C.ClientCertUpdated
       FROM dbo.APPL AS A(NOLOCK)
       INNER JOIN dbo.ApplSectionsETA AS ETA(NOLOCK) ON A.APNO = ETA.Apno   
       INNER JOIN dbo.ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
       LEFT OUTER JOIN dbo.Crim AS CR(NOLOCK) ON ETA.SectionKeyID = CR.CrimID AND ETA.ApplSectionID = 5
       LEFT OUTER JOIN dbo.EMPL AS E(NOLOCK) ON ETA.SectionKeyID = E.EmplID AND ETA.ApplSectionID  = 1
       LEFT OUTER JOIN dbo.Educat AS ED(NOLOCK) ON ETA.SectionKeyID = ED.EducatID AND ETA.ApplSectionID = 2
       LEFT OUTER JOIN dbo.ProfLic AS P(NOLOCK) ON ETA.SectionKeyID = P.ProfLicID AND ETA.ApplSectionID = 4
       LEFT OUTER JOIN dbo.DL AS D(NOLOCK) ON ETA.Apno = D.APNO AND ETA.ApplSectionID = 6
       LEFT OUTER JOIN dbo.MedInteg AS M(NOLOCK) ON ETA.Apno = M.APNO AND ETA.ApplSectionID = 7
       WHERE (CR.Clear NOT IN ('T','F','P')
                       OR M.SectStat NOT IN ('2','3','4','5')
                       OR D.SectStat NOT IN ('2','3','4','5')
                       OR P.SectStat NOT IN ('2','3','4','5')
                       OR ED.SectStat NOT IN ('2','3','4','5')
                       OR E.SectStat NOT IN ('2','3','4','5')
                       OR A.APSTATUS != 'F')
          AND CR.IsHidden = 0
          AND A.Clno IN (SELECT CLNO FROM dbo.Client (NOLOCK) WHERE CLNO =@clno OR WebOrderParentCLNO = @clno)
         GROUP BY ETA.Apno, C.ClientCertUpdated
       --HAVING C.ClientCertUpdated >= @StartDate 
       --AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 

       IF @count > 0 
       BEGIN
              SELECT A.CLNO AS [Client Number], 
                        C.Name AS [Client Name], 
                        ETA.APNO as [Report Number], 
                        A.First + ' ' + A.Last AS [Applicant Name] , 
                        P.PackageDesc AS [Package Ordered], 
                        ETA.CertDate AS [Report Start Date],
                        CONVERT(varchar, ETADate, 101) AS [Report Conclusion ETA]  
              FROM @ETADate AS ETA
              INNER JOIN dbo.Appl AS A(NOLOCK) ON ETA.APNO = A.APNO
              INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
              LEFT OUTER JOIN dbo.PackageMain AS P(NOLOCK) ON P.PackageID = A.PackageID
              WHERE A.ApStatus NOT IN ('F','M')
                AND A.OrigCompDate IS NULL
                AND C.IsInactive = 0
                --AND A.Clno IN (SELECT CLNO FROM Client(NOLOCK) WHERE ParentCLNO = @CLNO) -- commented by Radhika Dereddy on 08/08/2018 We need to use WeborderparentCLno and CLNO
                AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO =@clno OR WebOrderParentCLNO = @clno)
       END
       ELSE
       BEGIN
              SELECT A.CLNO AS [Client Number], 
                        C.Name AS [Client Name], 
                        ETA.APNO as [Report Number], 
                        A.First + ' ' + A.Last AS [Applicant Name] , 
                        P.PackageDesc AS [Package Ordered], 
                        ETA.CertDate AS [Report Start Date], 
                        CONVERT(varchar, ETADate, 101) AS [Report Conclusion ETA]  
              FROM @ETADate AS ETA
              INNER JOIN dbo.Appl AS A(NOLOCK) ON ETA.APNO = A.APNO
              INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
              LEFT OUTER JOIN dbo.PackageMain AS P(NOLOCK) ON P.PackageID = A.PackageID
              WHERE A.ApStatus NOT IN ('F','M')
                AND A.OrigCompDate IS NULL
                AND C.IsInactive = 0
                --AND A.Clno IN (SELECT CLNO FROM dbo.Client(NOLOCK) WHERE Clno = @CLNO)
                AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO =@clno OR WebOrderParentCLNO = @clno)
       END

