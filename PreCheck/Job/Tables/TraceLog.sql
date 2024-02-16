CREATE TABLE [Job].[TraceLog] (
    [TraceLogId] INT            IDENTITY (1, 1) NOT NULL,
    [Component]  VARCHAR (5)    NOT NULL,
    [TaskName]   VARCHAR (250)  NULL,
    [Message]    VARCHAR (2000) NOT NULL,
    [TraceLevel] VARCHAR (10)   NOT NULL,
    [CreateDate] DATETIME       NULL
);

