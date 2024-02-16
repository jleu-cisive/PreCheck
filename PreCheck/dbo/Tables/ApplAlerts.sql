CREATE TABLE [dbo].[ApplAlerts] (
    [ApplAlertID]          INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                 INT          NOT NULL,
    [PackageComponentID]   INT          NULL,
    [ItemID]               INT          NULL,
    [Cleared]              BIT          CONSTRAINT [DF_ApplAlerts_Completed] DEFAULT ((0)) NOT NULL,
    [ClearedBy]            VARCHAR (8)  NULL,
    [ClearedDate]          DATETIME     NULL,
    [Incomplete]           BIT          CONSTRAINT [DF_ApplAlerts_Incomplete] DEFAULT ((0)) NOT NULL,
    [Billed]               BIT          CONSTRAINT [DF_ApplAlerts_Billed] DEFAULT ((0)) NOT NULL,
    [Source]               VARCHAR (50) NULL,
    [refAlertTypeID]       INT          NULL,
    [refApplAlertStatusID] INT          NULL,
    [CreatedDate]          DATETIME     NOT NULL,
    [Comment]              TEXT         NULL,
    CONSTRAINT [PK_ApplAlerts] PRIMARY KEY CLUSTERED ([ApplAlertID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

