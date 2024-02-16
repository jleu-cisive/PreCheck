CREATE TABLE [dbo].[PrecheckFramework_ApplAliasStaging] (
    [ApplAliasStagingID]      INT           IDENTITY (1, 1) NOT NULL,
    [SectionId]               INT           NULL,
    [FolderId]                VARCHAR (100) NULL,
    [APNO]                    INT           NULL,
    [First]                   VARCHAR (50)  NULL,
    [Middle]                  VARCHAR (50)  NULL,
    [Last]                    VARCHAR (50)  NULL,
    [IsMaiden]                BIT           NULL,
    [CreatedDate]             DATETIME      NULL,
    [Generation]              VARCHAR (15)  NULL,
    [Deleted]                 BIT           NULL,
    [CLNO]                    INT           NULL,
    [SSN]                     VARCHAR (20)  NULL,
    [IsPublicRecordQualified] BIT           NULL,
    [IsPrimaryName]           BIT           NULL,
    [CreatedBy]               VARCHAR (50)  NULL,
    [LastUpdatedDate]         DATETIME      NULL,
    [LastUpdatedBy]           VARCHAR (50)  NULL,
    CONSTRAINT [PK_ApplAliasStagingId] PRIMARY KEY CLUSTERED ([ApplAliasStagingID] ASC) WITH (FILLFACTOR = 50)
);

