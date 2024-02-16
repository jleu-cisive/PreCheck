CREATE TABLE [dbo].[ZipCrimWorkOrdersStaging] (
    [WorkOrderID]          INT              NOT NULL,
    [PartnerID]            INT              NOT NULL,
    [ClientID]             VARCHAR (10)     NOT NULL,
    [PartnerReference]     VARCHAR (20)     NOT NULL,
    [ConfirmationCode]     UNIQUEIDENTIFIER CONSTRAINT [DF_ZipCrimWorkOrdersStaging_ConfirmationCode] DEFAULT (newid()) NOT NULL,
    [refWorkOrderStatusID] INT              NOT NULL,
    [CreateReportAttempts] INT              CONSTRAINT [DF_ZipCrimWorkOrdersStaging_SubmitWorkOrderAttempts] DEFAULT ((0)) NOT NULL,
    [CreateDate]           DATETIME2 (7)    CONSTRAINT [DF_ZipCrimWorkOrdersStaging_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (100)    CONSTRAINT [DF_ZipCrimWorkOrdersStaging_CreatedBy] DEFAULT (app_name()) NOT NULL,
    [ModifyDate]           DATETIME2 (3)    NULL,
    [ModifiedBy]           VARCHAR (100)    NULL,
    CONSTRAINT [PK_ZipCrimWorkOrdersStaging_WorkOrderID] PRIMARY KEY CLUSTERED ([PartnerID] ASC, [WorkOrderID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ZipCrimWorkOrdersStaging_refWorkOrderStatus_PartnerID] FOREIGN KEY ([PartnerID]) REFERENCES [dbo].[Partner] ([PartnerId]),
    CONSTRAINT [FK_ZipCrimWorkOrdersStaging_refWorkOrderStatus_refWorkOrderStatusID] FOREIGN KEY ([refWorkOrderStatusID]) REFERENCES [dbo].[refWorkOrderStatus] ([refWorkOrderStatusID])
);


GO
CREATE NONCLUSTERED INDEX [idx_Staging_WorkOrderID]
    ON [dbo].[ZipCrimWorkOrdersStaging]([WorkOrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Staging_PartnerReference]
    ON [dbo].[ZipCrimWorkOrdersStaging]([PartnerReference] ASC);

