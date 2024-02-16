CREATE TABLE [dbo].[PartnerConfig] (
    [PartnerConfigId]              INT            IDENTITY (1, 1) NOT NULL,
    [PartnerId]                    INT            NOT NULL,
    [TransformRequest]             BIT            NULL,
    [TransformResponse]            BIT            NULL,
    [ConfigSettings]               NVARCHAR (MAX) NULL,
    [PartnerOperation]             VARCHAR (100)  NULL,
    [CallbackMethod]               VARCHAR (100)  NULL,
    [PasswordLastUpdated]          DATETIME       NULL,
    [PasswordChangeIntervalInDays] INT            NULL,
    [IsJson]                       BIT            NULL,
    [IsActive]                     BIT            CONSTRAINT [DF_PartnerConfig_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]                   DATETIME       CONSTRAINT [DF_PartnerConfig_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                     INT            CONSTRAINT [DF_PartnerConfig_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]                   DATETIME       CONSTRAINT [DF_PartnerConfig_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                     INT            CONSTRAINT [DF_PartnerConfig_ModifyBy] DEFAULT ((0)) NOT NULL,
    [TransformSchema]              NVARCHAR (MAX) NULL,
    [PartnerGroupingId]            INT            DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PartnerConfig] PRIMARY KEY CLUSTERED ([PartnerConfigId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY],
    CONSTRAINT [FK__PartnerCo__Partn__575EB44E] FOREIGN KEY ([PartnerId]) REFERENCES [dbo].[Partner] ([PartnerId])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

