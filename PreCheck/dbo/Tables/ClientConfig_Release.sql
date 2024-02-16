CREATE TABLE [dbo].[ClientConfig_Release] (
    [ClientConfig_ReleaseID]   INT            IDENTITY (1, 1) NOT NULL,
    [CLNO]                     INT            NOT NULL,
    [ShortRelease]             BIT            CONSTRAINT [DF_ClientConfig_Release_ShortRelease] DEFAULT ('False') NOT NULL,
    [ContactPresentEmployer]   BIT            CONSTRAINT [DF_ClientConfig_Release_ContactPresentEmployer] DEFAULT ('True') NOT NULL,
    [DisplayEducation]         BIT            CONSTRAINT [DF_ClientConfig_Release_DisplayEducation] DEFAULT ('True') NOT NULL,
    [DisplayLicense]           BIT            CONSTRAINT [DF_ClientConfig_Release_DisplayLicense] DEFAULT ('True') NOT NULL,
    [ClientDisclosure]         VARCHAR (2500) NULL,
    [ReleaseNotificationEmail] VARCHAR (100)  NULL,
    [DisplayCriminal]          BIT            CONSTRAINT [DF_ClientConfig_Release_DisplayCriminal] DEFAULT ((1)) NOT NULL,
    [CriminalQuestion]         VARCHAR (8000) CONSTRAINT [DF_ClientConfig_Release_CriminalQuestion] DEFAULT ('*Have you ever been convicted of a crime?') NOT NULL,
    [CustomHardCopyHeader]     VARCHAR (1000) NULL,
    CONSTRAINT [PK_ClientConfig_Release] PRIMARY KEY CLUSTERED ([ClientConfig_ReleaseID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ClientConfig_Release_CLNO]
    ON [dbo].[ClientConfig_Release]([CLNO] ASC) WITH (FILLFACTOR = 70);

