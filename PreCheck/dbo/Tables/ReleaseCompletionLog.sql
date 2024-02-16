CREATE TABLE [dbo].[ReleaseCompletionLog] (
    [ReleaseLogCompletionID] INT            IDENTITY (1, 1) NOT NULL,
    [ClientAPNO]             VARCHAR (50)   NULL,
    [CLNO]                   INT            NULL,
    [first]                  VARCHAR (50)   NULL,
    [last]                   VARCHAR (50)   NULL,
    [SSN]                    VARCHAR (11)   NULL,
    [BrowserInfo]            NVARCHAR (MAX) NULL,
    [IP]                     VARCHAR (200)  NULL,
    [LogTime]                DATETIME       NULL,
    [CrimResponse]           NVARCHAR (MAX) NULL,
    [ReleaseInsertException] VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_ReleaseCompletionLog] PRIMARY KEY CLUSTERED ([ReleaseLogCompletionID] ASC)
);

