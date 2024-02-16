CREATE TABLE [dbo].[I9IntegrationLog] (
    [I9IntegrationLogId]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [Request]             NVARCHAR (MAX) NULL,
    [TransformedRequest]  NVARCHAR (MAX) NULL,
    [Response]            NVARCHAR (MAX) NULL,
    [TransformedResponse] NVARCHAR (MAX) NULL,
    [ResponseCode]        INT            NULL,
    [I9OrderDetailID]     BIGINT         NULL,
    [I9CallBackResponse]  NVARCHAR (MAX) NULL,
    [CreateDate]          DATETIME       NOT NULL,
    [CreateBy]            NVARCHAR (50)  NULL,
    [ModifyDate]          DATETIME       NULL,
    [ModifyBy]            NVARCHAR (50)  NULL,
    CONSTRAINT [PK_dbo.I9IntegrationLog] PRIMARY KEY CLUSTERED ([I9IntegrationLogId] ASC),
    CONSTRAINT [FK_dbo.I9IntegrationLog_dbo.I9OrderDetail_I9OrderDetailID] FOREIGN KEY ([I9OrderDetailID]) REFERENCES [dbo].[I9OrderDetail] ([I9OrderDetailID])
);

