CREATE TABLE [dbo].[refZipCrimLeadTypes] (
    [refZipCrimLeadTypeID] VARCHAR (6)   NOT NULL,
    [Category]             VARCHAR (30)  NOT NULL,
    [LeadTypeName]         VARCHAR (200) NOT NULL,
    [ApplSectionID]        INT           NULL,
    [IsActive]             BIT           NOT NULL,
    [CreateDate]           DATETIME2 (3) CONSTRAINT [DF_refZipCrimLeadTypes_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (100) CONSTRAINT [DF_refZipCrimLeadTypes_CreatedBy] DEFAULT (app_name()) NOT NULL,
    [ModifyDate]           DATETIME2 (3) NULL,
    [ModifiedBy]           VARCHAR (100) NULL,
    CONSTRAINT [PK_refZipCrimLeadTypes_refZipCrimLeadTypeID] PRIMARY KEY CLUSTERED ([refZipCrimLeadTypeID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_refZipCrimLeadTypes_ApplSections_ApplSectionID] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);

