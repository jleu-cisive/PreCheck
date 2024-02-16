CREATE TABLE [dbo].[ApplImages] (
    [ApplImagesID]   INT           IDENTITY (1, 1) NOT NULL,
    [APNO]           INT           NULL,
    [ImageFilename]  VARCHAR (100) NULL,
    [ClientFilename] VARCHAR (150) NULL,
    [Description]    VARCHAR (255) NULL,
    [ClientOther]    VARCHAR (50)  NULL,
    [Status]         INT           NULL,
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ApplImages] PRIMARY KEY CLUSTERED ([ApplImagesID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_APNO]
    ON [dbo].[ApplImages]([APNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

