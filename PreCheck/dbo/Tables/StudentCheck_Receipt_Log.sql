CREATE TABLE [dbo].[StudentCheck_Receipt_Log] (
    [ReceiptLogId]  INT           IDENTITY (1, 1) NOT NULL,
    [Apno]          INT           NOT NULL,
    [EmailAddress]  VARCHAR (200) NULL,
    [UserName]      VARCHAR (50)  NULL,
    [HostIPAddress] VARCHAR (50)  NULL,
    [HostDateTime]  DATETIME      NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [CreatedBy]     VARCHAR (50)  NOT NULL
);

