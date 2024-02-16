CREATE TABLE [dbo].[Partner] (
    [PartnerId]          INT           IDENTITY (1, 1) NOT NULL,
    [PartnerName]        VARCHAR (100) NOT NULL,
    [PartnerDescription] VARCHAR (200) NULL,
    [IsActive]           BIT           CONSTRAINT [DF_Partner_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]         DATETIME      CONSTRAINT [DF_Partner_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]           INT           CONSTRAINT [DF_Partner_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]         DATETIME      CONSTRAINT [DF_Partner_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]           INT           CONSTRAINT [DF_Partner_ModifyBy] DEFAULT ((0)) NOT NULL,
    [PartnerGroupingId]  INT           DEFAULT (NULL) NULL,
    CONSTRAINT [PK_Partner] PRIMARY KEY CLUSTERED ([PartnerId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

