CREATE TABLE [dbo].[FeeTypeBySection] (
    [FeeTypeBySectionId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [FeeTypeId]          SMALLINT NOT NULL,
    [ThirdPartyVendorId] INT      NOT NULL,
    [BillToClient]       BIT      NULL,
    [SectionId]          INT      NOT NULL,
    [Isactive]           BIT      NULL,
    [CreateDate]         DATETIME NULL,
    [CreateBy]           INT      NULL,
    [ModifyDate]         DATETIME NULL,
    [ModifyBy]           INT      NULL,
    PRIMARY KEY CLUSTERED ([FeeTypeBySectionId] ASC) ON [PRIMARY],
    CONSTRAINT [FK_BySection_FeeTypeId] FOREIGN KEY ([FeeTypeId]) REFERENCES [dbo].[FeeType] ([FeeTypeId]),
    CONSTRAINT [FK_BySection_SectionId] FOREIGN KEY ([SectionId]) REFERENCES [dbo].[ApplSections] ([ApplSectionID]),
    CONSTRAINT [FK_BySection_ThirdPartyVendorId] FOREIGN KEY ([ThirdPartyVendorId]) REFERENCES [dbo].[ThirdPartyVendors] ([ThirdPartyVendorId])
) ON [PRIMARY];

