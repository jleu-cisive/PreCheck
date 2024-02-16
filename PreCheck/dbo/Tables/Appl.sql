CREATE TABLE [dbo].[Appl] (
    [APNO]                    INT           IDENTITY (167110, 1) NOT NULL,
    [ApStatus]                CHAR (1)      CONSTRAINT [DF_Appl_ApStatus] DEFAULT ('P') NOT NULL,
    [UserID]                  VARCHAR (8)   NULL,
    [Billed]                  BIT           CONSTRAINT [DF_Appl_Billed] DEFAULT (0) NOT NULL,
    [Investigator]            VARCHAR (8)   NULL,
    [EnteredBy]               VARCHAR (8)   NULL,
    [EnteredVia]              VARCHAR (8)   NULL,
    [ApDate]                  DATETIME      NULL,
    [CompDate]                DATETIME      NULL,
    [CLNO]                    SMALLINT      NOT NULL,
    [Attn]                    VARCHAR (100) NULL,
    [Last]                    VARCHAR (50)  NOT NULL,
    [First]                   VARCHAR (50)  NOT NULL,
    [Middle]                  VARCHAR (50)  NULL,
    [Alias]                   VARCHAR (30)  NULL,
    [Alias2]                  VARCHAR (30)  NULL,
    [Alias3]                  VARCHAR (30)  NULL,
    [Alias4]                  VARCHAR (30)  NULL,
    [SSN]                     VARCHAR (11)  NULL,
    [DOB]                     DATETIME      NULL,
    [Sex]                     VARCHAR (1)   NULL,
    [DL_State]                VARCHAR (2)   NULL,
    [DL_Number]               VARCHAR (20)  NULL,
    [Addr_Num]                VARCHAR (6)   NULL,
    [Addr_Dir]                VARCHAR (2)   NULL,
    [Addr_Street]             VARCHAR (100) NULL,
    [Addr_StType]             VARCHAR (2)   NULL,
    [Addr_Apt]                VARCHAR (5)   NULL,
    [City]                    VARCHAR (50)  NULL,
    [State]                   VARCHAR (2)   NULL,
    [Zip]                     VARCHAR (5)   NULL,
    [Pos_Sought]              VARCHAR (100) NULL,
    [Update_Billing]          BIT           CONSTRAINT [DF_Appl_Update_Billing] DEFAULT (0) NOT NULL,
    [Priv_Notes]              VARCHAR (MAX) NULL,
    [Pub_Notes]               VARCHAR (MAX) NULL,
    [PC_Time_Stamp]           DATETIME      CONSTRAINT [DF_Appl_PC_Time_Stamp] DEFAULT (getdate()) NULL,
    [Pc_Time_Out]             DATETIME      NULL,
    [Special_instructions]    VARCHAR (MAX) NULL,
    [Reason]                  CHAR (20)     NULL,
    [ReopenDate]              DATETIME      NULL,
    [OrigCompDate]            DATETIME      NULL,
    [Generation]              VARCHAR (3)   NULL,
    [Alias1_Last]             VARCHAR (50)  NULL,
    [Alias1_First]            VARCHAR (50)  NULL,
    [Alias1_Middle]           VARCHAR (50)  NULL,
    [Alias1_Generation]       VARCHAR (3)   NULL,
    [Alias2_Last]             VARCHAR (50)  NULL,
    [Alias2_First]            VARCHAR (50)  NULL,
    [Alias2_Middle]           VARCHAR (50)  NULL,
    [Alias2_Generation]       VARCHAR (3)   NULL,
    [Alias3_Last]             VARCHAR (50)  NULL,
    [Alias3_First]            VARCHAR (50)  NULL,
    [Alias3_Middle]           VARCHAR (50)  NULL,
    [Alias3_Generation]       VARCHAR (3)   NULL,
    [Alias4_Last]             VARCHAR (50)  NULL,
    [Alias4_First]            VARCHAR (50)  NULL,
    [Alias4_Middle]           VARCHAR (50)  NULL,
    [Alias4_Generation]       VARCHAR (3)   NULL,
    [PrecheckChallenge]       BIT           CONSTRAINT [DF_Appl_PrecheckChallenge] DEFAULT (0) NULL,
    [InUse]                   VARCHAR (8)   NULL,
    [ClientAPNO]              VARCHAR (50)  NULL,
    [ClientApplicantNO]       VARCHAR (50)  NULL,
    [Last_Updated]            DATETIME      CONSTRAINT [DF_Appl_Last_Updated] DEFAULT (getdate()) NULL,
    [DeptCode]                VARCHAR (20)  NULL,
    [NeedsReview]             VARCHAR (2)   NULL,
    [StartDate]               DATETIME      NULL,
    [RecruiterID]             INT           NULL,
    [Phone]                   VARCHAR (50)  NULL,
    [Rush]                    BIT           CONSTRAINT [DF_Appl_Rush] DEFAULT (0) NULL,
    [IsAutoPrinted]           BIT           CONSTRAINT [DF_Appl_AutoPrinted] DEFAULT (0) NOT NULL,
    [AutoPrintedDate]         DATETIME      NULL,
    [IsAutoSent]              BIT           CONSTRAINT [DF_Appl_IsAutoSent] DEFAULT (0) NOT NULL,
    [AutoSentDate]            DATETIME      NULL,
    [PackageID]               SMALLINT      NULL,
    [Rel_Attached]            BIT           NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_Appl_CreatedDate] DEFAULT (getdate()) NULL,
    [ClientProgramID]         INT           NULL,
    [I94]                     VARCHAR (50)  NULL,
    [Recruiter_Email]         VARCHAR (50)  NULL,
    [CAM]                     VARCHAR (8)   NULL,
    [SubStatusID]             INT           NULL,
    [GetNextDate]             DATETIME      NULL,
    [Email]                   VARCHAR (100) NULL,
    [CellPhone]               VARCHAR (20)  NULL,
    [OtherPhone]              VARCHAR (20)  NULL,
    [IsDrugTestFileFound_bit] BIT           CONSTRAINT [DF_Appl_IsDrugTestFileFound] DEFAULT ((0)) NOT NULL,
    [IsDrugTestFileFound]     INT           DEFAULT ((2)) NOT NULL,
    [FreeReport]              BIT           NULL,
    [ClientNotes]             VARCHAR (MAX) NULL,
    [InProgressReviewed]      BIT           NULL,
    [LastModifiedDate]        DATETIME      NULL,
    [LastModifiedBy]          VARCHAR (20)  NULL,
    [EvaluationDate]          DATETIME      NULL,
    [refAppEvalStatusId]      INT           NULL,
    CONSTRAINT [PK_Appl] PRIMARY KEY CLUSTERED ([APNO] ASC) WITH (FILLFACTOR = 90, PAD_INDEX = ON, DATA_COMPRESSION = PAGE ON PARTITIONS (3), DATA_COMPRESSION = PAGE ON PARTITIONS (4), DATA_COMPRESSION = PAGE ON PARTITIONS (5), DATA_COMPRESSION = PAGE ON PARTITIONS (1), DATA_COMPRESSION = PAGE ON PARTITIONS (2), DATA_COMPRESSION = PAGE ON PARTITIONS (6), DATA_COMPRESSION = PAGE ON PARTITIONS (7), DATA_COMPRESSION = PAGE ON PARTITIONS (8), DATA_COMPRESSION = PAGE ON PARTITIONS (9), DATA_COMPRESSION = PAGE ON PARTITIONS (10), DATA_COMPRESSION = PAGE ON PARTITIONS (11), DATA_COMPRESSION = PAGE ON PARTITIONS (12), DATA_COMPRESSION = PAGE ON PARTITIONS (13), DATA_COMPRESSION = PAGE ON PARTITIONS (14), DATA_COMPRESSION = PAGE ON PARTITIONS (15)) ON [PS_APPL] ([APNO])
) ON [PS_APPL] ([APNO]);


