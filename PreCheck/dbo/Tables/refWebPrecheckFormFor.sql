CREATE TABLE [dbo].[refWebPrecheckFormFor] (
    [refWebPrecheckFormForID] INT          IDENTITY (1, 1) NOT NULL,
    [WebPrecheckFormFor]      VARCHAR (50) NULL,
    [IsActive]                BIT          CONSTRAINT [DF_refWebPrecheckFormFor_IsActive] DEFAULT (1) NULL,
    CONSTRAINT [PK_refWebPrecheckFormFor] PRIMARY KEY CLUSTERED ([refWebPrecheckFormForID] ASC) WITH (FILLFACTOR = 50)
);

