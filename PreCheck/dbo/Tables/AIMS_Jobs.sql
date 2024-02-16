CREATE TABLE [dbo].[AIMS_Jobs] (
    [AIMS_JobID]           INT            IDENTITY (1, 1) NOT NULL,
    [Section]              VARCHAR (10)   NOT NULL,
    [SectionKeyId]         VARCHAR (50)   NOT NULL,
    [AIMS_JobStatus]       VARCHAR (1)    CONSTRAINT [DF_Table_2_Status] DEFAULT ('Q') NOT NULL,
    [CreatedDate]          DATETIME       CONSTRAINT [DF_AIMS_Jobs_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [JobStart]             DATETIME       NULL,
    [JobEnd]               DATETIME       NULL,
    [RetryCount]           INT            CONSTRAINT [DF_AIMS_Jobs_RetryCount] DEFAULT ((0)) NULL,
    [IsPriority]           BIT            CONSTRAINT [DF_AIMS_Jobs_IsPriority] DEFAULT ((0)) NOT NULL,
    [DataXtract_LoggingId] INT            NULL,
    [AgentStatus]          VARCHAR (1000) NULL,
    [Last_Updated]         DATETIME       NULL,
    [VendorAccountId]      INT            CONSTRAINT [DF_AIMS_Jobs_VendorAccountId] DEFAULT ((5)) NULL,
    CONSTRAINT [PK_AIMS_Jobs] PRIMARY KEY CLUSTERED ([AIMS_JobID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_AIMS_Jobs_DataXtract_Logging] FOREIGN KEY ([DataXtract_LoggingId]) REFERENCES [dbo].[DataXtract_Logging] ([DataXtract_LoggingId]),
    CONSTRAINT [FK_AIMS_Jobs_refAIMS_JobStatus] FOREIGN KEY ([AIMS_JobStatus]) REFERENCES [dbo].[refAIMS_JobStatus] ([AIMS_JobStatus])
);


GO
ALTER TABLE [dbo].[AIMS_Jobs] NOCHECK CONSTRAINT [FK_AIMS_Jobs_DataXtract_Logging];


GO
CREATE NONCLUSTERED INDEX [IDX_AIMS_Jobs-Section_SectionKeyID_vendor_Jobstatus]
    ON [dbo].[AIMS_Jobs]([Section] ASC, [SectionKeyId] ASC, [VendorAccountId] ASC, [AIMS_JobStatus] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_AIMS_Jobs_JobStatus]
    ON [dbo].[AIMS_Jobs]([AIMS_JobStatus] ASC)
    INCLUDE([AIMS_JobID], [Section], [SectionKeyId], [IsPriority], [VendorAccountId]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [Section_SectionKeyId_VendorAccountId_Includes]
    ON [dbo].[AIMS_Jobs]([Section] ASC, [SectionKeyId] ASC, [VendorAccountId] ASC)
    INCLUDE([AIMS_JobStatus], [JobStart]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_AIMS_Jobs_DataXtract_LoggingID]
    ON [dbo].[AIMS_Jobs]([DataXtract_LoggingId] ASC)
    INCLUDE([AIMS_JobStatus]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_AIMS_Jobs_VendorAccountId]
    ON [dbo].[AIMS_Jobs]([VendorAccountId] ASC)
    INCLUDE([AIMS_JobID], [Section], [SectionKeyId], [AIMS_JobStatus], [CreatedDate], [JobStart], [JobEnd], [RetryCount], [DataXtract_LoggingId], [AgentStatus], [Last_Updated]);

