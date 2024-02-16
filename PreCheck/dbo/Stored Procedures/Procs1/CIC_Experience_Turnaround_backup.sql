-- =============================================
-- Author:		Vairavan  A
-- Create date: 01/19/2023
-- Description: HCA Requires Data Pulled on CIC Use
--Ticket No - 68361 HCA Requires Data Pulled on CIC Use
--Parameters should be dates, and have optional CLNO (blank for all, separate multiple by colon) and Affiliate (blank for all, separate multiple by colon)
-- EXEC [dbo].[CIC_Experience_Turnaround_backup] '294:4','7519','01/01/2023','01/05/2023'
--
-- Modified date : 01/20/2023
-- Modified By : Jeff Simenc
-- Description : The @EndDate field was being used as DATEADD(d, 1, @EndDate) in the where clauses on line 65 and 131.  These are the only 2 uses for this variable, so 
--				 I changed the SP to set the @EndDate = DATEADD(d, 1, @EndDate) on line 24 and replaced DATEADD(d, 1, @EndDate) with @EndDate in the where clauses.
--				 The join condition on line 210 was REPLACE(a.SocialNumber,'-','') = REPLACE(R.SSN,'-','').  I moved the replace functions for both fields to the select
--				 select statements on lines 62 and 102 and changed the the join condition to a.SocialNumber = R.SSN.
--
-- =============================================

