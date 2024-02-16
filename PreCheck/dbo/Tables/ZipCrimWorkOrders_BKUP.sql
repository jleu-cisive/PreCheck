CREATE TABLE [dbo].[ZipCrimWorkOrders_BKUP] (
    [APNO]                    INT            NOT NULL,
    [WorkOrderID]             INT            NULL,
    [SubjectID]               INT            NULL,
    [refWorkOrderStatusID]    INT            NOT NULL,
    [IsAutomated]             BIT            NOT NULL,
    [SubmitWorkOrderAttempts] INT            NOT NULL,
    [GetLeadsAttempts]        INT            NOT NULL,
    [SubjectData]             NVARCHAR (MAX) NULL,
    [LeadsData]               NVARCHAR (MAX) NULL,
    [CreateDate]              DATETIME2 (3)  NOT NULL,
    [CreatedBy]               VARCHAR (200)  NOT NULL,
    [ModifyDate]              DATETIME2 (3)  NULL,
    [ModifiedBy]              VARCHAR (100)  NULL
);

