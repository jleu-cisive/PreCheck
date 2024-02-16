CREATE TABLE [dbo].[refStatewide] (
    [StateWideID]       INT            IDENTITY (1, 1) NOT NULL,
    [Description]       NVARCHAR (100) NULL,
    [StatewideSearchID] INT            NULL,
    CONSTRAINT [PK_dbo.refStatewide] PRIMARY KEY CLUSTERED ([StateWideID] ASC) WITH (FILLFACTOR = 50)
);

