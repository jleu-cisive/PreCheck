CREATE TABLE [dbo].[PrecheckConfiguration] (
    [PrecheckKeyID] INT            IDENTITY (1, 1) NOT NULL,
    [PrecheckKey]   VARCHAR (50)   NOT NULL,
    [PrecheckValue] VARCHAR (8000) NULL,
    CONSTRAINT [PK_PrecheckConfiguration_1] PRIMARY KEY CLUSTERED ([PrecheckKey] ASC) WITH (FILLFACTOR = 50)
);

