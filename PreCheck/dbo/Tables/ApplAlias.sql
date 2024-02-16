CREATE TABLE [dbo].[ApplAlias] (
    [ApplAliasID]             INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                    INT          NULL,
    [First]                   VARCHAR (50) NULL,
    [Middle]                  VARCHAR (50) NULL,
    [Last]                    VARCHAR (50) NULL,
    [IsMaiden]                BIT          NULL,
    [CreatedDate]             DATETIME     CONSTRAINT [DF_ApplAlias_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [Generation]              VARCHAR (15) DEFAULT (NULL) NULL,
    [AddedBy]                 VARCHAR (25) NULL,
    [CLNO]                    INT          NULL,
    [SSN]                     VARCHAR (20) NULL,
    [IsPrimaryName]           BIT          CONSTRAINT [ApplAlias_IsPrimaryName] DEFAULT ((0)) NULL,
    [IsActive]                BIT          CONSTRAINT [ApplAlias_IsActive] DEFAULT ((1)) NULL,
    [CreatedBy]               VARCHAR (50) NULL,
    [LastUpdateDate]          DATETIME     DEFAULT (getdate()) NULL,
    [LastUpdatedBy]           VARCHAR (50) NULL,
    [IsPublicRecordQualified] BIT          CONSTRAINT [ApplAlias_IsPublicRecordQualified] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ApplAlias] PRIMARY KEY CLUSTERED ([ApplAliasID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ApplAlias_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAlias_IsPrimaryName_Inc-APNO]
    ON [dbo].[ApplAlias]([IsPrimaryName] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplAlias_APNO]
    ON [dbo].[ApplAlias]([APNO] ASC)
    INCLUDE([IsPrimaryName], [IsActive]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplAlias_IsPublicRecordQualified]
    ON [dbo].[ApplAlias]([IsPublicRecordQualified] ASC)
    INCLUDE([ApplAliasID], [APNO]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IsActive_IsPublicRecordQualified_Includes]
    ON [dbo].[ApplAlias]([IsActive] ASC, [IsPublicRecordQualified] ASC)
    INCLUDE([APNO], [First], [Middle], [Last]) WITH (FILLFACTOR = 100);

