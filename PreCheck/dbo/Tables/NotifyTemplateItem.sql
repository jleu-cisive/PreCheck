CREATE TABLE [dbo].[NotifyTemplateItem] (
    [NotifyTemplateItemId] INT           IDENTITY (1, 1) NOT NULL,
    [NotifyTemplateID]     INT           NOT NULL,
    [ContentType]          VARCHAR (100) NOT NULL,
    [Content]              VARCHAR (MAX) NULL,
    [CreatedBy]            VARCHAR (50)  CONSTRAINT [DF_EmailSourceTemplateItem_CreatedBy] DEFAULT (suser_sname()) NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_EmailSourceTemplateItem_CreatedDate] DEFAULT (getdate()) NULL,
    [ModifiedBy]           VARCHAR (50)  CONSTRAINT [DF_EmailSourceTemplateItem_ModifiedBy] DEFAULT (suser_sname()) NULL,
    [ModifiedDate]         DATETIME      CONSTRAINT [DF_EmailSourceTemplateItem_ModifyDate] DEFAULT (getdate()) NULL,
    [DisplayOrder]         INT           NULL,
    PRIMARY KEY CLUSTERED ([NotifyTemplateItemId] ASC),
    CONSTRAINT [FK_EmailSourceTemplate_EmailSourceTemplateItem] FOREIGN KEY ([NotifyTemplateID]) REFERENCES [dbo].[NotifyTemplate] ([NotifyTemplateId])
);

