CREATE TABLE [dbo].[PriorityLevel] (
    [PriorityLevelID] INT           IDENTITY (1, 1) NOT NULL,
    [PriorityType]    VARCHAR (50)  NULL,
    [FieldName]       VARCHAR (50)  NULL,
    [ColumnName]      VARCHAR (100) NULL,
    [Weight]          FLOAT (53)    NULL,
    CONSTRAINT [PK_PriorityLevel] PRIMARY KEY CLUSTERED ([PriorityLevelID] ASC) WITH (FILLFACTOR = 50)
);