GO
ALTER TABLE [dbo].[Appl] SET (LOCK_ESCALATION = AUTO);


GO
CREATE NONCLUSTERED INDEX [IX_ApDate]
    ON [dbo].[Appl]([ApDate] ASC, [APNO] ASC)
    INCLUDE([CLNO], [PrecheckChallenge]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_CLNO]
    ON [dbo].[Appl]([CLNO] ASC, [ApStatus] ASC, [SSN] ASC, [Last] ASC, [InUse] ASC, [CompDate] ASC, [IsAutoPrinted] ASC, [AutoSentDate] ASC, [Last_Updated] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_CLNO_CLPrgID]
    ON [dbo].[Appl]([APNO] ASC, [CLNO] ASC, [ApStatus] ASC, [InUse] ASC, [ClientProgramID] ASC)
    INCLUDE([First], [Last], [SSN], [CreatedDate], [ApDate], [IsDrugTestFileFound]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_EnteredBy]
    ON [dbo].[Appl]([EnteredBy] ASC, [ApStatus] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_InUse]
    ON [dbo].[Appl]([InUse] ASC, [NeedsReview] ASC, [ApStatus] ASC, [APNO] ASC, [CLNO] ASC, [Investigator] ASC, [Rush] ASC)
    INCLUDE([SSN], [DOB]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_Inuse_AutoPrintSent]
    ON [dbo].[Appl]([APNO] ASC, [InUse] ASC, [IsAutoPrinted] ASC, [IsAutoSent] ASC, [ApStatus] ASC)
    INCLUDE([CLNO], [IsDrugTestFileFound]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_Investigator]
    ON [dbo].[Appl]([Investigator] ASC, [ApStatus] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_Name]
    ON [dbo].[Appl]([Last] ASC, [First] ASC, [Middle] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_SSN]
    ON [dbo].[Appl]([SSN] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_UserID]
    ON [dbo].[Appl]([UserID] ASC, [ApStatus] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_ApStatus]
    ON [dbo].[Appl]([ApStatus] ASC, [APNO] ASC, [ApDate] ASC, [CreatedDate] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_First]
    ON [dbo].[Appl]([First] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [Reports]
    ON [dbo].[Appl]([CompDate] ASC, [CLNO] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Appl_Apstatus_CLNO]
    ON [dbo].[Appl]([ApStatus] ASC, [CLNO] ASC, [OrigCompDate] ASC, [APNO] ASC)
    INCLUDE([UserID], [ApDate], [Last], [First], [CompDate], [ReopenDate]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Appl_CLNO_CreatedDate]
    ON [dbo].[Appl]([CLNO] ASC, [CreatedDate] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_ApStatus_InUse]
    ON [dbo].[Appl]([ApStatus] ASC, [InUse] ASC)
    INCLUDE([APNO], [SSN], [NeedsReview]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_Apstatus_DLState_inc]
    ON [dbo].[Appl]([ApStatus] ASC, [DL_State] ASC)
    INCLUDE([APNO], [ApDate]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_SSN_Inc]
    ON [dbo].[Appl]([SSN] ASC)
    INCLUDE([APNO], [ApDate], [CLNO]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_CLNO_ApDate_CompDate_Inc]
    ON [dbo].[Appl]([CLNO] ASC, [ApDate] ASC, [CompDate] ASC)
    INCLUDE([APNO], [Last], [First], [Middle], [SSN]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_I94_Inc]
    ON [dbo].[Appl]([I94] ASC, [DOB] ASC)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_OrigCompDate]
    ON [dbo].[Appl]([OrigCompDate] ASC)
    INCLUDE([APNO], [EnteredVia], [CLNO], [PackageID])
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_ApStatus_InUse_RR]
    ON [dbo].[Appl]([InUse] ASC, [ApStatus] ASC, [UserID] ASC)
    INCLUDE([APNO], [Investigator], [CLNO], [CAM])
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [CLNO_ClientAPNO_Includes]
    ON [dbo].[Appl]([CLNO] ASC, [ClientAPNO] ASC)
    INCLUDE([APNO], [ApDate], [CompDate], [Last], [First], [Middle], [SSN], [DOB], [Last_Updated]) WITH (FILLFACTOR = 100)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [UserID_CompDate_Includes]
    ON [dbo].[Appl]([UserID] ASC, [CompDate] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Appl_CLNO_OirgCompDate]
    ON [dbo].[Appl]([CLNO] ASC, [OrigCompDate] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Appl_AppStatus_CLNO_OriginalCompDate]
    ON [dbo].[Appl]([ApStatus] ASC, [CLNO] ASC, [OrigCompDate] ASC)
    INCLUDE([APNO], [UserID], [ApDate], [CompDate], [Last], [First], [Pos_Sought]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Appl_ApStatus_Includes]
    ON [dbo].[Appl]([ApStatus] ASC)
    INCLUDE([APNO], [ApDate], [DL_State], [UserID], [Investigator], [EnteredVia], [CLNO], [Last], [First], [ReopenDate], [OrigCompDate], [PackageID], [InProgressReviewed]) WITH (FILLFACTOR = 90)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_AppStatus_UserID]
    ON [dbo].[Appl]([ApStatus] ASC, [UserID] ASC)
    INCLUDE([APNO], [Investigator], [ApDate], [CLNO], [Last], [First], [Middle], [ReopenDate])
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_CLNO_InUse]
    ON [dbo].[Appl]([CLNO] ASC, [InUse] ASC)
    INCLUDE([APNO], [UserID], [Last], [First], [Middle], [SSN], [DOB], [City])
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Appl_InUse_Includes]
    ON [dbo].[Appl]([InUse] ASC)
    INCLUDE([APNO], [UserID], [CLNO], [Last], [First], [Middle], [SSN], [DOB], [City], [State], [Zip])
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Appl_EnteredVia_ApDate_CLNO]
    ON [dbo].[Appl]([EnteredVia] ASC, [ApDate] ASC, [CLNO] ASC)
    ON [PS_APPL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_DOB]
    ON [dbo].[Appl]([DOB] ASC)
    INCLUDE([APNO])
    ON [FG_INDEX];


