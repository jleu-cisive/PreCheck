CREATE TABLE [dbo].[ApplFile] (
    [ApplFileID]      INT           IDENTITY (1, 1) NOT NULL,
    [APNO]            INT           NOT NULL,
    [ImageFilename]   VARCHAR (150) NULL,
    [ClientFilename]  VARCHAR (150) NULL,
    [Description]     VARCHAR (50)  NULL,
    [ClientOther]     VARCHAR (50)  NULL,
    [refApplFileType] INT           NULL,
    [AttachToReport]  BIT           NULL,
    [Deleted]         BIT           CONSTRAINT [DF_ApplFile_Deleted] DEFAULT ((0)) NOT NULL,
    [CreatedDate]     DATETIME      CONSTRAINT [DF_ApplFile_CreatedDate] DEFAULT (getdate()) NULL,
    [FileSize]        BIGINT        NULL,
    CONSTRAINT [PK_ApplFile] PRIMARY KEY CLUSTERED ([ApplFileID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_APNO]
    ON [dbo].[ApplFile]([APNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

