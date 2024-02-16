CREATE TABLE [dbo].[Crim_ResendLog] (
    [errorLogid] INT      IDENTITY (1, 1) NOT NULL,
    [CrimID]     INT      NULL,
    [Apno]       INT      NULL,
    [CreateDate] DATETIME NULL,
    CONSTRAINT [PK_dbo.Crim_ResendLog_] PRIMARY KEY CLUSTERED ([errorLogid] ASC) WITH (FILLFACTOR = 50)
);