GO

-- =============================================
-- edited by:		Santosh CHapyala
-- Create date: 5/5/2013
-- Description:	updated to handle batch updates
-- =============================================

-- =============================================
-- edited by:		kiran miryala
-- Create date: 8/22/2012
-- Description:	based on balaji's feedback changed the trigger
-- =============================================

--ALTER TRIGGER [dbo].[Status_Update] on [dbo].[Appl]
--for update
--as
--	 --UPDATE A SET  A.pc_time_out = CURRENT_TIMESTAMP
--	 --FROM dbo.appl A INNER JOIN INSERTED I 
--	 --ON A.apno = I.apno
--	 --INNER JOIN DELETED D
--	 --ON I.apno = D.apno
--	 --WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'')

--	 ----Send a callback acknowledgement only if the status changes from OnHold to InProgress
--	 --UPDATE IOR SET  IOR.Process_Callback_Acknowledge = 1 , IOR.Callback_Acknowledge_Date = NULL
--	 --FROM dbo.Integration_OrderMgmt_Request IOR INNER JOIN INSERTED I 
--	 --ON IOR.apno = I.apno
--	 --INNER JOIN DELETED D
--	 --ON I.apno = D.apno
--	 --WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'') AND I.apstatus = 'P' AND D.apstatus = 'M'

