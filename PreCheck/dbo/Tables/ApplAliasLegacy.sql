CREATE TABLE [dbo].[ApplAliasLegacy] (
    [APNO]   INT          NOT NULL,
    [Alias]  VARCHAR (30) NULL,
    [Alias2] VARCHAR (30) NULL,
    [Alias3] VARCHAR (30) NULL,
    [Alias4] VARCHAR (30) NULL,
    CONSTRAINT [PK_ApplAliasLegacy] PRIMARY KEY CLUSTERED ([APNO] ASC) WITH (FILLFACTOR = 50)
);

