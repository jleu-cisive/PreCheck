CREATE TABLE [dbo].[ReleaseEmailLog] (
    [LogID]    INT           IDENTITY (1, 1) NOT NULL,
    [SentBy]   VARCHAR (50)  NULL,
    [SentTo]   VARCHAR (50)  NULL,
    [Subject]  VARCHAR (200) NULL,
    [Body]     VARCHAR (MAX) NULL,
    [SendDate] DATETIME      NULL,
    [CLNO]     INT           NULL
);

