
-- =============================================
-- Author:		Sahithi
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- Exec [HCA_PendingReport]  0,0,'03/01/2020','03/20/2022'
 /* Modified By: Vairavan A
-- Modified Date: 07/06/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -54481 Update AffiliateID Parameters 971-1053
*/
---Testing
/*
Exec [HCA_PendingReport]  0,'0','03/01/2020','03/23/2020'
Exec [HCA_PendingReport]  0,'0','03/01/2017','03/20/2022'
Exec [HCA_PendingReport]  7519,'4','03/01/2020','03/20/2020'
*/

--Modified by Arindam Mitra on 03/03/2023 to add AffiliateId 4 and 294 (HCA and HCA Velocity) for ticket# 84621 PART 3
-- Exec [HCA_PendingReport]  0,'0','03/01/2022','01/30/2023'
-- =============================================
CREATE PROCEDURE [dbo].[HCA_PendingReport]

 @CLNO int,
--@AffiliateID int,--code commented by vairavan for ticket id -53763(54481)
 @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763(54481) --- Currently Not in use will open when require in future   
 @StartDate	Date,
 @EndDate	Date

--declare 
--@CLNO int=0,
--@AffiliateIDs int=0,
--@StartDate       Date='03/01/2017',
--@EndDate         Date='03/20/2022'
As
BEGIN
                -- SET NOCOUNT ON added to prevent extra result sets from
                -- interfering with SELECT statements.
                SET NOCOUNT ON;

	--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

    -- Insert statements for procedure here
   DECLARE @count INT 
   	DECLARE @ETAPASTTRIGGER date = GETDATE()  
   --set @CLNO  = 7519

   SELECT @count = count(CLNO) FROM Client with(nolock) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
   and IsInactive = 0
  -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
   --and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
   and AffiliateID IN (4,294) --code added by Arindam for ticket# 84621 PART 3

