/******************************************************************          
-- Created By :  Yashan Sharma          
-- Created Date: 20-June-2022      
-- Ref   : Overdue_status_report_HCA_Lifecycle    
-- Requirement  : Include New parameters in Report HDT #49333          
-- Exec Overdue_status_report_HCA_Lifecycle_WithPara 0,0,4,'2022-04-01','2022-04-30' 

ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	11/16/2022		72018		#72018  include both affiliate 4 (HCA) & 294 (HCA Velocity). 
											EXEC dbo.[Overdue_status_report_HCA_Lifecycle_WithPara] 0,0,0,'11/01/2022',
-----------------------------------------------------------------------------
-- Modified By :  Vairavan A           
-- Modified Date: 20-March-2023
-- Ticket No   : 87031
-- Requirement :  Modify Existing QR: HCA LifeCycle Report With Parameters
*******************************************************************/
CREATE PROCEDURE [dbo].[Overdue_status_report_HCA_Lifecycle_WithPara]
(
    @For_HCA_Inspire BIT = 0,
    @CLNo INT = 0,
    @AffilateID INT = 4, --- Currently Not in use will open when require in future   
    @StatDate DATETIME = NULL,
    @EndDate DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @HCA_InModel BIT;
    DECLARE @includeCompletedReports BIT;
    DECLARE @MergeCompletedReports BIT;

    ---------------------------------------    
    DECLARE @tStartDate DATETIME,
            @tEndDate DATETIME,
            @LocalCLNO INT,
            @LocalFor_HCA_Inspire BIT,
			@LocalAffiliateID INT
    SET @tStartDate = ISNULL(@StatDate, '1900-01-01');
    SET @tEndDate = ISNULL(@EndDate, GETDATE());
    ---------------------------------------         

    SET @HCA_InModel = 1;
    SET @includeCompletedReports = 1;
    SET @MergeCompletedReports = 1;
    SET @LocalCLNO = @CLNo;
    SET @LocalFor_HCA_Inspire = @For_HCA_Inspire;
	SET @LocalAffiliateID = @AffilateID



    CREATE TABLE #tempPendingPercentages
    (
        [CAM] VARCHAR(8),
        [Report Number] INT,
        [Client ID] INT,
        [Client Name] VARCHAR(100),
        [Recruiter Name] VARCHAR(100),
        [Reopened] VARCHAR(20),
        [Admitted] VARCHAR(10),
        [InProgressReviewed] VARCHAR(20),
        [Percentage Completed] INT,
        [BusinessDaysInThisPercentage] VARCHAR(10),
        [Report TAT] INT
    );

    INSERT INTO #tempPendingPercentages
    EXEC [PendingReportsWithPercentages_ByCAM] NULL;


    CREATE TABLE #tmpHCAOverDue
    (
        [Report Number] INT,
        [Report Created Date] DATETIME,
        [Report Status] VARCHAR(10),
        [Applicant Last Name] VARCHAR(100),
        [Applicant First Name] VARCHAR(100),
        [Applicant Middle Name] VARCHAR(50),
        [SSN] VARCHAR(11),
        JobTitle VARCHAR(200), --Code added by Shashank for ticket id -87031
        [Report Reopened Date] DATETIME,
        [Report Completion Date] DATETIME,
        ProcessLevel VARCHAR(50),
        Requisition VARCHAR(50),
        StartDate VARCHAR(12),
        [Account Name] VARCHAR(250),
        [Elapsed Days] INT,
        [Report TAT] INT,
        [Admitted Crim] VARCHAR(10),
        [Criminal Searches Ordered] INT,
        [Criminal Searches Pending] INT,
        [MVR Ordered] INT,
        [MVR Pending] INT,
        [Employment Verifications Ordered] INT,
        [Employment Verifications Pending] INT,
        [Education Verifications Ordered] INT,
        [Education Verifications Pending] INT,
        [License Verifications Ordered] INT,
        [License Verifications Pending] INT,
        [Personal References Ordered] INT,
        [Personal References Pending] INT,
        [SanctionCheck Ordered] INT,
        [SanctionCheck Pending] INT,
        [Percentage Completed] INT
    );
    INSERT INTO #tmpHCAOverDue
    SELECT A.APNO,
           A.ApDate,
           CASE
               WHEN A.ApStatus = 'P' THEN
                   'InProgress'
               ELSE
                   'Available'
           END,
           REPLACE(A.Last, ',', ''),
           REPLACE(A.First, ',', ''),
           REPLACE(A.Middle, ',', ''),
           CASE
               WHEN @LocalFor_HCA_Inspire = 1 THEN
                   SSN
               ELSE
                   RIGHT(SSN, 4)
           END,
           NULL AS JobTitle,     --OJ.JobTitle,    
           A.ReopenDate,
           A.CompDate,
           REPLACE(ISNULL(DeptCode, 0), ',', ' '),
           REPLACE(
                      ISNULL(
                                TransformedRequest.value(
                                                            '(/Application/NewApplicant/RequisitionNumber)[1]',
                                                            'varchar(50)'
                                                        ),
                                ''
                            ),
                      ',',
                      ''
                  ),
           NULL AS JobStartDate, --CAST(JobStartDate AS VARCHAR(12)),
           REPLACE(C.Name, ',', ''),
           CONVERT(NUMERIC(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())),
           tp.[Report TAT],      --Added By Humera Ahmed on 9/22/2021 for HDT#19093 to Add 2 columns - Report TAT and Admitted Crim          
           CASE
               WHEN tp.Admitted = 0 THEN
                   'No'
               ELSE
                   'Yes'
           END AS [Admitted Crim],
           (
               SELECT COUNT(1)
               FROM dbo.Crim WITH (NOLOCK)
               WHERE (
                         Crim.APNO = A.APNO
                         AND IsHidden = 0
                     )
           ),                    --[Criminal Searches Ordered]          
           (
               SELECT COUNT(1)
               FROM dbo.Crim WITH (NOLOCK)
               WHERE (
                         Crim.APNO = A.APNO
                         AND IsHidden = 0
                     )
                     AND (ISNULL(Crim.Clear, '') NOT IN ( 'T', 'F' ))
           ),                    --[Criminal Searches Pending]              
           (
               SELECT COUNT(1)
               FROM dbo.DL WITH (NOLOCK)
               WHERE (
                         DL.APNO = A.APNO
                         AND IsHidden = 0
                     )
           ),                    --[MVR Ordered]          
           (
               SELECT COUNT(1)
               FROM dbo.DL WITH (NOLOCK)
               WHERE (
                         DL.APNO = A.APNO
                         AND IsHidden = 0
                     )
                     AND
                     (
                         DL.SectStat = '9'
                         OR DL.SectStat = '0'
                     )
           ),                    --[MVR Pending]          
           (
               SELECT COUNT(1)
               FROM dbo.Empl WITH (NOLOCK)
               WHERE (Empl.Apno = A.APNO)
                     AND Empl.IsOnReport = 1
           ),                    --[Employment Verifications Ordered]          
           (
               SELECT COUNT(1)
               FROM dbo.Empl WITH (NOLOCK)
               WHERE (Empl.Apno = A.APNO)
                     AND Empl.IsOnReport = 1
                     AND
                     (
                         Empl.SectStat = '9'
                         OR Empl.SectStat = '0'
                     )
           ),                    --[Employment Verifications Pending]          
           (
               SELECT COUNT(1)
               FROM dbo.Educat WITH (NOLOCK)
               WHERE (Educat.APNO = A.APNO)
                     AND Educat.IsOnReport = 1
           ),                    --AS [Education Verifications Ordered]          
           (
               SELECT COUNT(1)
               FROM dbo.Educat WITH (NOLOCK)
               WHERE (Educat.APNO = A.APNO)
                     AND Educat.IsOnReport = 1
                     AND
                     (
                         Educat.SectStat = '9'
                         OR Educat.SectStat = '0'
                     )
           ),                    --AS [Education Verifications Pending]          
           (
               SELECT COUNT(1)
               FROM dbo.ProfLic WITH (NOLOCK)
               WHERE (ProfLic.Apno = A.APNO)
                     AND ProfLic.IsOnReport = 1
           ),                    -- AS [License Verifications Ordered],          
           (
               SELECT COUNT(1)
               FROM dbo.ProfLic WITH (NOLOCK)
               WHERE (ProfLic.Apno = A.APNO)
                     AND ProfLic.IsOnReport = 1
                     AND
                     (
                         ProfLic.SectStat = '9'
                         OR ProfLic.SectStat = '0'
                     )
           ),                    -- AS [License Verifications Pending],          
           (
               SELECT COUNT(1)
               FROM dbo.PersRef WITH (NOLOCK)
               WHERE (PersRef.APNO = A.APNO)
                     AND PersRef.IsOnReport = 1
           ),                    -- AS [Personal References Ordered],          
           (
               SELECT COUNT(1)
               FROM dbo.PersRef WITH (NOLOCK)
               WHERE (PersRef.APNO = A.APNO)
                     AND PersRef.IsOnReport = 1
                     AND
                     (
                         PersRef.SectStat = '9'
                         OR PersRef.SectStat = '0'
                     )
           ),                    --AS  [Personal References Pending],          
           (
               SELECT COUNT(1)
               FROM dbo.MedInteg WITH (NOLOCK)
               WHERE (
                         MedInteg.APNO = A.APNO
                         AND IsHidden = 0
                     )
           ),                    -- AS [SanctionCheck Ordered],          
           (
               SELECT COUNT(1)
               FROM dbo.MedInteg WITH (NOLOCK)
               WHERE (
                         MedInteg.APNO = A.APNO
                         AND IsHidden = 0
                     )
                     AND
                     (
                         MedInteg.SectStat = '9'
                         OR MedInteg.SectStat = '0'
                     )
           ),                    --AS [SanctionCheck Pending]          
           (CASE
                WHEN tp.[Percentage Completed] = 100 THEN
                    99
                ELSE
                    tp.[Percentage Completed]
            END
           ) AS [Percentage Completed]
    FROM dbo.Appl A WITH (NOLOCK)
        INNER JOIN dbo.Client C WITH (NOLOCK)
            ON A.CLNO = C.CLNO
        LEFT JOIN dbo.Integration_OrderMgmt_Request R (NOLOCK)
            ON A.APNO = R.APNO
        --LEFT JOIN Enterprise.[dbo].[Order] O (NOLOCK)
        --  ON A.APNO = OrderNumber
        -- LEFT outer JOIN Enterprise.[dbo].[OrderJobDetail] OJ (NOLOCK)
        --ON O.[OrderId] = OJ.OrderId
        LEFT JOIN HEVN.dbo.Facility F (NOLOCK)
            ON ISNULL(TransformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'), '') = FacilityNum
               AND ParentEmployerID = 7519
               AND ISNULL(IsOneHR, 0) = @HCA_InModel
        INNER JOIN #tempPendingPercentages tp
            ON A.APNO = tp.[Report Number]
    WHERE
        --c.AffiliateID = 4		--Code commenetd by Shashank for ticket id -72018
        C.AffiliateID IN ( 4, 294 ) --Code added by Shashank for ticket id -72018
        --C.AffiliateID=Case WHen @AffilateID=4 Then 4 Else C.AffiliateID END    --------//Ysharma TKT 493333    
        AND C.CLNO = CASE
                         WHEN @LocalCLNO = 0 THEN
                             C.CLNO
                         ELSE
                             @LocalCLNO
                     END
        AND A.ApDate
        BETWEEN @tStartDate AND DATEADD(DAY, 1, @tEndDate) --------\\    
        AND (A.ApStatus IN ( 'P', 'W' ))
        AND
        (
            A.ApStatus = 'P'
            AND OrigCompDate IS NULL
        )
		

    SELECT aad.APNO,
           CASE
               WHEN SUM(ISNULL(CAST(aad.Crim_SelfDisclosed AS INT), 0)) = 0 THEN
                   'No'
               ELSE
                   'Yes'
           END AS [Admitted Crim]
    INTO #AdmittedCrim_CompletedReports
    FROM Appl a (NOLOCK)
        INNER JOIN dbo.Client c
            ON a.CLNO = c.CLNO
        INNER JOIN dbo.ApplAdditionalData aad (NOLOCK)
            ON a.APNO = aad.APNO
    WHERE
        --c.AffiliateID = 4		--Code commenetd by Shashank for ticket id -72018
        c.AffiliateID IN ( 4, 294 ) --Code added by Shashank for ticket id -72018
        AND a.ApDate
        BETWEEN @tStartDate AND DATEADD(DAY, 1, @tEndDate)
        --C.AffiliateID=Case WHen @AffilateID=4 Then 4 Else C.AffiliateID END    --------//Ysharma TKT 493333    
        AND c.CLNO = CASE
                         WHEN @LocalCLNO = 0 THEN
                             c.CLNO
                         ELSE
                             @LocalCLNO
                     END --------\\    
        AND
        (
            (a.ApStatus = 'F')
            OR
            (
                a.ApStatus = 'P'
                AND OrigCompDate IS NOT NULL
            )
        )
        AND ISNULL(a.CompDate, '1/1/1900') > CASE
                                                 WHEN @LocalFor_HCA_Inspire = 0 THEN
                                                     '7/1/2021'
                                                 ELSE
                                                     DATEADD(m, -1, CURRENT_TIMESTAMP)
                                             END
    GROUP BY aad.APNO
	

    IF @includeCompletedReports = 1
        INSERT INTO #tmpHCAOverDue
        SELECT A.APNO,
               A.ApDate,
               CASE
                   WHEN A.ApStatus = 'F' THEN
                       'Completed'
                   ELSE
                       'ReOpened'
               END,
               REPLACE(A.Last, ',', ''),
               REPLACE(A.First, ',', ''),
               REPLACE(A.Middle, ',', ''),
               CASE
                   WHEN @LocalFor_HCA_Inspire = 1 THEN
                       SSN
                   ELSE
                       RIGHT(SSN, 4)
               END,
               NULL AS JobTitle,     --OJ.JobTitle, --Code added by Shashank for ticket id -87031
               A.ReopenDate,
               A.CompDate,
               REPLACE(ISNULL(DeptCode, 0), ',', ' '),
               REPLACE(
                          ISNULL(
                                    TransformedRequest.value(
                                                                '(/Application/NewApplicant/RequisitionNumber)[1]',
                                                                'varchar(50)'
                                                            ),
                                    ''
                                ),
                          ',',
                          ''
                      ),
               NULL AS JobStartDate, --CAST(JobStartDate AS VARCHAR(12)),
               REPLACE(C.Name, ',', ''),
               CONVERT(NUMERIC(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())),
               dbo.ElapsedBusinessDays_2(A.ApDate, A.OrigCompDate) AS [Report TAT],
               accr.[Admitted Crim] AS [Admitted Crim],
               (
                   SELECT COUNT(1)
                   FROM dbo.Crim WITH (NOLOCK)
                   WHERE (
                             Crim.APNO = A.APNO
                             AND IsHidden = 0
                         )
               ),                    --[Criminal Searches Ordered]          
               0,                    --[Criminal Searches Pending]          
               (
                   SELECT COUNT(1)
                   FROM dbo.DL WITH (NOLOCK)
                   WHERE (
                             DL.APNO = A.APNO
                             AND IsHidden = 0
                         )
               ),                    --[MVR Ordered]          
               0,                    --[MVR Pending]          
               (
                   SELECT COUNT(1)
                   FROM dbo.Empl WITH (NOLOCK)
                   WHERE (Empl.Apno = A.APNO)
                         AND Empl.IsOnReport = 1
               ),                    --[Employment Verifications Ordered]          
               0,                    --[Employment Verifications Pending]          
               (
                   SELECT COUNT(1)
                   FROM dbo.Educat WITH (NOLOCK)
                   WHERE (Educat.APNO = A.APNO)
                         AND Educat.IsOnReport = 1
               ),                    --AS [Education Verifications Ordered]          
               0,                    --AS [Education Verifications Pending]          
               (
                   SELECT COUNT(1)
                   FROM dbo.ProfLic WITH (NOLOCK)
                   WHERE (ProfLic.Apno = A.APNO)
                         AND ProfLic.IsOnReport = 1
               ),                    -- AS [License Verifications Ordered],          
               0,                    -- AS [License Verifications Pending],          
               (
                   SELECT COUNT(1)
                   FROM dbo.PersRef WITH (NOLOCK)
                   WHERE (PersRef.APNO = A.APNO)
                         AND PersRef.IsOnReport = 1
               ),                    -- AS [Personal References Ordered],          
               0,                    --AS  [Personal References Pending],          
               (
                   SELECT COUNT(1)
                   FROM dbo.MedInteg WITH (NOLOCK)
                   WHERE (
                             MedInteg.APNO = A.APNO
                             AND IsHidden = 0
                         )
               ),                    -- AS [SanctionCheck Ordered],          
               0,                    --AS [SanctionCheck Pending],          
               (CASE
                    WHEN ISNULL(tp.[Percentage Completed], 100) = 100
                         AND A.ApStatus <> 'F' THEN
                        99
                    ELSE
                        ISNULL(tp.[Percentage Completed], 100)
                END
               ) AS [Percentage Completed]
        FROM dbo.Appl A WITH (NOLOCK)
            INNER JOIN dbo.Client C WITH (NOLOCK)
                ON A.CLNO = C.CLNO
            LEFT JOIN dbo.Integration_OrderMgmt_Request R (NOLOCK)
                ON A.APNO = R.APNO
            --LEFT JOIN Enterprise.[dbo].[Order] O (NOLOCK)
            --ON A.APNO = OrderNumber
            --LEFT outer JOIN Enterprise.[dbo].[OrderJobDetail] OJ (NOLOCK)
            --ON O.[OrderId] = OJ.OrderId
            LEFT JOIN HEVN.dbo.Facility F (NOLOCK)
                ON ISNULL(TransformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'), '') = FacilityNum
                   AND ParentEmployerID = 7519
                   AND ISNULL(IsOneHR, 0) = @HCA_InModel
            LEFT JOIN #tempPendingPercentages tp
                ON A.APNO = tp.[Report Number]
            INNER JOIN #AdmittedCrim_CompletedReports accr
                ON A.APNO = accr.APNO
        WHERE
            --C.AffiliateID = 4		--Code commenetd by Shashank for ticket id -72018
            C.AffiliateID IN ( 4, 294 ) --Code added by Shashank for ticket id -72018   
            AND A.ApDate
            BETWEEN @tStartDate AND DATEADD(DAY, 1, @tEndDate)
            --C.AffiliateID=Case WHen @AffilateID=4 Then 4 Else C.AffiliateID END --------//Ysharma TKT 493333    
            AND C.CLNO = CASE
                             WHEN @LocalCLNO = 0 THEN
                                 C.CLNO
                             ELSE
                                 @LocalCLNO
                         END --------\\    
            AND
            (
                (A.ApStatus = 'F')
                OR
                (
                    A.ApStatus = 'P'
                    AND OrigCompDate IS NOT NULL
                )
            ) --and A.ApDate >= DateAdd(d,-90,current_TimeStamp)          
            --and DateDiff(dd,cast(a.compdate  as Date),cast(Current_timeStamp as Date))<=3          
            AND ISNULL(A.CompDate, '1/1/1900') > CASE
                                                     WHEN @LocalFor_HCA_Inspire = 0 THEN
                                                         '7/1/2021'
                                                     ELSE
                                                         DATEADD(m, -1, CURRENT_TIMESTAMP)
                                                 END
												 

    --TBF Logic           
    CREATE TABLE #tmpAppl
    (
        Apno INT
    );

    INSERT INTO #tmpAppl
    SELECT A.APNO
    FROM dbo.Appl A WITH (NOLOCK)
        INNER JOIN dbo.Client C
            ON A.CLNO = C.CLNO
        LEFT JOIN dbo.Crim WITH (NOLOCK)
            ON Crim.APNO = A.APNO
               AND Crim.IsHidden = 0
               AND
               (
                   Crim.Clear IS NULL
                   OR Crim.Clear IN ( 'R', 'M', 'O', 'V', 'I', 'W', 'Z', 'D' )
               )
        LEFT JOIN dbo.Civil WITH (NOLOCK)
            ON Civil.APNO = A.APNO
               AND
               (
                   (Civil.Clear IS NULL)
                   OR (Civil.Clear = 'O')
               )
        LEFT JOIN dbo.Credit WITH (NOLOCK)
            ON (Credit.APNO = A.APNO)
               AND
               (
                   Credit.SectStat = '0'
                   OR Credit.SectStat = '9'
               )
        LEFT JOIN dbo.DL WITH (NOLOCK)
            ON (DL.APNO = A.APNO)
               AND
               (
                   DL.SectStat = '0'
                   OR DL.SectStat = '9'
               )
        LEFT JOIN dbo.Empl WITH (NOLOCK)
            ON (Empl.Apno = A.APNO)
               AND Empl.IsOnReport = 1
               AND
               (
                   Empl.SectStat = '0'
                   OR Empl.SectStat = '9'
               )
        LEFT JOIN dbo.Educat WITH (NOLOCK)
            ON (Educat.APNO = A.APNO)
               AND Educat.IsOnReport = 1
               AND
               (
                   Educat.SectStat = '0'
                   OR Educat.SectStat = '9'
               )
        LEFT JOIN dbo.ProfLic WITH (NOLOCK)
            ON (ProfLic.Apno = A.APNO)
               AND ProfLic.IsOnReport = 1
               AND
               (
                   ProfLic.SectStat = '0'
                   OR ProfLic.SectStat = '9'
               )
        LEFT JOIN dbo.PersRef WITH (NOLOCK)
            ON (PersRef.APNO = A.APNO)
               AND PersRef.IsOnReport = 1
               AND
               (
                   PersRef.SectStat = '0'
                   OR PersRef.SectStat = '9'
               )
        LEFT JOIN dbo.MedInteg WITH (NOLOCK)
            ON (MedInteg.APNO = A.APNO)
               AND
               (
                   MedInteg.SectStat = '0'
                   OR MedInteg.SectStat = '9'
               )
    WHERE (A.ApStatus IN ( 'P', 'W' ))
          AND ISNULL(A.Investigator, '') <> ''
          AND A.UserID IS NOT NULL
          --AND ISNULL(A.CAM, '') = ''          
          AND ISNULL(C.ClientTypeID, -1) <> 15
          AND Crim.CrimID IS NULL
          AND Civil.CivilID IS NULL
          AND Credit.APNO IS NULL
          AND DL.APNO IS NULL
          AND Empl.EmplID IS NULL
          AND Educat.EducatID IS NULL
          AND ProfLic.ProfLicID IS NULL
          AND PersRef.PersRefID IS NULL
          AND MedInteg.APNO IS NULL
    ORDER BY A.ApDate;

    --End TBF Temp          
    SELECT DISTINCT
           [Report Number]
    INTO #ReportsTemp
    FROM #tmpHCAOverDue;

    SELECT rt.[Report Number],
           oj.JobTitle,
           oj.JobStartDate
    INTO #JobInfo
    FROM #ReportsTemp rt
        INNER JOIN Enterprise.dbo.[Order] o
            ON o.OrderNumber = rt.[Report Number]
        INNER JOIN Enterprise.dbo.OrderJobDetail oj
            ON oj.OrderId = o.OrderId;

    UPDATE hod
    SET hod.JobTitle = ji.JobTitle,
        hod.StartDate = ji.JobStartDate
    FROM #tmpHCAOverDue hod
        LEFT OUTER JOIN #JobInfo ji
            ON ji.[Report Number] = hod.[Report Number];

    IF @MergeCompletedReports = 1
        SELECT DISTINCT
               *,
               [Contingent Decision Status] = CASE
                                                  WHEN [Criminal Searches Pending] = 0
                                                       AND [License Verifications Pending] = 0
                                                       AND [SanctionCheck Pending] = 0 THEN
                                                      'Review'
                                                  ELSE
                                                      'Pending'
                                              END,
               [Pending Closure <24hrs] = CASE
                                              WHEN EXISTS
    (
        SELECT TOP 1 1 FROM #tmpAppl t WHERE t.Apno = Qry.[Report Number]
    )          THEN
                                                  'True'
                                              ELSE
                                                  'False'
                                          END,
               [Report Conclusion ETA] =
               (
                   SELECT CASE
                              WHEN CAST(CURRENT_TIMESTAMP AS DATE) <= MAX(ETADate) THEN
                                  MAX(ETADate)
                              ELSE
                                  NULL
                          END
                   FROM dbo.ApplSectionsETA ETA
                   GROUP BY ETA.Apno
                   HAVING ETA.Apno = Qry.[Report Number]
               ),
               ResultsURL = 'https://weborder.precheck.net/ClientAccess/webclient.aspx?Apno='
                            + CAST([Report Number] AS VARCHAR) + '&Clno=7519'
        FROM
        (
            SELECT *
            FROM #tmpHCAOverDue
        --where [Report Created Date] Between ISNULL(@StatDate,'1/1/1900') and ISNULL(@EndDate,GETDATE())         
        --   [Report Status] in ('InProgress','Available')            
        --   UNION ALL          
        --   select  * from #tmpHCAOverDue where           
        --   [Report Status] in ('Completed','ReOpened') --and DateDiff(dd,cast([Report Completion Date]  as Date),cast(Current_timeStamp as Date))<=3          
        ) QRY
        ORDER BY [Elapsed Days] DESC;

    ELSE
    BEGIN
        --Client wants to include all in progress regardless of the non pending components          

        SELECT DISTINCT
               'OverDue' FileType,
               *
        FROM #tmpHCAOverDue
        WHERE --[Report Number] not in (Select [Report Number] from #temp2) and           
            [Report Status] IN ( 'InProgress', 'Available' )
        ORDER BY [Elapsed Days] DESC;

        IF @includeCompletedReports = 1
            SELECT DISTINCT
                   'Completed' FileType,
                   *
            FROM #tmpHCAOverDue
            WHERE [Report Status] IN ( 'Completed', 'ReOpened' )
            ORDER BY [Report Created Date] DESC
			 

    END;


    DROP TABLE IF EXISTS #tmpAppl;
    DROP TABLE IF EXISTS #tmpHCAOverDue;
    DROP TABLE IF EXISTS #tempPendingPercentages;
    DROP TABLE IF EXISTS #AdmittedCrim_CompletedReports;
    DROP TABLE IF EXISTS #JobInfo;
    DROP TABLE IF EXISTS #ReportsTemp;

END;
