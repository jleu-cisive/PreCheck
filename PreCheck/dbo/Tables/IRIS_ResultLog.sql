CREATE TABLE [dbo].[IRIS_ResultLog] (
    [ResultLogID]         INT         IDENTITY (1, 1) NOT NULL,
    [ResultLogCategoryID] INT         NULL,
    [CrimID]              INT         NULL,
    [APNO]                INT         NULL,
    [Investigator]        VARCHAR (8) NULL,
    [LogDate]             DATETIME    CONSTRAINT [DF_IRIS_ResultLog_LogDate] DEFAULT (getdate()) NULL,
    [Clear]               VARCHAR (1) NULL,
    CONSTRAINT [PK_IRIS_ResultLog] PRIMARY KEY CLUSTERED ([ResultLogID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [LogDate_Clear_Includes]
    ON [dbo].[IRIS_ResultLog]([LogDate] ASC, [Clear] ASC)
    INCLUDE([ResultLogCategoryID], [CrimID], [APNO], [Investigator]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [Investigator_LogDate_Clear_Includes]
    ON [dbo].[IRIS_ResultLog]([Investigator] ASC, [LogDate] ASC, [Clear] ASC)
    INCLUDE([ResultLogCategoryID], [CrimID]) WITH (FILLFACTOR = 100);

