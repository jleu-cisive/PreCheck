CREATE TABLE [dbo].[InvMaster] (
    [InvoiceNumber] INT        IDENTITY (8975890, 1) NOT NULL,
    [CLNO]          SMALLINT   NOT NULL,
    [Printed]       BIT        CONSTRAINT [DF_InvMaster_Printed] DEFAULT (0) NOT NULL,
    [InvDate]       DATETIME   NOT NULL,
    [Sale]          MONEY      NULL,
    [Tax]           SMALLMONEY NOT NULL,
    CONSTRAINT [PK_InvMaster] PRIMARY KEY CLUSTERED ([InvoiceNumber] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_InvMaster_Client] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO])
);


GO
CREATE NONCLUSTERED INDEX [IX_InvMaster_CLNO]
    ON [dbo].[InvMaster]([CLNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_InvDate]
    ON [dbo].[InvMaster]([InvDate] ASC)
    INCLUDE([InvoiceNumber]) WITH (FILLFACTOR = 50)
    ON [PRIMARY];

