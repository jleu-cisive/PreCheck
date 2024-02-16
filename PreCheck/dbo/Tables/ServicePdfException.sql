CREATE TABLE [dbo].[ServicePdfException] (
    [id]             INT          IDENTITY (1, 1) NOT NULL,
    [Apno]           INT          NULL,
    [DeliveryMethod] VARCHAR (50) NULL,
    [Clno]           INT          NULL,
    [Attn]           VARCHAR (50) NULL,
    [Fax]            VARCHAR (20) NULL,
    [ErrorDate]      DATETIME     CONSTRAINT [DF_ServicePdfException_ErrorDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ServicePdfException] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

