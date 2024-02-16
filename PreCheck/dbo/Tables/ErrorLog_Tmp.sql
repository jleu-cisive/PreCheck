CREATE TABLE [dbo].[ErrorLog_Tmp] (
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
    [CreateDate]    DATETIME       NOT NULL
);

