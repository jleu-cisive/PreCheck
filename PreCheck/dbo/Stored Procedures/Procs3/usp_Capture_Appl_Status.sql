CREATE PROCEDURE [dbo].[usp_Capture_Appl_Status]
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @LogID int
	DECLARE @CommitDatetime datetime
	DECLARE @CurrentDatetime datetime

	SELECT @CurrentDatetime  = DATEADD(MINUTE,-1,CURRENT_TIMESTAMP)
	SELECT @CurrentDatetime =  dateadd(millisecond, -datepart(millisecond, @CurrentDatetime  ), @CurrentDatetime  ) ;

	--SELECT @CommitDatetime = dateadd(millisecond, datediff(millisecond, 0, [LastSyncDate]), 0) FROM [dbo].[Sync_Config] WHERE TableName = 'Appl_CT_TRG'
	SELECT @CommitDatetime =  [LastSyncDate] FROM [dbo].[Sync_Config] WHERE TableName = 'Appl_CT_TRG'
	
	SELECT @LogID  = ChangelogID FROM dbo.CDCChangelog WHERE DATABASEName = 'Precheck' AND TableName = 'Appl' AND ColumnName = 'ApStatus'

	INSERT INTO dbo.CDCChangelogDetail
	(ChangeLogId	,
	KeyColumnValue	,
	OldValue	,
	NewValue	,
	[ChangeDate]	,
	[ChangedBy]	)	
	SELECT distinct
	@LogID , 
	APNO, 
	Old_ApStatus, 
	New_ApStatus, 
	dateadd(millisecond, -datepart(millisecond, CommitDateTime), CommitDateTime) AS CommitDateTime,
	LastModifiedBy
	FROM [CTCFG].[vwAppl_ApStatus] 
	WHERE Old_ApStatus = 'P' AND New_ApStatus = 'F'
	AND CommitDateTime >= @CommitDatetime;
	
	UPDATE O SET 
		O.DAOrderServiceStatusId = (SELECT DynamicAttributeId FROM Enterprise.dbo.DynamicAttribute WHERE ShortName=A.New_ApStatus AND DynamicAttributeTypeId =12)
		,O.ModifyDate = A.CommitDateTime
		,O.ModifyBy = 0
		FROM Enterprise.dbo.[OrderService] O
		INNER JOIN [CTCFG].[vwAppl_ApStatus] A
		ON O.OrderServiceNumber = A.APNO
	 AND o.BusinessServiceId=1 
	 WHERE A.New_ApStatus <> A.Old_ApStatus
	 AND CommitDateTime >= @CommitDatetime;
	 
	UPDATE O SET 
		O.DAOrderServiceStatusId = (SELECT DynamicAttributeId FROM Enterprise.dbo.DynamicAttribute WHERE ShortName=A.New_ApStatus AND DynamicAttributeTypeId =12)
		,O.ModifyDate = A.CommitDateTime
		,O.ModifyBy = 0
		FROM  [CTCFG].[vwAppl_ApStatus] A
	 INNER JOIN dbo.OCHS_CandidateInfo OC
	 ON ISNULL(OC.APNO,-1) = A.APNO			
	 INNER JOIN Enterprise.dbo.[OrderService] O
	 ON O.OrderServiceNumber = OC.OCHS_CandidateInfoID
	 AND o.BusinessServiceId=2
	 WHERE A.New_ApStatus <> A.Old_ApStatus
	 AND CommitDateTime >= @CommitDatetime;
	
	UPDATE [dbo].[Sync_Config] SET[LastSyncDate] =  @CurrentDatetime WHERE TableName = 'Appl_CT_TRG'
END;


