CREATE TABLE [dbo].[refCreditNotes] (
    [CreditNotesID] INT           IDENTITY (1, 1) NOT NULL,
    [CreditNotes]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refCreditNotes] PRIMARY KEY CLUSTERED ([CreditNotesID] ASC) WITH (FILLFACTOR = 50)
);

