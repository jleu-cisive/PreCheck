CREATE TABLE [dbo].[PrecheckSSO] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [CLNO]           INT              NULL,
    [UserName]       VARCHAR (50)     NULL,
    [Token]          UNIQUEIDENTIFIER NULL,
    [Product]        VARCHAR (100)    NULL,
    [ExpiresInDays]  INT              NULL,
    [ExpiresDefault] INT              NULL,
    [CreatedDate]    DATETIME         NULL,
    [IsSuperUser]    BIT              NULL,
    CONSTRAINT [PK_PrecheckSSO] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 50)
);

