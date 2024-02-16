CREATE TABLE [dbo].[NotifyTemplateClientItem] (
    [NotifyTemplateClientItemId] INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]                   INT           NOT NULL,
    [NotifyTemplateItemId]       INT           NOT NULL,
    [ItemContent]                VARCHAR (MAX) NULL,
    [CreatedBy]                  VARCHAR (50)  CONSTRAINT [DF_NotifyTemplateClientItem_CreatedBy] DEFAULT (suser_sname()) NULL,
    [CreatedDate]                DATETIME      CONSTRAINT [DF_NotifyTemplateClientItem_CreatedDate] DEFAULT (getdate()) NULL,
    [ModifiedBy]                 VARCHAR (50)  CONSTRAINT [DF_NotifyTemplateClientItem_ModifiedBy] DEFAULT (suser_sname()) NULL,
    [ModifiedDate]               DATETIME      CONSTRAINT [DF_NotifyTemplateClientItem_Modifieddate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_NotifyTemplateClientItem] PRIMARY KEY CLUSTERED ([NotifyTemplateClientItemId] ASC)
);