----cchaupin 5/28/08 changed to handle multiple records
--if (Select Count(*) FROM inserted) > 1
--RETURN;
--/* COMMENTED AND MADE CHANGES BELOW -SChapyala 10/21/2011
--if update(apstatus) AND (select isnull(apstatus,-1) from inserted) <> (select isnull(apstatus,-1) from deleted)
-- update appl set
-- pc_time_out = getdate()
-- where  apno = (select apno from inserted)

--COMMENTED AND MADE CHANGES BELOW -SChapyala 10/21/2011 */

----Declare @InsertedApStatus varchar(1),@APNO int,@DeletedApStatus varchar(1)

----select @InsertedApStatus =  isnull(apstatus,''), @APNO = apno from inserted

----Select @DeletedApStatus = isnull(apstatus,'') from deleted

----if update(apstatus) AND (@InsertedApStatus) <> (@DeletedApStatus)
----	begin
----	 update appl set
----	 pc_time_out = getdate()
----	 where  apno = @APNO

----	 IF( @InsertedApStatus = 'P' and @DeletedApStatus = 'M')	--Send a callback acknowledgement only if the status changes from OnHold to InProgress	
----		update Integration_OrderMgmt_Request
----		set   Process_Callback_Acknowledge = 1,
----			  Callback_Acknowledge_Date = null 
----		where apno =  @APNO
----	end
----- Updated on 8/22/2012
----if update(apstatus) 
----	BEGIN
--	 UPDATE A SET  A.pc_time_out = CURRENT_TIMESTAMP, 
--	 A.ApDate = Case When  (I.apstatus = 'P' AND D.apstatus = 'M') Then CURRENT_TIMESTAMP Else A.ApDate End  --Added by schapyala on 06/05/13 - Onhold to InProgress should reset apdate for TAT measurement purposes
--	 FROM dbo.appl A INNER JOIN INSERTED I 
--	 ON A.apno = I.apno
--	 INNER JOIN DELETED D
--	 ON I.apno = D.apno
--	 WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'')


--	 UPDATE IOR SET  IOR.Process_Callback_Acknowledge = 1 , IOR.Callback_Acknowledge_Date = NULL
--	 FROM dbo.Integration_OrderMgmt_Request IOR INNER JOIN INSERTED I 
--	 ON IOR.apno = I.apno
--	 INNER JOIN DELETED D
--	 ON I.apno = D.apno
--	 WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'') AND I.apstatus = 'P' AND D.apstatus = 'M'

