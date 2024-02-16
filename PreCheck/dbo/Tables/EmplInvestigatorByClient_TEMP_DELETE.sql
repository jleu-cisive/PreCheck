CREATE TABLE [dbo].[EmplInvestigatorByClient_TEMP_DELETE] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]       INT           NULL,
    [LogDate]    DATETIME      NULL,
    [ColumnName] VARCHAR (100) NULL,
    [OldValue]   VARCHAR (8)   NULL,
    [NewValue]   VARCHAR (8)   NULL,
    CONSTRAINT [PK_EmplInvestigatorByClient_TEMP] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

