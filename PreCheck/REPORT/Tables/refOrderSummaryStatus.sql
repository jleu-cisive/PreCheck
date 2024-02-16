CREATE TABLE [REPORT].[refOrderSummaryStatus] (
    [OrderSummaryStatusId] SMALLINT     NOT NULL,
    [StatusCode]           VARCHAR (1)  NOT NULL,
    [DisplayName]          VARCHAR (15) NOT NULL,
    [CreateDate]           DATETIME     CONSTRAINT [DF_OrderSummaryStatus_CreateDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OrderSummaryStatus] PRIMARY KEY CLUSTERED ([OrderSummaryStatusId] ASC)
);

