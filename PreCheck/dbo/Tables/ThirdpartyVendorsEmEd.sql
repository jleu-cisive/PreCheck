CREATE TABLE [dbo].[ThirdpartyVendorsEmEd] (
    [ThirdpartyVendorsEmEdid] INT          IDENTITY (1, 1) NOT NULL,
    [ThirdPartyVendorId]      INT          NOT NULL,
    [SectionKeyId]            INT          NOT NULL,
    [Apno]                    INT          NULL,
    [SectionId]               INT          NOT NULL,
    [EnteredBy]               VARCHAR (50) NULL,
    [EnteredVia]              VARCHAR (50) NULL,
    [Isactive]                BIT          DEFAULT ((1)) NULL,
    [CreateDate]              DATETIME     DEFAULT (getdate()) NULL,
    [CreateBy]                INT          DEFAULT ((0)) NULL,
    [ModifyDate]              DATETIME     DEFAULT (getdate()) NULL,
    [ModifyBy]                INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ThirdpartyVendorsEmEdid] ASC) ON [PRIMARY],
    CONSTRAINT [FK_ThirdParty_SectionId] FOREIGN KEY ([SectionId]) REFERENCES [dbo].[ApplSections] ([ApplSectionID]),
    CONSTRAINT [FK_ThirdParty_VendorId] FOREIGN KEY ([ThirdPartyVendorId]) REFERENCES [dbo].[ThirdPartyVendors] ([ThirdPartyVendorId])
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [idx_ThirdPartyEmEd_Senctionkey]
    ON [dbo].[ThirdpartyVendorsEmEd]([SectionKeyId] ASC)
    ON [PRIMARY];

