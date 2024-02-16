CREATE TABLE [dbo].[PreCheckZipCrimComponentMap] (
    [APNO]            INT           NOT NULL,
    [ApplSectionID]   INT           NOT NULL,
    [SectionUniqueID] INT           NOT NULL,
    [ExternalType]    VARCHAR (20)  NOT NULL,
    [ExternalID]      VARCHAR (50)  NOT NULL,
    [IsSent]          BIT           CONSTRAINT [DF_PreCheckZipCrimComponentMap_IsSent] DEFAULT ((0)) NOT NULL,
    [SendDate]        DATETIME2 (3) NULL,
    [SendAttempts]    INT           CONSTRAINT [DF_PreCheckZipCrimComponentMap_SendAttempts] DEFAULT ((0)) NOT NULL,
    [IsActive]        BIT           CONSTRAINT [DF_PreCheckZipCrimComponentMap_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]      DATETIME2 (3) CONSTRAINT [DF_PreCheckZipCrimComponentMap_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF_PreCheckZipCrimComponentMap_CreatedBy] DEFAULT (app_name()) NOT NULL,
    [ModifyDate]      DATETIME2 (3) NULL,
    [ModifiedBy]      VARCHAR (100) NULL,
    [ETASentDate]     DATETIME2 (7) NULL,
    [SendResult]      BIT           NULL,
    [ResendResult]    BIT           DEFAULT ((0)) NOT NULL,
    [IsCancelled]     BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PreCheckZipCrimComponentMap] PRIMARY KEY CLUSTERED ([APNO] ASC, [ApplSectionID] ASC, [SectionUniqueID] ASC, [ExternalType] ASC, [ExternalID] ASC),
    CONSTRAINT [FK_PreCheckZipCrimComponentMap_Appl_APNO] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_PreCheckZipCrimComponentMap_ApplSections_ApplSectionID] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);


GO
CREATE NONCLUSTERED INDEX [idx_ComponentMap_APNO]
    ON [dbo].[PreCheckZipCrimComponentMap]([APNO] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ComponentMap_SectionUniqueID]
    ON [dbo].[PreCheckZipCrimComponentMap]([SectionUniqueID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PreCheckZipCrimComponentMap_IsActive_SendAttempts_Inc]
    ON [dbo].[PreCheckZipCrimComponentMap]([IsActive] ASC, [SendAttempts] ASC)
    INCLUDE([APNO], [ApplSectionID], [SectionUniqueID], [ExternalType], [ExternalID]);


GO
CREATE NONCLUSTERED INDEX [IX_PreCheckZipCrimComponentMap_ApplSectionID_SendDate_IsActive_SendAttempts]
    ON [dbo].[PreCheckZipCrimComponentMap]([ApplSectionID] ASC, [SendDate] ASC, [IsActive] ASC, [SendAttempts] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PreCheckZipCrimComponentMap_ModifyDate]
    ON [dbo].[PreCheckZipCrimComponentMap]([ModifyDate] ASC)
    INCLUDE([IsSent], [SendDate], [IsActive], [ModifiedBy], [ResendResult]);


GO
CREATE NONCLUSTERED INDEX [IX_PreCheckZipCrimComponentMap_IsSent_IsActive_ETASentDate_SendAttemps]
    ON [dbo].[PreCheckZipCrimComponentMap]([IsSent] ASC, [IsActive] ASC, [ETASentDate] ASC, [SendAttempts] ASC)
    INCLUDE([APNO], [ApplSectionID], [SectionUniqueID]);

