CREATE TABLE [dbo].[refPC_Application] (
    [refPC_ApplicationID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]         VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_refPC_Application] PRIMARY KEY CLUSTERED ([refPC_ApplicationID] ASC) WITH (FILLFACTOR = 50)
);

