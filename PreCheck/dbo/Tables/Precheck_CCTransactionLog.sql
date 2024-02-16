CREATE TABLE [dbo].[Precheck_CCTransactionLog] (
    [TransactionID]        INT           IDENTITY (1, 1) NOT NULL,
    [APPNUMBER]            INT           NULL,
    [CCNO]                 NVARCHAR (50) NULL,
    [CCTYPE]               VARCHAR (20)  NULL,
    [Name]                 VARCHAR (50)  NULL,
    [TransUserIP]          VARCHAR (50)  NULL,
    [TransactionType]      CHAR (1)      NULL,
    [TransREF]             VARCHAR (50)  NOT NULL,
    [TransResponseCode]    INT           NULL,
    [TransResponseDesc]    VARCHAR (100) NULL,
    [TransDate]            DATETIME      NULL,
    [TransAmount]          MONEY         NULL,
    [AuthCode]             VARCHAR (50)  NULL,
    [AVSAuth]              CHAR (1)      NULL,
    [CSCAuth]              CHAR (1)      NULL,
    [GatewayCharges]       MONEY         CONSTRAINT [DF_Precheck_CCTransactionLog_GatewayCharges] DEFAULT ((0)) NULL,
    [AcquiringBankCharges] MONEY         CONSTRAINT [DF_Precheck_CCTransactionLog_AcquiringBankCharges] DEFAULT ((0)) NULL,
    [AMEXCharges]          MONEY         CONSTRAINT [DF_Precheck_CCTransactionLog_AMEXCharges] DEFAULT ((0)) NULL,
    [Comment1]             VARCHAR (128) NULL,
    [Comment2]             VARCHAR (128) NULL,
    [INVOICED]             BIT           CONSTRAINT [DF_Precheck_CCTransactionLog_INVOICED] DEFAULT ((0)) NULL
) ON [PRIMARY];

