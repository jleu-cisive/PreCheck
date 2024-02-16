CREATE TABLE [dbo].[refReasonForContact] (
    [refReasonForContactID] INT           IDENTITY (1, 1) NOT NULL,
    [ItemName]              VARCHAR (100) NOT NULL,
    [Description]           VARCHAR (MAX) NULL,
    [ApplSectionID]         INT           NULL,
    [DisplayOrder]          INT           NOT NULL,
    [IsActive]              BIT           NOT NULL,
    [CreateDate]            DATETIME2 (3) CONSTRAINT [DF_refReasonForContact_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]              VARCHAR (100) NOT NULL,
    [ModifyDate]            DATETIME2 (3) NULL,
    [ModifyBy]              VARCHAR (100) NULL,
    CONSTRAINT [PK_refReasonForContact_refReasonForContactID] PRIMARY KEY CLUSTERED ([refReasonForContactID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_refReasonForContact_ApplSections_ApplSectionID] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);