--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
                CREATE TABLE #tmpMainSet(
                                [ApplSectionID] [int] NOT NULL,
                                [SectionName] VARCHAR(25) NOT NULL,
                                [Apno] [int] NOT NULL,
                                [SectionKeyID] [int] NOT NULL,
                                [ETADate] [DATETIME] NULL,
                                [ClientCertUpdated] [DATETIME] NULL,
                                [Client Notes] VARCHAR(MAX) NOT NULL,
                                CrimStatus varchar(max) null,
                                SanctionCheckStatus varchar(max) null,
                                LicenseStatus varchar(max) null,
                                EducationStatus varchar(max) null ,
                                EmploymentStatus varchar(max) null,
                               [SectStat] VARCHAR(25)  NULL
                                )

                CREATE TABLE #tmpAll(
                                [ApplSectionID] [int] NOT NULL,
                                [SectionName] VARCHAR(25) NOT NULL,
                                [Apno] [int] NOT NULL,
                                [SectionKeyID] [int] NOT NULL,
                                [ETADate] [DATETIME] NULL,
                                [ClientCertUpdated] [DATETIME] NULL,
                                [Client Notes] VARCHAR(MAX) NOT NULL,
                                CrimStatus varchar(max) null,
                            SanctionCheckStatus varchar(max) null,
                                LicenseStatus varchar(max) null,
                                EducationStatus varchar(max) null ,
                                EmploymentStatus varchar(max) null,
                                [SectStat] VARCHAR(25)  NULL,
                                [RowNumber] [int] NOT NULL
                                )

                CREATE TABLE #tmpAllMaxETA(
                                [ApplSectionID] [int] NOT NULL,
                                [SectionName] VARCHAR(25) NOT NULL,
                                [Apno] [int] NOT NULL,
                                [SectionKeyID] [int] NOT NULL,
                                [ETADate] [DATETIME] NULL,
                                [ClientCertUpdated] [DATETIME] NULL,
                                [Client Notes] VARCHAR(MAX) NOT NULL,
                                CrimStatus varchar(max) null,
                                SanctionCheckStatus varchar(max) null,
                                LicenseStatus varchar(max) null,
                                EducationStatus varchar(max) null ,
                                EmploymentStatus varchar(max) null,
                                [SectStat] VARCHAR(25)  NULL,
                                [RowNumber] [int] NOT NULL
                                )

                --Index on temp tables
                CREATE CLUSTERED INDEX IX_tmpMainSet_01 ON #tmpMainSet(APNO, SectionKeyID)
                CREATE CLUSTERED INDEX IX_tmpAll_02 ON #tmpAll(APNO, SectionKeyID)
                CREATE CLUSTERED INDEX IX_tmpAllMaxETA_02 ON #tmpAllMaxETA(APNO, SectionKeyID)

                ;WITH Criminal AS
                (
                                SELECT ETA.ApplSectionID, null as SectionName , ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated
                                                                ,CASE  WHEN ETA.ApplSectionID = 5 THEN ISNULL(CR.Pub_Notes,'') END AS [Client Notes],                                                
                                                                 CASE   when cs.crimsect in ('T','F','P','S','Z') then  'Completed' else 'Pending'  End As CrimStatus,
																'' as SanctionCheckStatus,'' as LicenseStatus, '' as EducationStatus, '' as EmploymentStatus,
																'' as Sectstat
															
                                FROM ApplSectionsETA AS ETA with(NOLOCK)
                                INNER JOIN APPL AS A with(NOLOCK) ON ETA.APNO = A.Apno            
                                LEFT OUTER JOIN ClientCertification C with(NOLOCK) ON ETA.APNO = C.APNO
                                LEFT OUTER JOIN dbo.Crim AS CR with(NOLOCK) ON ETA.SectionKeyID = CR.CrimID AND ETA.ApplSectionID = 5
								inner join  Crimsectstat as cs  with(NOLOCK)  on cs.crimsect=cr.clear
                                WHERE
								CR.[Clear]  IN ('T','F','P','S','Z','R','O','V','W','') 
                                 AND 
								  CR.IsHidden = 0
                                  AND A.APSTATUS != 'F'
								   AND C.ClientCertUpdated >= @StartDate 
                                  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
                                  AND A.Clno IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
								  -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
								 --and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
								 AND AffiliateID IN (4,294)) --code added by Arindam for ticket# 84621 PART 3
                )
				
                INSERT INTO #tmpMainSet
                SELECT X.ApplSectionID, 
                        CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section, 
                        Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes],-- ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus],
                    x.CrimStatus,x.SanctionCheckStatus,x.LicenseStatus,x.EducationStatus,x.EmploymentStatus,X.Sectstat
                FROM Criminal AS X with(nolock)
                INNER JOIN dbo.ApplSections Y  with(nolock) ON X.ApplSectionID = Y.ApplSectionID;


                ;WITH Employment AS
                (
                                SELECT  ETA.ApplSectionID, null as SectionName , ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated
                                                                ,CASE WHEN ETA.ApplSectionID = 1 THEN ISNULL(E.Pub_Notes,'') END AS [Client Notes],
                                                                '' as CrimStatus,'' as SanctionCheckStatus,'' as LicenseStatus, '' as EducationStatus,
																  CASE WHEN isnull(s.Code,'0') = '0' THEN 'Not Ordered'
																 WHEN s.Code in ('4','5','6','7','8') THEN 'Completed'  when s.code='9' then 'Attempted' when s.code='H'then 'Pending' END AS Employmentstatus ,
																null as Sectstat
                                FROM ApplSectionsETA AS ETA with(NOLOCK)
                                INNER JOIN APPL AS A with(NOLOCK) ON ETA.APNO = A.Apno            
                                LEFT OUTER JOIN ClientCertification C with(NOLOCK) ON ETA.APNO = C.APNO
                                LEFT OUTER JOIN dbo.EMPL AS E with(NOLOCK) ON ETA.SectionKeyID = E.EmplID AND ETA.ApplSectionID = 1
								inner join SectStat s  with(NOLOCK)  on s.code=e.SectStat
                                WHERE 
								E.SectStat IN ('9','8','7','6','5','4','H')
                                 and
								  a.APSTATUS != 'F'
								  and 
								  e.IsOnReport=1
								   AND
								   C.ClientCertUpdated >= @StartDate
                                  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
                                  AND A.Clno IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO))
								    -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
									--and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
									AND AffiliateID IN (4,294)) --code added by Arindam for ticket# 84621 PART 3
                )
                INSERT INTO #tmpMainSet
                SELECT X.ApplSectionID, CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section, 
                   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes],-- ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus],
                  x.CrimStatus,x.SanctionCheckStatus,x.LicenseStatus, x.EducationStatus, X.Employmentstatus,X.Sectstat
                FROM Employment AS X with(NOLOCK) 
                INNER JOIN dbo.ApplSections Y  with(NOLOCK) ON X.ApplSectionID = Y.ApplSectionID

                ;WITH Education AS
           (
        --                        SELECT ETA.ApplSectionID, null as SectionName , ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
        --                                                        CASE WHEN ETA.ApplSectionID = 2 THEN ISNULL(ED.Pub_Notes,'') END AS [Client Notes],
                                                           
        --                                                        '' as CrimStatus,
								--								'' as SanctionCheckStatus,
								--								'' as LicenseStatus, 
								--							        CASE WHEN s.Code in ('5','4','E','7','6','A','8') THEN 'Completed' when s.Code  in  ('9') then 'Attempted'  when s.code in ('H') then 'Pending'  END AS EducationStatus,
								--								'' as EmploymentStatus,
								--								null as Sectstat
        --                      FROM ApplSectionsETA AS ETA(NOLOCK)
        --                        INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno            
        --                        LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
        --                        LEFT OUTER JOIN dbo.Educat AS ED(NOLOCK) ON ETA.SectionKeyID = ED.EducatID AND ETA.ApplSectionID = 2
								--Inner Join SectStat s on s.Code=ED.SectStat
        --                        WHERE 	ED.SectStat IN ('H','9','5','4','E','7','6','A','8')
        --                         AND 
								--  A.APSTATUS != 'F'


								--- new code 
								SELECT distinct 2 as ApplSectionID , null as SectionName , a.Apno,  isnull(eta.SectionKeyID, ed.educatid) SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
                                                                CASE WHEN eta.ApplSectionID = 2 THEN ISNULL(ED.Pub_Notes,'') END AS [Client Notes],
                                                                '' as CrimStatus,
																'' as SanctionCheckStatus,
																'' as LicenseStatus,
															        CASE WHEN isnull(s.Code,'0') = '0' THEN 'Not Ordered'
																	WHEN s.Code in ('5','4','E','7','6','A','8') THEN 'Completed' when s.Code  in  ('9') then 'Attempted'  when s.code in ('H') then 'Pending'  END AS EducationStatus,
																'' as EmploymentStatus,
																null as Sectstat
                          from   APPL AS a with(NOLOCK) inner join educat  ed   with(NOLOCK)  ON a.APNO = ed.Apno
								Inner Join SectStat s with(NOLOCK)  on s.Code=ED.SectStat
								 left  JOIN ApplSectionsETA AS eta with(NOLOCK) ON ETA.APNO = A.Apno 
								  LEFT OUTER JOIN ClientCertification C with(NOLOCK) ON ETA.APNO = C.APNO
                               WHERE 
                             
								  a.APSTATUS != 'F'
								  and
								  ed.isonreport=1				  
                                   AND
								   C.ClientCertUpdated >= @StartDate 
                                  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
                                 AND A.Clno IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
								   -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
								--and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
								AND AffiliateID IN (4,294)) --code added by Arindam for ticket# 84621 PART 3
                )
                INSERT INTO #tmpMainSet
                SELECT X.ApplSectionID, 
                                                CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section, 
                                                Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes],
                                                x.CrimStatus,x.SanctionCheckStatus,x.LicenseStatus, x.EducationStatus, X.Employmentstatus,X.Sectstat
                FROM Education AS X with(NOLOCK) 
                INNER JOIN dbo.ApplSections Y  with(NOLOCK) ON X.ApplSectionID = Y.ApplSectionID

                ;WITH ProfessionalLicense AS
                (
                             SELECT 
				4 as ApplSectionID, null as SectionName,  a.Apno, isnull(ETA.SectionKeyID, P.ProfLicID) SectionKeyID, ETA.ETADate, C.ClientCertUpdated
                                                                ,CASE WHEN ETA.ApplSectionID = 4 THEN ISNULL(P.Pub_Notes,'') END AS [Client Notes],
                                                                    '' as CrimStatus,'' as SanctionCheckStatus,
																     CASE WHEN s.code in ('0') THEN 'Not Ordered'
																	  WHEN s.code in ('9','H') THEN 'Pending' when s.Code in ('4','5','6','7','8') then 'Completed'  END  as LicenseStatus,
																	 '' as EducationStatus, '' as EmploymentStatus,'' as Sectstat
                                FROM appl AS a with(NOLOCK) inner JOIN dbo.ProfLic AS P with(NOLOCK) ON a.APNO = P.Apno 
								Inner Join SectStat s  with(NOLOCK)  on s.Code=P.SectStat
                                left  JOIN ApplSectionsETA AS ETA with(NOLOCK) ON ETA.APNO = A.Apno and ETA.ApplSectionID = 4
                                LEFT OUTER JOIN ClientCertification C with(NOLOCK) ON ETA.APNO = C.APNO
                                WHERE
								   A.APSTATUS != 'F'
                                 AND
								 p.IsOnReport=1
								 and 
								  C.ClientCertUpdated >= @StartDate 
                                 AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
                                  AND A.Clno IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO))
								    -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
   --and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
   AND AffiliateID IN (4,294)) --code added by Arindam for ticket# 84621 PART 3
                )
			
                INSERT INTO #tmpMainSet

				
                SELECT X.ApplSectionID, 
                                                CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section, 
                                                Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes],
                                                x.CrimStatus,x.SanctionCheckStatus,x.LicenseStatus, x.EducationStatus, X.Employmentstatus,X.Sectstat
                FROM ProfessionalLicense AS X with(NOLOCK) 
                INNER JOIN dbo.ApplSections Y with(NOLOCK)  ON X.ApplSectionID = Y.ApplSectionID

				
                ;WITH SanctionCheck AS
                (
                                SELECT ETA.ApplSectionID,null as SectionName , ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated
                                                                ,NULL AS [Client Notes], 
                                                                
                                                                '' as CrimStatus,
														  CASE WHEN s.Code='9' THEN 'Pending' Else 'Completed' END   as SanctionCheckStatus,
																'' as LicenseStatus, '' as EducationStatus, '' as EmploymentStatus,null as sectstat
                                FROM ApplSectionsETA AS ETA with(NOLOCK)
                                INNER JOIN APPL AS A with(NOLOCK) ON ETA.APNO = A.Apno            
                                LEFT OUTER JOIN ClientCertification C with(NOLOCK) ON ETA.APNO = C.APNO
                                LEFT OUTER JOIN dbo.MedInteg AS M with(NOLOCK) ON ETA.Apno = M.APNO AND ETA.ApplSectionID = 7
								inner join sectstat  as  s  with(NOLOCK) on s.Code=m.SectStat
                                WHERE
									M.SectStat IN ('9','7','3','2')
                                 AND
								   A.APSTATUS != 'F'
                                 AND
								   C.ClientCertUpdated >= @StartDate 
                                  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
                                  AND A.Clno IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
								    -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
   --and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
   AND AffiliateID IN (4,294)) --code added by Arindam for ticket# 84621 PART 3
                )
                INSERT INTO #tmpMainSet
                SELECT X.ApplSectionID, 
                                                CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section, 
                                                Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes],
                                                x.CrimStatus,x.SanctionCheckStatus,x.LicenseStatus, x.EducationStatus, X.Employmentstatus,x.Sectstat
                FROM SanctionCheck AS X  with(NOLOCK) 
                INNER JOIN dbo.ApplSections Y  with(NOLOCK)  ON X.ApplSectionID = Y.ApplSectionID


                INSERT INTO #tmpAll
                SELECT  *, ROW_NUMBER() OVER (PARTITION BY M.Apno ORDER BY M.ETADate DESC, M.SectionName ASC) AS RowNumber
                FROM #tmpMainSet M 
                ORDER BY M.Apno 


			

                INSERT INTO #tmpAllMaxETA
                SELECT distinct  A.ApplSectionID,
				A.SectionName,
				A.Apno,
				A.SectionKeyID,
				A.ETADate,
				A.ClientCertUpdated,
				A.[Client Notes],	
			--	--A.CrimStatus,			
			--	--(select top 1 CrimStatus from #tmpAll  where RowNumber >= 1 and SectionName='Crim' and Apno=A.Apno) AS CrimStatus,
			--		ISNULL((select top 1  CrimStatus   from #tmpAll  where RowNumber >= 1 and SectionName='Crim' and Apno=A.Apno and LicenseStatus!='Pending'),'Pending') as criminalstatus,
			--	--A.SanctionCheckStatus,
			--	--	(select top 1 SanctionCheckStatus from #tmpAll  where RowNumber >= 1 and SectionName='SanctionCheck' and Apno=A.Apno) AS SanctionCheckStatus,
			--			ISNULL((select top 1  SanctionCheckStatus   from #tmpAll  where RowNumber >= 1 and SectionName='SanctionCheck' and Apno=A.Apno and LicenseStatus!='Not Ordered'),'Not Ordered') AS SanctionCheckStatus,
			--	--A.LicenseStatus,
			--	ISNULL((select top 1  LicenseStatus   from #tmpAll  where RowNumber >= 1 and SectionName='ProfLic' and Apno=A.Apno and LicenseStatus!='Not Ordered'),'Not Ordered') AS LicenseStatus,
				
			--	--(select top 1 EducationStatus from #tmpAll  where RowNumber >= 1 and SectionName='Educat' and Apno=A.Apno) AS EducationStatus,
			--	ISNULL((select top 1  EducationStatus   from #tmpAll  where RowNumber >= 1 and SectionName='Educat' and Apno=A.Apno and LicenseStatus!='Not Ordered'),'Not Ordered') as EducationStatus,
			--	--A.EmploymentStatus,
			----	(select top 1 EmploymentStatus from #tmpAll  where RowNumber >= 1 and SectionName='Empl' and Apno=A.Apno) AS EmploymentStatus,
			--	ISNULL((select top 1  EmploymentStatus   from #tmpAll  where RowNumber >= 1 and SectionName='Empl' and Apno=A.Apno and LicenseStatus!='Not Ordered'),'Not Ordered') as EmploymentStatus,
			--	
				ISNULL((select  top 1 CrimStatus   from #tmpAll c  where RowNumber >= 1   and SectionName='Crim' and c.Apno=A.Apno and CrimStatus='Pending'),isnull((select  top 1 CrimStatus   from #tmpAll c  where RowNumber >= 1   and SectionName='Crim' and c.Apno=A.Apno and CrimStatus<>'Pending') , 'Pending')) as criminalstatus,
				
			ISNULL((select top 1   SanctionCheckStatus   from #tmpAll  where RowNumber >= 1 and SectionName='SanctionCheck' and Apno=A.Apno and SanctionCheckStatus='Completed'),isnull((select  top 1 SanctionCheckStatus   from #tmpAll c  where RowNumber >= 1   and SectionName='SanctionCheck' and c.Apno=A.Apno and SanctionCheckStatus<>'Pending') , 'Pending')) AS SanctionCheckStatus,
			
				ISNULL((select  top 1  LicenseStatus   from #tmpAll  where RowNumber >=1 and SectionName='ProfLic' and Apno=A.Apno and LicenseStatus='Pending'),isnull((select  top 1 LicenseStatus   from #tmpAll c  where RowNumber >= 1   and SectionName='ProfLic' and c.Apno=A.Apno and LicenseStatus='Completed'),isnull((select  top 1 LicenseStatus   from #tmpAll c  where RowNumber >= 1 and SectionName='ProfLic' and Apno=A.Apno and LicenseStatus  not in ('Completed','Pending')),'Not ordered'))) AS LicenseStatus,
				
			
				ISNULL((select  top 1 EducationStatus   from #tmpAll c  where RowNumber >= 1 and SectionName='Educat' and Apno=A.Apno and EducationStatus='Attempted'),isnull((select  top 1 EducationStatus   from #tmpAll c  where RowNumber >= 1   and SectionName='Educat' and c.Apno=A.Apno and EducationStatus='Completed'),isnull((select  top 1 EducationStatus   from #tmpAll c  where RowNumber >= 1 and SectionName='Educat' and Apno=A.Apno and EducationStatus not in ('Completed','Attempted')),'Not ordered'))) as EducationStatus,
			
				ISNULL((select  top 1  EmploymentStatus   from #tmpAll c  where RowNumber >= 1 and SectionName='Empl' and Apno=A.Apno and EmploymentStatus='Attempted'),isnull((select  top 1 EmploymentStatus   from #tmpAll c  where RowNumber >= 1   and SectionName='Empl' and c.Apno=A.Apno and EmploymentStatus='Completed'),isnull((select  top 1 EmploymentStatus   from #tmpAll c  where RowNumber >= 1 and SectionName='Empl' and Apno=A.Apno and EmploymentStatus not  in ('Completed','Attempted')),'Not ordered'))) as EmploymentStatus,
			
			   A.SectStat,
				A.RowNumber
				-- * 
				FROM #tmpAll A 
                WHERE
				 A.RowNumber = 1 

			
                BEGIN
                                SELECT distinct A.CLNO AS [Client Number], 
                                                   C.Name AS [Client Name], 
                                                   ETA.APNO as [Report Number], 
                                                   A.First + ' ' + A.Last AS [Applicant Name] ,
												      A.ClientApplicantNO as TaleoCandidateId, 
                                                   P.PackageDesc AS [Package Ordered], 
                                                   A.DeptCode AS [Process Level],
												    f.facilityname as [Process Level Name ],
                                                   ETA.[ClientCertUpdated] AS [Report Start Date], 
												
                                                 
												   CASE when DATEDIFF(d,@ETAPASTTRIGGER,ETADate) < 0 then 'ETA Unavailable' else CONVERT(varchar, ETADate, 101) end as  [Current ETA Date],
                                               
                                                   [dbo].[ElapsedBusinessDays_2](ETA.[ClientCertUpdated],CURRENT_TIMESTAMP) AS [ Current Turnaround Time],
                                              
                                                   ETA.CrimStatus as CriminalStatus ,
                                                  ETA.SanctionCheckStatus as SanctionCheckStatus,
                                                  ETA.LicenseStatus as LicenseStatus, 
                                                  ETA.EducationStatus  as EducationStatus, 
                                                  ETA.Employmentstatus as EmploymentStatus--,
												--AffiliateID
                                FROM #tmpAllMaxETA AS ETA
                                INNER JOIN Appl AS A with(NOLOCK) ON ETA.APNO = A.APNO
                                LEFT OUTER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
                                LEFT OUTER JOIN PackageMain AS P with(NOLOCK) ON P.PackageID = A.PackageID
								LEFT OUTER JOIN [HEVN].DBO.Facility f with(NOLOCK) ON A.DeptCode = F.FacilityNum
                                WHERE A.ApStatus NOT IN ('F','M')
                                AND A.OrigCompDate IS NULL
                                  AND C.IsInactive = 0
								 AND f.ParentEmployerID IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) AND C.IsInactive = 0
								   -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
								 --and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
								 AND AffiliateID IN (4,294) --code added by Arindam for ticket# 84621 PART 3
                                  AND A.Clno IN (SELECT CLNO FROM Client with(NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO))
								  AND C.IsInactive = 0 
								    -- AND AffiliateID = IIF(@AffiliateID=0, AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
								--and (@AffiliateIDs IS NULL OR AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481) --code commented by Arindam for ticket# 84621 PART 3
								AND AffiliateID IN (4,294) --code added by Arindam for ticket# 84621 PART 3
))
								 
				 END
      

           drop table #tmpMainSet
 drop  table #tmpAll 
 
  drop table  #tmpAllMaxETA    
END


