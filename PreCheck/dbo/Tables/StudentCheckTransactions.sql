CREATE TABLE [dbo].[StudentCheckTransactions] (
    [TransactionID]      UNIQUEIDENTIFIER NOT NULL,
    [TransactionStatus]  VARCHAR (200)    NOT NULL,
    [TransactionMode]    VARCHAR (200)    NOT NULL,
    [StartedDateTime]    DATETIME         NOT NULL,
    [CompletedDateTime]  DATETIME         NULL,
    [TransactionMessage] VARCHAR (4000)   NULL,
    CONSTRAINT [PK_StudentCheckTransactions] PRIMARY KEY CLUSTERED ([TransactionID] ASC) WITH (FILLFACTOR = 50)
);

