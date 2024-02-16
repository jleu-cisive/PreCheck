CREATE TABLE [dbo].[PartnerConfig_FromProd10242022] (
    [PartnerConfigId]              INT            NOT NULL,
    [PartnerId]                    INT            NOT NULL,
    [TransformRequest]             BIT            NULL,
    [TransformResponse]            BIT            NULL,
    [ConfigSettings]               NVARCHAR (MAX) NULL,
    [PartnerOperation]             VARCHAR (100)  NULL,
    [CallbackMethod]               VARCHAR (100)  NULL,
    [PasswordLastUpdated]          DATETIME       NULL,
    [PasswordChangeIntervalInDays] INT            NULL,
    [IsJson]                       BIT            NULL,
    [IsActive]                     BIT            NOT NULL,
    [CreateDate]                   DATETIME       NOT NULL,
    [CreateBy]                     INT            NOT NULL,
    [ModifyDate]                   DATETIME       NOT NULL,
    [ModifyBy]                     INT            NOT NULL,
    [TransformSchema]              NVARCHAR (MAX) NULL,
    [PartnerGroupingId]            INT            NULL
);

