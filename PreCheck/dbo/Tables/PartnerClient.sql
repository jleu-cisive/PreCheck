CREATE TABLE [dbo].[PartnerClient] (
    [PartnerClientId] INT      IDENTITY (1, 1) NOT NULL,
    [PartnerId]       INT      NOT NULL,
    [ClientId]        SMALLINT NOT NULL,
    [IsActive]        BIT      CONSTRAINT [DF_PartnerClient_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]      DATETIME CONSTRAINT [DF_PartnerClient_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]        INT      CONSTRAINT [DF_PartnerClient_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]      DATETIME CONSTRAINT [DF_PartnerClient_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]        INT      CONSTRAINT [DF_PartnerClient_ModifyBy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PartnerClient] PRIMARY KEY CLUSTERED ([PartnerClientId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY],
    CONSTRAINT [FK__PartnerCl__Clien__7306CEC3] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([CLNO]),
    CONSTRAINT [FK__PartnerCl__Partn__7212AA8A] FOREIGN KEY ([PartnerId]) REFERENCES [dbo].[Partner] ([PartnerId])
) ON [PRIMARY];

