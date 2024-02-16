CREATE TABLE [dbo].[StudentCheckErrors] (
    [ErrorID]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [TransactionID]    VARCHAR (50)  NULL,
    [Reference]        VARCHAR (50)  NULL,
    [ErrorNumber]      BIGINT        NULL,
    [ErrorDescription] VARCHAR (300) NULL,
    [ErrorSource]      VARCHAR (50)  NULL,
    [ErrorMsg]         VARCHAR (MAX) NULL,
    [ErrorDateTime]    DATETIME      NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

