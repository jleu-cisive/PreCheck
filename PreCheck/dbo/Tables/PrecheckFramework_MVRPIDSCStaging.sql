CREATE TABLE [dbo].[PrecheckFramework_MVRPIDSCStaging] (
    [MVRPIDSCStagingId] INT           IDENTITY (19325, 1) NOT NULL,
    [FolderId]          VARCHAR (100) NULL,
    [APNO]              INT           NULL,
    [Type]              VARCHAR (30)  NULL,
    [SectStat]          CHAR (1)      NULL,
    [Web_Status]        INT           NULL,
    [Report]            VARCHAR (MAX) NULL,
    [CreatedDate]       DATETIME      NULL,
    [IsHidden]          BIT           DEFAULT ((0)) NULL
) ON [FG_STAGEDATA] TEXTIMAGE_ON [FG_STAGEDATA];


GO
CREATE NONCLUSTERED INDEX [IX_PrecheckFramework_MVRPIDSCStaging_FolderId_APNO_Type_CreatedDate]
    ON [dbo].[PrecheckFramework_MVRPIDSCStaging]([FolderId] ASC, [APNO] ASC, [Type] ASC, [CreatedDate] ASC)
    INCLUDE([SectStat], [Report], [IsHidden])
    ON [FG_STAGEDATA];

