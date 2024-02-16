CREATE TABLE [EAPI].[ExpandedApiCallback] (
    [ExpandedApiCallbackId] INT         IDENTITY (1, 1) NOT NULL,
    [OrderNumber]           INT         NULL,
    [IsCallbackReady]       BIT         NULL,
    [CallbackDate]          DATETIME    NULL,
    [CreatedDate]           DATETIME    DEFAULT (getdate()) NULL,
    [CreatedBy]             VARCHAR (8) NULL,
    [ModifiedDate]          DATETIME    NULL,
    [CallbackFailures]      INT         DEFAULT (NULL) NULL,
    CONSTRAINT [PK_ExpandedApiCallbackId] PRIMARY KEY CLUSTERED ([ExpandedApiCallbackId] ASC) ON [PRIMARY]
) ON [PRIMARY];

