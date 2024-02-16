CREATE TABLE [REPORT].[OrderSummary] (
    [OrderNumber]          INT           NOT NULL,
    [Applicant_FirstName]  VARCHAR (50)  NULL,
    [Applicant_LastName]   VARCHAR (50)  NULL,
    [Applicant_MiddleName] VARCHAR (50)  NULL,
    [Applicant_UID]        VARCHAR (12)  NULL,
    [OrderCreateDate]      DATETIME      NOT NULL,
    [ClientId]             INT           NOT NULL,
    [ProgramId]            INT           NULL,
    [ProgramName]          VARCHAR (250) NULL,
    [ApDate]               DATETIME      NULL,
    [HasBackground]        BIT           NOT NULL,
    [HasDrugScreen]        BIT           NOT NULL,
    [HasImmunization]      BIT           NOT NULL,
    [BG_OrderStatusId]     SMALLINT      NULL,
    [BG_OrderStatus]       VARCHAR (1)   NULL,
    [BG_CompleteDate]      DATETIME      NULL,
    [BG_ResultId]          SMALLINT      NULL,
    [BG_Result]            VARCHAR (20)  NULL,
    [DT_OrderStatusId]     SMALLINT      NULL,
    [DT_OrderStatus]       VARCHAR (1)   NULL,
    [DT_CompleteDate]      DATETIME      NULL,
    [DT_ResultId]          SMALLINT      NULL,
    [DT_Result]            VARCHAR (20)  NULL,
    [DT_OrderId]           INT           NULL,
    [DT_ReportId]          INT           NULL,
    [IM_OrderStatusId]     SMALLINT      NULL,
    [IM_OrderStatus]       VARCHAR (1)   NULL,
    [IM_ResultId]          SMALLINT      NULL,
    [IM_Result]            VARCHAR (20)  NULL,
    [OrderStatusId]        SMALLINT      NULL,
    [CreateDate]           DATETIME      CONSTRAINT [DF_OrderSummary_CreateDate] DEFAULT (getdate()) NOT NULL,
    [ModifyDate]           DATETIME      CONSTRAINT [DF_OrderSummary_ModifyDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OrderSummary] PRIMARY KEY CLUSTERED ([OrderNumber] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Client_CreateDate]
    ON [REPORT].[OrderSummary]([ClientId] ASC, [OrderCreateDate] ASC)
    INCLUDE([OrderNumber], [Applicant_FirstName], [Applicant_LastName], [ProgramId], [HasBackground], [HasDrugScreen], [HasImmunization], [BG_OrderStatusId], [BG_ResultId], [DT_OrderStatusId], [DT_ResultId], [IM_OrderStatusId], [IM_ResultId], [ProgramName]);

