CREATE TABLE [dbo].[InvDetailLogging] (
    [InvDetailLoggingID] INT           IDENTITY (1, 1) NOT NULL,
    [UpdatedID]          INT           NULL,
    [apno]               INT           NULL,
    [OldDesc]            VARCHAR (100) NULL,
    [NewDesc]            VARCHAR (100) NULL,
    [OldAmount]          SMALLMONEY    NULL,
    [NewAmount]          SMALLMONEY    NULL,
    [ModifiedDate]       DATETIME      NULL,
    CONSTRAINT [PK_InvDetailLogging] PRIMARY KEY CLUSTERED ([InvDetailLoggingID] ASC) WITH (FILLFACTOR = 50)
);