--	--END


	
--set ANSI_NULLS ON
--set QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[Status_Update] on [dbo].[Appl]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON;

 IF update(apstatus)
	 UPDATE A SET  A.pc_time_out = CURRENT_TIMESTAMP,
	  A.Apdate = (case when (A.apstatus = 'P' AND D.apstatus = 'M') then current_timestamp else A.Apdate end) -- added by schapyala on 09/05/2013 to reset apdate 
	 FROM dbo.appl A 
	 --INNER JOIN INSERTED I 
	 --ON A.apno = I.apno
	 INNER JOIN DELETED D
	 ON A.apno = D.apno
	 WHERE 	ISNULL(A.apstatus,'') <> ISNULL(D.apstatus,'')


END;
	 
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON








GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[Appl_Log_update] on [dbo].[Appl]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON;
 DECLARE @HostName  varchar(100), @ClientAddress  varchar(100),@LoginName  varchar(100), @ProgramName  varchar(150)
 
 SELECT @HostName = 	SES.host_name 
	  ,@ClientAddress = CON.client_net_address 
	  ,@LoginName = SES.login_name 
	  ,@ProgramName = SES.program_name 
    FROM sys.dm_exec_connections AS CON
         INNER JOIN sys.dm_exec_sessions as SES
             ON CON.session_id = SES.session_id
		WHERE CON.session_id = @@spid	 

IF update(	apstatus)
BEGIN
	

	
 
	 INSERT INTO dbo.Appl_StatusLog 
	 SELECT I.APNO
			,@HostName 
			,@LoginName 
			,@ClientAddress 
			,@ProgramName 
			,D.apstatus	AS Prev_Apstatus
			,I.apstatus	AS Curr_Apstatus
			,Current_Timestamp
	FROM
	INSERTED I 
	 INNER JOIN DELETED D
	 ON I.apno = D.apno
	 WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'') --AND I.apstatus = 'P' AND D.apstatus = 'F'



	 

END

IF update(DOB)
BEGIN
	 --DECLARE @HostName  varchar(100), @ClientAddress  varchar(100),@LoginName  varchar(100), @ProgramName  varchar(150)

	--SELECT @HostName = 	SES.host_name 
	--  ,@ClientAddress = CON.client_net_address 
	--  ,@LoginName = SES.login_name 
	--  ,@ProgramName = SES.program_name 
 --   FROM sys.dm_exec_connections AS CON
 --        INNER JOIN sys.dm_exec_sessions as SES
 --            ON CON.session_id = SES.session_id
	--	WHERE CON.session_id = @@spid	 

 
	-- INSERT INTO dbo.Appl_StatusLog 
	-- SELECT I.APNO
	--		,@HostName 
	--		,@LoginName 
	--		,@ClientAddress 
	--		,@ProgramName 
	--		,D.apstatus	AS Prev_Apstatus
	--		,I.apstatus	AS Curr_Apstatus
	--		,Current_Timestamp
	--FROM
	--INSERTED I 
	-- INNER JOIN DELETED D
	-- ON I.apno = D.apno
	-- WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'') --AND I.apstatus = 'P' AND D.apstatus = 'F'



	  INSERT INTO dbo.Appl_StatusLog 
	 SELECT I.APNO
			,@HostName 
			,@LoginName 
			,@ClientAddress 
			,@ProgramName 
			,'X'	AS Prev_Apstatus
			,'Z'	AS Curr_Apstatus
			,Current_Timestamp
	FROM
	INSERTED I 
	 INNER JOIN DELETED D
	 ON I.apno = D.apno
	 WHERE  ISNULL(I.DOB,'') <> ISNULL(D.DOB,'') and 
	 CONVERT(varchar(50),I.DOB,101) = '01/01/1900'

END
END;
	 
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON








GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[Appl_ProcessCallback_update] on [dbo].[Appl]
FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF update(	apstatus)
	 UPDATE IOR SET  IOR.Process_Callback_Acknowledge = 1 , IOR.Callback_Acknowledge_Date = NULL
	 FROM dbo.Integration_OrderMgmt_Request IOR INNER JOIN INSERTED I 
	 ON IOR.apno = I.apno
	 INNER JOIN DELETED D
	 ON I.apno = D.apno
	 WHERE 	ISNULL(I.apstatus,'') <> ISNULL(D.apstatus,'') AND I.apstatus = 'P' AND D.apstatus = 'M'

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'so MDAnderson nevers gets NULL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Appl', @level2type = N'COLUMN', @level2name = N'Last_Updated';