CREATE PROC dbo.CIC_Experience_Turnaround_backup
    @Affiliate VARCHAR(MAX) = '',
    @CLNO VARCHAR(MAX) = '',
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

	/*
	declare @Startdate datetime = '01/01/2023',
            @Enddate datetime   = '01/05/2023',
            @CLNO int = '',
			@Affiliate VARCHAR(MAX) = ''
	*/

    SET @EndDate = DATEADD(d, 1, @EndDate);


    IF @Affiliate = ''
    BEGIN
        SET @Affiliate = NULL;
    END;

    IF @CLNO = ''
    BEGIN
        SET @CLNO = NULL;
    END;


    DROP TABLE IF EXISTS #tmpDates;
    DROP TABLE IF EXISTS #tmp;
	Drop table If exists #temp;
    Drop table if exists #tmp_ApplicantStage;
	Drop table if exists #tmp_vwStageOrder;
	Drop table if exists #tmp_vwClient;


    CREATE TABLE #tmpDates
    (   ApplicantNumber	Varchar(20),
        [ReleaseFormID] [INT] NOT NULL,
        [SSN] [VARCHAR](15) NULL,
        [ReleaseDate] [DATETIME] NULL,
        [CLNO] [INT] NOT NULL
    );

    CREATE CLUSTERED INDEX IX_tmpDates_01
    ON #tmpDates (ReleaseFormID);
	

    ;
    WITH tmpReleaseDates
    AS (SELECT a.ApplicantNumber,
			   rf.ReleaseFormID,
               REPLACE(rf.ssn, '-', '') AS SSN,
               rf.[date],
               rf.CLNO,
               ROW_NUMBER() OVER (PARTITION BY rf.ssn ORDER BY rf.ReleaseFormID DESC) AS RowNumber
        FROM PRECHECK.dbo.ReleaseForm rf WITH (NOLOCK)
			 Inner join 
			 Enterprise.dbo.ApplicantDocument ad WITH(NOLOCK)
		on(rf.ReleaseFormID = ad.ReleaseFormId)
			 inner join
			  Enterprise.dbo.Applicant a WITH (NOLOCK)  
			  ON ad.ApplicantId = a.ApplicantId 
       --WHERE rf.[date] BETWEEN @StartDate AND @EndDate
		)
    INSERT INTO #tmpDates
    SELECT T.ApplicantNumber,
		   T.ReleaseFormID,
           T.SSN,
           T.[date],
           T.CLNO
    FROM tmpReleaseDates AS T WITH (NOLOCK)
    WHERE T.RowNumber = 1;

	
	
	Select StagingApplicantId,StagingOrderId,CreateDate,ApplicantNumber, 
	       FirstName,
		   LastName,
		   Email,SecurityTokenId,SocialNumber
	into #tmp_ApplicantStage
	From [Enterprise].[Staging].[ApplicantStage]  with(nolock)
	WHERE CreateDate BETWEEN @StartDate AND @EndDate

	Create Clustered index idx_tmp_ApplicantStage on #tmp_ApplicantStage(StagingOrderId)

	Select ClientId,IntegrationRequestId,OrderNumber,ord.FacilityId,StagingOrderId
	into #tmp_vwStageOrder
	from [Enterprise].[Staging].[vwStageOrder] ord with(nolock)
	WHERE (
				@CLNO IS NULL
				OR ClientId IN
					(
						SELECT value FROM fn_Split(@CLNO, ':')
					)
			)

	Create Clustered index idx_tmp_vwStageOrder on #tmp_vwStageOrder(IntegrationRequestId)
	Create nonClustered index idx_tmp_vwStageOrder1 on #tmp_vwStageOrder(FacilityId)	
	
	Select ClientId,AffiliateId
	into #tmp_vwClient
	from [Enterprise].[PreCheck].[vwClient]
	 WHERE
			  (
				  @Affiliate IS NULL
				  OR AffiliateId IN
					 (
						 SELECT value FROM fn_Split(@Affiliate, ':')
					 )
			  );

	 Create Clustered index idx_tmp_vwClient on #tmp_vwClient(ClientId)

	select FacilityCLNO,FacilityName,FacilityNum
	into #tmp_Facility
	from HEVN.dbo.Facility with(nolock)
	where FacilityCLNO in( select FacilityId from #tmp_vwStageOrder)

	    Create Clustered index idx_tmp_Facility on #tmp_Facility(FacilityCLNO)

    SELECT app.StagingApplicantId,
           app.CreateDate AS app_createdate,
           app.ApplicantNumber,
           client.AffiliateId,
             cast(NUll as nvarchar(100)) as AffiliateName,
         --  aff.Affiliate AS AffiliateName,
           ord.ClientId,
		    Fac.FacilityCLNO  AS [Facility CLNO],
            Fac.FacilityName   AS [Facility Name],
            Fac.FacilityNum    AS [Facility Number],
				ord.IntegrationRequestId,
			app.StagingOrderId,
			Cast(NULL as Varchar(500)) AS [RequisitionNumber],
            --/*Fac.FacilityCLNO*/ cast(NULL as int) AS [Facility CLNO],--cast(NULL as int)
            --/*Fac.FacilityName*/ cast(NULL as varchar(100)) AS [Facility Name],--cast(NULL as varchar(100))
            --/*Fac.FacilityNum*/  cast(NULL as varchar(10))  AS [Facility Number],--cast(NULL as varchar(10)) 
          -- ([PRECHECK].[dbo].[GetIntegrationRequestNodeValue](ord.IntegrationRequestId, NULL, 'RequisitionNumber')) AS [RequisitionNumber],
           ord.OrderNumber [Order Number],
           app.FirstName [First Name],
           app.LastName [Last Name],
           app.Email,
           CAST(NULL AS VARCHAR(100)) AS [Consent/Application Status],
           app.CreateDate AS [App Create Date],
           CAST(NULL AS DATETIME) AS [Candidate Start Date],
           CAST(NULL AS DATETIME) AS [Review Create Date],
           CAST(NULL AS DATETIME) AS [Additional Info Requested Date],
           NULL AS [CandidatePortionCompleted(Mins)],
           NULL AS [Client Portion Completed (Mins)],
           app.SecurityTokenId,
           ord.FacilityId,
           REPLACE(app.SocialNumber, '-', '') AS SocialNumber,
           CAST(NULL AS INT) AS RRA_ReviewRequestID,
           CAST(NULL AS INT) AS RRA_ReviewStatusId,
           CAST(NULL AS DATETIME) AS RRA_CreateDate,
           CAST(NULL AS BIT) AS Tok_IsAccessGranted,
           CAST(NULL AS UNIQUEIDENTIFIER) AS Tok_TokenId,
           CAST(NULL AS INT) AS Rev_StagingApplicantId,
           CAST(NULL AS BIT) AS Rev_IsComplete,
           CAST(NULL AS INT) AS Rev_ClosingReviewStatusId,
           CAST(NULL AS UNIQUEIDENTIFIER) AS Tok2_TokenId,
           CAST(NULL AS DATETIME) AS Tok2_ExpireDate,
           CAST(NULL AS DATETIME) AS R_ReleaseDate,
           CAST(NULL AS DATETIME) AS ClientCertUpdated,
           CAST(NULL AS INT) AS RR_StagingApplicantid
    INTO #tmp
     FROM #tmp_ApplicantStage app WITH (NOLOCK)
        INNER JOIN #tmp_vwStageOrder ord WITH (NOLOCK)
            ON ord.StagingOrderId = app.StagingOrderId
        INNER JOIN #tmp_vwClient client WITH (NOLOCK)
            ON client.ClientId = ord.FacilityId
        INNER JOIN [PRECHECK].[dbo].[Integration_OrderMgmt_Request] integ WITH (NOLOCK)
            ON integ.RequestID = ord.IntegrationRequestId
        INNER JOIN #tmp_Facility Fac WITH (NOLOCK)
            ON Fac.FacilityCLNO = ord.FacilityId 
			--AND client.ClientId = fac.EmployerID
		--INNER JOIN refAffiliate aff with(nolock)
		--    on (client.AffiliateId = aff.AffiliateId)

			
	Update a 
	SET  a.AffiliateName    = aff.Affiliate
	FROM #tmp a 
		INNER JOIN refAffiliate aff with(nolock)
		    on (a.AffiliateId = aff.AffiliateId)

Declare @NodeName varchar(500) = 'RequisitionNumber'

select  cast(transformedrequest.query('//*[local-name()=sql:variable("@NodeName")]') AS nvarchar(max)) as node,RequestID,
        cast(NULL as varchar(100)) as RequisitionNumber
into #Integration_OrderMgmt_Request
FROM Integration_OrderMgmt_Request with(nolock)
where  RequestID in(select IntegrationRequestId from #tmp)

Update #Integration_OrderMgmt_Request
set RequisitionNumber = replace(replace(node,'<RequisitionNumber>',''),'</RequisitionNumber>','')

Update a 
set a.RequisitionNumber = ord.RequisitionNumber
from #tmp a 
		inner join 
		#Integration_OrderMgmt_Request ord WITH (NOLOCK)
ON ord.RequestID = a.IntegrationRequestId

    UPDATE a
    SET a.[Review Create Date] = rev.CreateDate,
        a.Rev_StagingApplicantId = rev.StagingApplicantId,
        a.Rev_IsComplete = rev.IsComplete,
        a.Rev_ClosingReviewStatusId = rev.ClosingReviewStatusId
    FROM #tmp a
        OUTER APPLY
    (
        SELECT TOP 1
               rev.*
        FROM [Enterprise].[Staging].[ReviewRequest] rev WITH (NOLOCK)
        WHERE rev.StagingApplicantId = a.StagingApplicantId
        ORDER BY rev.CreateDate DESC
    ) rev;

    UPDATE a
    SET a.[Candidate Start Date] = tok.CreateDate,
        a.Tok_IsAccessGranted = tok.IsAccessGranted,
        a.Tok_TokenId = tok.TokenId
    FROM #tmp a
        OUTER APPLY
    (
        SELECT TOP 1
               tok.*
        FROM [SecureBridge].[dbo].[TokenActivity] tok WITH (NOLOCK)
        WHERE tok.TokenId = a.SecurityTokenId
        ORDER BY tok.CreateDate DESC
    ) tok;

    UPDATE a
    SET a.Tok2_ExpireDate = tok2.ExpireDate,
        a.Tok2_TokenId = tok2.TokenId
    FROM #tmp a
        OUTER APPLY
    (
        SELECT TOP 1
               token.*
        FROM [SecureBridge].[dbo].[Token] token WITH (NOLOCK)
        WHERE token.TokenId = a.SecurityTokenId
        ORDER BY token.CreateDate DESC
    ) tok2;

    UPDATE a
    SET a.RR_StagingApplicantid = RR.StagingApplicantId
    FROM #tmp a
        LEFT OUTER JOIN Enterprise.Staging.ReviewRequest RR WITH (NOLOCK)
            ON RR.StagingApplicantId = a.StagingApplicantId;

    UPDATE a
    SET a.RRA_ReviewRequestID = RRA.ReviewRequestId,
        a.RRA_ReviewStatusId = RRA.ReviewStatusId,
        a.RRA_CreateDate = RRA.CreateDate
    FROM #tmp a
        LEFT OUTER JOIN Enterprise.Staging.ReviewRequest RR WITH (NOLOCK)
            ON RR.StagingApplicantId = a.StagingApplicantId
        LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA WITH (NOLOCK)
  ON RR.ReviewRequestId = RRA.ReviewRequestId
               AND RRA.ReviewStatusId = RR.ClosingReviewStatusId;

    UPDATE a
    SET a.R_ReleaseDate = R.ReleaseDate,
        a.ClientCertUpdated = cc.ClientCertUpdated
    FROM #tmp a
        LEFT OUTER JOIN PRECHECK.dbo.ClientCertification AS cc (NOLOCK)
            ON cc.APNO = a.ApplicantNumber
        LEFT OUTER JOIN #tmpDates AS R
            ON  r.ApplicantNumber = cc.APNO and
			    a.SocialNumber = R.SSN  --REPLACE(a.SocialNumber,'-','') = REPLACE(R.SSN,'-','')
               AND a.FacilityId = R.CLNO;

    UPDATE a
    SET a.[Additional Info Requested Date] = CASE
                                                 WHEN a.RRA_ReviewStatusId = 2 THEN
                                                     a.RRA_CreateDate
                                                 ELSE
                                                     CAST(NULL AS DATETIME)
                                             END
    FROM #tmp a;

    UPDATE a
    SET a.[CandidatePortionCompleted(Mins)] = DATEDIFF(MINUTE, a.[Candidate Start Date], a.[Review Create Date])
    FROM #tmp a;


    UPDATE a
    SET a.[Client Portion Completed (Mins)] = DATEDIFF(MINUTE, a.R_ReleaseDate, a.ClientCertUpdated)
    FROM #tmp a;
	--select * from #tmp where [CandidatePortionCompleted(Mins)]<0

    UPDATE a
    SET a.[Consent/Application Status] = CASE
                                             WHEN a.Tok_TokenId IS NULL THEN
                                                 'Not Started'
                                             WHEN
                                             (
                                                 a.Tok_IsAccessGranted = 1
                                                 AND a.RR_StagingApplicantid IS NULL
                                                 AND a.ApplicantNumber IS NULL
                                             ) THEN
                                                 'In Progress'
                                             WHEN a.Rev_ClosingReviewStatusId = 2
                                                  AND a.ApplicantNumber IS NULL
                                                  AND
                                                  (
                                                      a.Rev_IsComplete <> 1
                                                      AND a.Rev_ClosingReviewStatusId <> 4
                                                  ) THEN
                                                 'Awaiting Additional Info'
                                             WHEN a.Rev_IsComplete = 1
                                                  AND a.Rev_ClosingReviewStatusId = 4
                                                  AND a.ApplicantNumber IS NOT NULL THEN
                                                 'Completed'
                                             WHEN a.Tok2_TokenId IS NOT NULL
                                                  AND a.ApplicantNumber IS NULL
                                                  AND CAST(a.Tok2_ExpireDate AS DATE) < CAST(GETDATE() AS DATE) THEN
                                                 'Expired'
                                             ELSE
                                                 NULL
                                         END
    FROM #tmp a;


 


    SELECT a.AffiliateID,
           a.AffiliateName,
           a.ClientId AS ClientCLNO,
           a.[Facility CLNO],
           a.[Facility Name],
           a.[Facility Number],
           a.RequisitionNumber,
           a.[Order Number],
           a.[First Name],
           a.[Last Name],
           a.Email,
           a.[Consent/Application Status],
           a.[App Create Date],
           a.[Candidate Start Date],
           a.[Review Create Date],
           b.min_Additional_info_requested_date AS [Additional Info Requested Date],
           a.[CandidatePortionCompleted(Mins)],
           a.[Client Portion Completed (Mins)] into #temp
    FROM #tmp a
        INNER JOIN
        (
            SELECT StagingApplicantId,
                   ApplicantNumber AS apno,
                   MIN([Additional Info Requested Date]) AS min_Additional_info_requested_date
            FROM #tmp
            GROUP BY StagingApplicantId,
                     ApplicantNumber
        ) b
            ON (
                   ISNULL(a.StagingApplicantId, '') = ISNULL(b.StagingApplicantId, '')
                   AND ISNULL(a.ApplicantNumber, '') = ISNULL(b.apno, '')
                   AND ISNULL(a.[Additional Info Requested Date], '') = ISNULL(b.min_Additional_info_requested_date, '')
               )
			   where   datediff(minute, [Candidate Start Date], [Review Create Date])>= 0
    ORDER BY a.app_createdate DESC

	Select distinct * from #temp;

    SET NOCOUNT OFF;
END;

