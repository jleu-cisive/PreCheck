CREATE TABLE [dbo].[refWorkOrderStatus] (
    [refWorkOrderStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [ItemName]             VARCHAR (100) NOT NULL,
    [Description]          VARCHAR (MAX) NULL,
    [DisplayOrder]         INT           NOT NULL,
    [IsActive]             BIT           NOT NULL,
    [CreateDate]           DATETIME2 (3) CONSTRAINT [DF_refWorkOrderStatus_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]             VARCHAR (100) NOT NULL,
    [ModifyDate]           DATETIME2 (3) NULL,
    [ModifyBy]             VARCHAR (100) NULL,
    CONSTRAINT [PK_refWorkOrderStatus_refWorkOrderStatusID] PRIMARY KEY CLUSTERED ([refWorkOrderStatusID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [UQ_refWorkOrderStatus_DisplayOrder] UNIQUE NONCLUSTERED ([DisplayOrder] ASC) WITH (FILLFACTOR = 70)
);

