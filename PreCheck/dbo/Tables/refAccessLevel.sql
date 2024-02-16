CREATE TABLE [dbo].[refAccessLevel] (
    [refAccessLevelID] INT           IDENTITY (1, 1) NOT NULL,
    [AccessLevel]      VARCHAR (20)  NULL,
    [Description]      VARCHAR (100) NULL,
    CONSTRAINT [PK_refAccessLevel] PRIMARY KEY CLUSTERED ([refAccessLevelID] ASC) WITH (FILLFACTOR = 50)
);

