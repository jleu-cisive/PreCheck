CREATE TABLE [dbo].[PartnerCallback] (
    [PartnerCallbackId]    INT          IDENTITY (1, 1) NOT NULL,
    [PartnerId]            INT          NULL,
    [OrderNumber]          INT          NULL,
    [PartnerReference]     VARCHAR (50) NULL,
    [PartnerCallbackReady] BIT          CONSTRAINT [DF_PartnerCallback_PartnerCallbackReady] DEFAULT ((1)) NULL,
    [PartnerCallbackDate]  DATETIME     NULL,
    [RefUserActionId]      INT          CONSTRAINT [DF_PartnerCallback_RefUserActionId] DEFAULT ((1)) NOT NULL,
    [IsComplete]           BIT          CONSTRAINT [DF_PartnerCallback_IsComplete] DEFAULT ((0)) NOT NULL,
    [RetryCounter]         INT          NULL,
    [IsActive]             BIT          CONSTRAINT [DF_PartnerCallback_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]           DATETIME     CONSTRAINT [DF_PartnerCallback_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]             INT          CONSTRAINT [DF_PartnerCallback_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]           DATETIME     CONSTRAINT [DF_PartnerCallback_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]             INT          CONSTRAINT [DF_PartnerCallback_ModifyBy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PartnerCallback] PRIMARY KEY CLUSTERED ([PartnerCallbackId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY],
    CONSTRAINT [FK_PartnerCallback_Partner] FOREIGN KEY ([PartnerId]) REFERENCES [dbo].[Partner] ([PartnerId])
) ON [PRIMARY];

