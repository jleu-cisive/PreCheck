CREATE TABLE [dbo].[ClientCrimStatus] (
    [ClientCrimStatusID]    INT          IDENTITY (1, 1) NOT NULL,
    [CrimStatusCode]        VARCHAR (50) NOT NULL,
    [CrimStatusDescription] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ClientCrimStatus] PRIMARY KEY CLUSTERED ([ClientCrimStatusID] ASC) WITH (FILLFACTOR = 50)
);

