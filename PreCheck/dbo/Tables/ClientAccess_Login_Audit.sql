CREATE TABLE [dbo].[ClientAccess_Login_Audit] (
    [ClientAccessLogID] INT          IDENTITY (1, 1) NOT NULL,
    [username]          VARCHAR (50) NULL,
    [password]          VARCHAR (50) NULL,
    [clientid]          INT          NULL,
    [LogDate]           DATETIME     NULL,
    [LogInSuccess]      BIT          NULL,
    [ClientType]        SMALLINT     NULL,
    CONSTRAINT [PK_ClientAccess_Login_Audit] PRIMARY KEY CLUSTERED ([ClientAccessLogID] ASC) WITH (FILLFACTOR = 50)
);

