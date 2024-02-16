CREATE TABLE [dbo].[ApplicantContact] (
    [ApplicantContactID]           INT           IDENTITY (1, 1) NOT NULL,
    [APNO]                         INT           NOT NULL,
    [ApplSectionID]                INT           NOT NULL,
    [SectionUniqueID]              INT           NOT NULL,
    [refMethodOfContactID]         INT           NOT NULL,
    [refReasonForContactID]        INT           NOT NULL,
    [Investigator]                 VARCHAR (100) NOT NULL,
    [GotExpectedResultFromContact] BIT           NULL,
    [COntactOutcome]               VARCHAR (MAX) NULL,
    [CreateDate]                   DATETIME2 (3) CONSTRAINT [DF_ApplicantContact_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                     VARCHAR (100) NOT NULL,
    [ModifyDate]                   DATETIME2 (3) NULL,
    [ModifyBy]                     VARCHAR (100) NULL,
    CONSTRAINT [PK_ApplicantCOntact_ApplicantContactID] PRIMARY KEY CLUSTERED ([ApplicantContactID] ASC) WITH (FILLFACTOR = 70),
    FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID]),
    FOREIGN KEY ([refMethodOfContactID]) REFERENCES [dbo].[refMethodOfContact] ([refMethodOfContactID]),
    FOREIGN KEY ([refReasonForContactID]) REFERENCES [dbo].[refReasonForContact] ([refReasonForContactID]),
    CONSTRAINT [FK_ApplicantContact_Appl_APNO] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
);

