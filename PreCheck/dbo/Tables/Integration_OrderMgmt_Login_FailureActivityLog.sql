CREATE TABLE [dbo].[Integration_OrderMgmt_Login_FailureActivityLog] (
    [ActivityLogID] INT          IDENTITY (1, 1) NOT NULL,
    [UserName]      VARCHAR (50) NOT NULL,
    [CLNO]          INT          NOT NULL,
    [Password]      VARCHAR (50) NOT NULL,
    [ActivityDate]  DATETIME     CONSTRAINT [DF_Integration_LoginFailureActivityLog_LoginDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Integration_LoginFailureActivityLog] PRIMARY KEY CLUSTERED ([ActivityLogID] ASC) WITH (FILLFACTOR = 50)
);

