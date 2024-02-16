CREATE TABLE [dbo].[ErrorLog] (
    [LogId]         INT            IDENTITY (1, 1) NOT NULL,
    [Thread]        VARCHAR (255)  NOT NULL,
    [Level]         VARCHAR (50)   NOT NULL,
    [Logger]        VARCHAR (255)  NOT NULL,
    [Message]       VARCHAR (4000) NOT NULL,
    [Exception]     VARCHAR (2000) NULL,
    [User]          VARCHAR (255)  NULL,
    [Method]        VARCHAR (500)  NULL,
    [Parameters]    VARCHAR (500)  NULL,
    [Context]       VARCHAR (500)  NULL,
    [ExecutionTime] VARCHAR (100)  NULL,
    [ClassName]     VARCHAR (500)  NULL,
    [CreateDate]    DATETIME       CONSTRAINT [DF_Logging_CreateDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Logging] PRIMARY KEY CLUSTERED ([LogId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_CreateDate]
    ON [dbo].[ErrorLog]([CreateDate] ASC)
    ON [PRIMARY];

