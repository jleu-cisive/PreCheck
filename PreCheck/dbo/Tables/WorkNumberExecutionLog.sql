CREATE TABLE [dbo].[WorkNumberExecutionLog] (
    [WorkNumberExecutionID] INT             IDENTITY (1, 1) NOT NULL,
    [Date]                  DATETIME        NOT NULL,
    [Thread]                VARCHAR (32)    NOT NULL,
    [Context]               VARCHAR (10)    NOT NULL,
    [Level]                 VARCHAR (10)    NOT NULL,
    [Logger]                VARCHAR (512)   NOT NULL,
    [Method]                VARCHAR (200)   NULL,
    [Parameters]            NVARCHAR (4000) NULL,
    [Message]               NVARCHAR (1000) NOT NULL,
    [Exception]             NVARCHAR (4000) NULL,
    [ExecutionTime]         DECIMAL (14, 4) NULL,
    CONSTRAINT [PK_WorkNumberExecutionLog] PRIMARY KEY CLUSTERED ([WorkNumberExecutionID] ASC) WITH (FILLFACTOR = 50)
);

