CREATE TABLE [dbo].[OccHealthServicesSavePDFErrorLog] (
    [ErrorID]      INT           IDENTITY (1, 1) NOT NULL,
    [ProviderID]   VARCHAR (25)  NOT NULL,
    [OrderID]      VARCHAR (25)  NULL,
    [SSNOrOtherID] VARCHAR (25)  NULL,
    [ErrorDesc]    VARCHAR (500) NULL,
    [ErrorDate]    DATETIME      CONSTRAINT [DF_OccHealthServicesSavePDFErrorLog_ErrorDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OccHealthServicesSavePDFErrorLog] PRIMARY KEY CLUSTERED ([ErrorID] ASC) WITH (FILLFACTOR = 50)
);

