CREATE TABLE [dbo].[refCredentCheckEmployerStatus] (
    [CredentCheckEmployerStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [CredentCheckEmployerStatus]   VARCHAR (50) NULL,
    CONSTRAINT [PK_refCredentCheckEmployerStatus] PRIMARY KEY CLUSTERED ([CredentCheckEmployerStatusID] ASC) WITH (FILLFACTOR = 50)
);

