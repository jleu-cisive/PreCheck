CREATE TABLE [dbo].[tmp1] (
    [InvDetID]      INT           NOT NULL,
    [APNO]          INT           NOT NULL,
    [Type]          SMALLINT      NOT NULL,
    [Subkey]        INT           NULL,
    [SubKeyChar]    VARCHAR (2)   NULL,
    [Billed]        BIT           NOT NULL,
    [InvoiceNumber] INT           NULL,
    [CreateDate]    DATETIME      NOT NULL,
    [Description]   VARCHAR (100) NULL,
    [Amount]        SMALLMONEY    NULL,
    [compdate]      DATETIME      NULL
);

