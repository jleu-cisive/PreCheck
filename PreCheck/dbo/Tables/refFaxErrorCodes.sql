CREATE TABLE [dbo].[refFaxErrorCodes] (
    [refFaxErrorCodesID] INT           IDENTITY (1, 1) NOT NULL,
    [ErrorCode]          INT           NULL,
    [Message]            VARCHAR (800) NULL,
    [Type]               VARCHAR (50)  NULL,
    CONSTRAINT [PK_refFaxErrorCodes] PRIMARY KEY CLUSTERED ([refFaxErrorCodesID] ASC) WITH (FILLFACTOR = 50)
);

