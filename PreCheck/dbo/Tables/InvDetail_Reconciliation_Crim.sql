CREATE TABLE [dbo].[InvDetail_Reconciliation_Crim] (
    [InvReconID]         INT           IDENTITY (1, 1) NOT NULL,
    [VendorId]           INT           NOT NULL,
    [IntegratedVendorId] INT           NULL,
    [APNO]               INT           NOT NULL,
    [SectionKeyId]       INT           NOT NULL,
    [SubKeyId]           INT           NULL,
    [SectionId]          INT           NOT NULL,
    [FeeTypeId]          SMALLINT      NOT NULL,
    [Amount]             SMALLMONEY    DEFAULT ((0)) NULL,
    [Surcharge]          SMALLMONEY    DEFAULT ((0)) NULL,
    [EnteredBy]          VARCHAR (50)  NULL,
    [EnteredVia]         VARCHAR (50)  NULL,
    [InvDetID]           INT           NULL,
    [Description]        VARCHAR (100) NULL,
    [Isactive]           BIT           DEFAULT ((1)) NULL,
    [CreateDate]         DATETIME      DEFAULT (getdate()) NULL,
    [CreateBy]           INT           DEFAULT ((0)) NULL,
    [ModifyDate]         DATETIME      DEFAULT (getdate()) NULL,
    [ModifyBy]           INT           DEFAULT ((0)) NULL,
    [ReturnedDate]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InvReconID] ASC) ON [PRIMARY],
    CONSTRAINT [FK_InvRecon_Crim_APNO] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_InvRecon_Crim_FeeTypeId] FOREIGN KEY ([FeeTypeId]) REFERENCES [dbo].[FeeType] ([FeeTypeId]),
    CONSTRAINT [FK_InvRecon_Crim_SectionId] FOREIGN KEY ([SectionId]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [idx_invdetrecon_Crim_apno]
    ON [dbo].[InvDetail_Reconciliation_Crim]([APNO] ASC)
    ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [idx_invdetrecon_Crim_sectionkeyid]
    ON [dbo].[InvDetail_Reconciliation_Crim]([SectionKeyId] ASC)
    ON [PRIMARY];

