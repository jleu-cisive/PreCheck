CREATE TABLE [dbo].[ZipCrimWorkOrders] (
    [APNO]                    INT            NOT NULL,
    [WorkOrderID]             INT            NULL,
    [SubjectID]               INT            NULL,
    [refWorkOrderStatusID]    INT            NOT NULL,
    [IsAutomated]             BIT            NOT NULL,
    [SubmitWorkOrderAttempts] INT            CONSTRAINT [DF_ZipCrimWorkOrders_SubmitWorkOrderAttempts] DEFAULT ((0)) NOT NULL,
    [GetLeadsAttempts]        INT            CONSTRAINT [DF_ZipCrimWorkOrders_GetLeadsAttempts] DEFAULT ((0)) NOT NULL,
    [SubjectData]             NVARCHAR (MAX) NULL,
    [LeadsData]               NVARCHAR (MAX) NULL,
    [CreateDate]              DATETIME2 (3)  CONSTRAINT [DF_ZipCrimWorkOrders_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               VARCHAR (200)  CONSTRAINT [DF_ZipCrimWorkOrders_CreatedBy] DEFAULT (app_name()) NOT NULL,
    [ModifyDate]              DATETIME2 (3)  NULL,
    [ModifiedBy]              VARCHAR (100)  NULL,
    CONSTRAINT [PK_ZipCrimWorkOrders_APNO] PRIMARY KEY CLUSTERED ([APNO] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ZipCrimWorkOrders_refWorkOrderStatusID] FOREIGN KEY ([refWorkOrderStatusID]) REFERENCES [dbo].[refWorkOrderStatus] ([refWorkOrderStatusID])
);


GO
CREATE NONCLUSTERED INDEX [idx_WorkOrderID]
    ON [dbo].[ZipCrimWorkOrders]([WorkOrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ZipCrimWorkOrders_refWorkOrderStatusID]
    ON [dbo].[ZipCrimWorkOrders]([refWorkOrderStatusID] ASC)
    INCLUDE([APNO], [WorkOrderID]);

