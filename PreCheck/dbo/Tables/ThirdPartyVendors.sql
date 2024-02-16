CREATE TABLE [dbo].[ThirdPartyVendors] (
    [ThirdPartyVendorId]   INT            IDENTITY (5000, 1) NOT NULL,
    [VendorCode]           VARCHAR (100)  NULL,
    [VendorName]           VARCHAR (500)  NOT NULL,
    [ServiceFee]           SMALLMONEY     NULL,
    [PassThroughFee]       SMALLMONEY     NULL,
    [SurCharge]            SMALLMONEY     NULL,
    [ClientPassThroughFee] AS             ([PassThroughFee]+[SurCharge]),
    [Isactive]             BIT            NULL,
    [CreateDate]           DATETIME       NULL,
    [CreateBy]             INT            NULL,
    [ModifyDate]           DATETIME       NULL,
    [ModifyBy]             INT            NULL,
    [SectionId]            INT            NOT NULL,
    [Comments]             VARCHAR (1000) NULL,
    [CisiveRefId]          INT            NULL,
    [IsIntegrated]         BIT            NULL,
    PRIMARY KEY CLUSTERED ([ThirdPartyVendorId] ASC) ON [PRIMARY],
    CONSTRAINT [FK_Thirdpartyvendors_SectionId] FOREIGN KEY ([SectionId]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
) ON [PRIMARY];

