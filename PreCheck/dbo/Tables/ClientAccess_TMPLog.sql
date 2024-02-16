CREATE TABLE [dbo].[ClientAccess_TMPLog] (
    [logid]        INT IDENTITY (1, 1) NOT NULL,
    [Adjudication] BIT NULL,
    [clno]         INT NULL,
    [apno]         INT NULL,
    CONSTRAINT [PK_ClientAccess_TMPLog] PRIMARY KEY CLUSTERED ([logid] ASC) WITH (FILLFACTOR = 50)
);

