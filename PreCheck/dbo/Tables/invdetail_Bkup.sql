CREATE TABLE [dbo].[invdetail_Bkup] (
    [InvDetID]      INT           IDENTITY (1, 1) NOT NULL,
    [APNO]          INT           NOT NULL,
    [Type]          SMALLINT      NOT NULL,
    [Subkey]        INT           NULL,
    [SubKeyChar]    VARCHAR (50)  NULL,
    [Billed]        BIT           NOT NULL,
    [InvoiceNumber] INT           NULL,
    [CreateDate]    DATETIME      NOT NULL,
    [Description]   VARCHAR (100) NULL,
    [Amount]        SMALLMONEY    NULL
);

