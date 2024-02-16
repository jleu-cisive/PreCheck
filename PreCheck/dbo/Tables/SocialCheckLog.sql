CREATE TABLE [dbo].[SocialCheckLog] (
    [SocialCheckLogID] INT      IDENTITY (1, 1) NOT NULL,
    [Apno]             INT      NULL,
    [SocialAction]     TEXT     NULL,
    [SocialDate]       DATETIME NULL,
    CONSTRAINT [PK_SocialCheckLog] PRIMARY KEY CLUSTERED ([SocialCheckLogID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

