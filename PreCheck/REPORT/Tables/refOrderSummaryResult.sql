CREATE TABLE [REPORT].[refOrderSummaryResult] (
    [OrderSummaryResultId] SMALLINT     NOT NULL,
    [ServiceType]          VARCHAR (1)  NOT NULL,
    [ResultCode]           VARCHAR (20) NOT NULL,
    [DisplayName]          VARCHAR (50) NOT NULL,
    [ResultGroup]          SMALLINT     NULL,
    [CreateDate]           DATETIME     CONSTRAINT [DF_OrderSummaryResult_CreateDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OrderSummaryResult] PRIMARY KEY CLUSTERED ([OrderSummaryResultId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: neutral, 1: positive, -1: negative', @level0type = N'SCHEMA', @level0name = N'REPORT', @level1type = N'TABLE', @level1name = N'refOrderSummaryResult', @level2type = N'COLUMN', @level2name = N'ResultGroup';

