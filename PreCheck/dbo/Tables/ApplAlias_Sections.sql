CREATE TABLE [dbo].[ApplAlias_Sections] (
    [ApplAlias_SectionID] INT           IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]       INT           NOT NULL,
    [SectionKeyID]        INT           NOT NULL,
    [ApplAliasID]         INT           NOT NULL,
    [IsActive]            BIT           CONSTRAINT [DF_ApplAlias_Sections_Active_Default] DEFAULT ((1)) NOT NULL,
    [CreateDate]          DATETIME      CONSTRAINT [DF_ApplAlias_Sections_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           VARCHAR (50)  NULL,
    [LastUpdateDate]      DATETIME      CONSTRAINT [DF_ApplAlias_Sections_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]       NVARCHAR (50) NULL,
    CONSTRAINT [PK_ApplAlias_SectionID] PRIMARY KEY CLUSTERED ([ApplAlias_SectionID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ApplAlias_Sections_ApplAlias] FOREIGN KEY ([ApplAliasID]) REFERENCES [dbo].[ApplAlias] ([ApplAliasID]),
    CONSTRAINT [FK_ApplAlias_Sections_ApplSections] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplAlias_Sections_ApplSectionID_IsActive_inc]
    ON [dbo].[ApplAlias_Sections]([ApplSectionID] ASC, [SectionKeyID] ASC, [IsActive] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAlias_Sections_SectionKeyID]
    ON [dbo].[ApplAlias_Sections]([SectionKeyID] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [ApplAliasID_Includes]
    ON [dbo].[ApplAlias_Sections]([ApplAliasID] ASC)
    INCLUDE([SectionKeyID]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAlias_Sections_ApplSectionID_IsActive_CreatedBy]
    ON [dbo].[ApplAlias_Sections]([ApplSectionID] ASC, [IsActive] ASC, [CreatedBy] ASC)
    INCLUDE([SectionKeyID])
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_ApplAlias_Sections_Isactive]
    ON [dbo].[ApplAlias_Sections]([IsActive] ASC)
    INCLUDE([SectionKeyID], [ApplAliasID]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_AppAlias_Sec_AppSectionID_IsActive]
    ON [dbo].[ApplAlias_Sections]([ApplSectionID] ASC, [IsActive] ASC)
    INCLUDE([SectionKeyID], [ApplAliasID]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];

