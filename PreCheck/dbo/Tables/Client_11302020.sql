CREATE TABLE [dbo].[Client_11302020] (
    [CLNO]                           SMALLINT      IDENTITY (1602, 1) NOT NULL,
    [Name]                           VARCHAR (100) NULL,
    [Addr1]                          VARCHAR (100) NULL,
    [Addr2]                          VARCHAR (100) NULL,
    [Addr3]                          VARCHAR (25)  NULL,
    [City]                           VARCHAR (50)  NULL,
    [State]                          VARCHAR (20)  NULL,
    [Zip]                            VARCHAR (20)  NULL,
    [Phone]                          VARCHAR (20)  NULL,
    [Fax]                            VARCHAR (20)  NULL,
    [Contact]                        VARCHAR (25)  NULL,
    [Email]                          VARCHAR (35)  NULL,
    [HomeCounty]                     VARCHAR (25)  NULL,
    [TaxRate]                        SMALLMONEY    NULL,
    [Status]                         CHAR (1)      CONSTRAINT [DF_Client_Status_new1] DEFAULT ('N') NOT NULL,
    [BillCycle]                      CHAR (2)      NOT NULL,
    [FirstApdate]                    DATETIME      NULL,
    [LastInvDate]                    DATETIME      NULL,
    [LastInvAmount]                  SMALLMONEY    NULL,
    [CNTY_NO]                        INT           NULL,
    [AffiliateID]                    INT           NULL,
    [CAM]                            VARCHAR (8)   NULL,
    [TeamID]                         INT           NULL,
    [Investigator1]                  VARCHAR (8)   NULL,
    [Investigator2]                  VARCHAR (8)   NULL,
    [HighProfile]                    BIT           CONSTRAINT [DF_Client_HighProfile_new1] DEFAULT ((0)) NULL,
    [CountyCrimID]                   INT           NULL,
    [CountyCrimNotesID]              INT           NULL,
    [StateCrimNotesID]               INT           NULL,
    [Social]                         BIT           CONSTRAINT [DF_Client_Social_new1] DEFAULT ((0)) NULL,
    [MVR]                            VARCHAR (50)  NULL,
    [Medicaid/Medicare]              BIT           CONSTRAINT [DF_Client_Medicaid/Medicare_new1] DEFAULT ((0)) NULL,
    [EmploymentID]                   INT           NULL,
    [EmploymentNotes1ID]             INT           NULL,
    [EmploymentNotes2ID]             INT           NULL,
    [EducationNotesID]               INT           NULL,
    [LicenseNotesID]                 INT           NULL,
    [CreditNotesID]                  INT           NULL,
    [PersonalRefNotes]               VARCHAR (50)  NULL,
    [Comments]                       TEXT          NULL,
    [DeliveryMethodID]               INT           NULL,
    [BillingCycleID]                 INT           NULL,
    [BillingStatusID]                INT           NULL,
    [IsInactive]                     BIT           CONSTRAINT [DF_Client_IsActive_new1] DEFAULT ((0)) NOT NULL,
    [IsOnCreditHold]                 BIT           CONSTRAINT [DF_Client_IsOnCreditHold_new1] DEFAULT ((0)) NOT NULL,
    [AttnTo]                         VARCHAR (50)  NULL,
    [BillingAddress1]                VARCHAR (50)  NULL,
    [BillingAddress2]                VARCHAR (50)  NULL,
    [BillingCity]                    VARCHAR (30)  NULL,
    [BillingState]                   VARCHAR (20)  NULL,
    [BillingZip]                     VARCHAR (20)  NULL,
    [PrintLabel]                     BIT           NULL,
    [TaxStatusID]                    INT           NULL,
    [TaxRateID]                      INT           NULL,
    [IsTaxExempt]                    BIT           CONSTRAINT [DF_Client_IsTaxExempt_new1] DEFAULT ((0)) NOT NULL,
    [TaxExemptionNumber]             VARCHAR (15)  NULL,
    [TaxExempVerifiedDate]           DATETIME      NULL,
    [TaxExemptVerifiedUserID]        VARCHAR (8)   NULL,
    [TaxLocaleID]                    INT           NULL,
    [SalesPersonUserID]              VARCHAR (8)   NULL,
    [CustomerRatingID]               INT           NULL,
    [HolidayGift]                    BIT           NULL,
    [password]                       VARCHAR (20)  NULL,
    [HEVNEmployerStatusID]           INT           CONSTRAINT [DF_Client_HEVNEmployerStatusID_new1] DEFAULT ((1)) NOT NULL,
    [HEVNEmployerInternal]           BIT           CONSTRAINT [DF_Client_HEVNEmployerInternal_new1] DEFAULT ((0)) NULL,
    [HEVNPayrollNotes]               VARCHAR (500) NULL,
    [ParentCLNO]                     SMALLINT      NULL,
    [CompanyLogoPath]                VARCHAR (100) NULL,
    [NonClient]                      BIT           CONSTRAINT [DF_Client_NonClient_new1] DEFAULT ((0)) NULL,
    [DescriptiveName]                VARCHAR (100) NULL,
    [Medical]                        BIT           CONSTRAINT [DF_Client_Medical_new1] DEFAULT ((1)) NULL,
    [OneCountyPricing]               BIT           CONSTRAINT [DF_Client_OneCountyPricing_new1] DEFAULT ((0)) NULL,
    [OneCountyPrice]                 MONEY         CONSTRAINT [DF_Client_OneCountyPrice_new1] DEFAULT ((0)) NULL,
    [LmsEmployer]                    BIT           CONSTRAINT [DF_Client_LmsEmployer_new1] DEFAULT ((0)) NULL,
    [Lms_FileGrouping_Preference]    VARCHAR (50)  CONSTRAINT [DF_Client_Lms_FileGrouping_Preference_new1] DEFAULT ('FacilityBulk') NULL,
    [LmsLetter1]                     INT           CONSTRAINT [DF_Client_LmsLetter1_new1] DEFAULT ((60)) NULL,
    [LmsLetter2]                     INT           CONSTRAINT [DF_Client_LmsLetter2_new1] DEFAULT ((12)) NULL,
    [LmsLetter3]                     INT           CONSTRAINT [DF_Client_LmsLetter3_new1] DEFAULT ((0)) NULL,
    [LmsInitialCleanupDone]          BIT           CONSTRAINT [DF_Client_LmsInitialCleanupDone_new1] DEFAULT ((0)) NULL,
    [LmsInitialCleanupDoneDateStamp] DATETIME      NULL,
    [LmsCanPrintCertificates]        BIT           CONSTRAINT [DF_Client_LmsCanPrintCertificates_new1] DEFAULT ((0)) NULL,
    [EmplEmployerNotes]              TEXT          NULL,
    [EmplClientNotes]                TEXT          NULL,
    [AppTrackerEmployer]             BIT           CONSTRAINT [DF_Client_AppTrackerEmployer_new1] DEFAULT ((0)) NULL,
    [Adverse]                        INT           NULL,
    [CertificateLetter1]             INT           CONSTRAINT [DF_Client_CertificateLetter1_new1] DEFAULT ((90)) NULL,
    [CertificateLetter2]             INT           CONSTRAINT [DF_Client_CertificateLetter2_new1] DEFAULT ((60)) NULL,
    [ClientEntry]                    DATETIME      CONSTRAINT [DF_Client_ClientEntry_new1] DEFAULT (getdate()) NULL,
    [UserAgreementDate]              DATETIME      NULL,
    [AutoReportDelivery]             BIT           CONSTRAINT [DF_Client_AutoReportDelivery_new1] DEFAULT ((0)) NULL,
    [ClientTypeID]                   INT           NULL,
    [CredentCheckCam]                VARCHAR (50)  NULL,
    [WebOrderParentCLNO]             INT           NULL,
    [IsOnSchoolDroplist]             BIT           CONSTRAINT [DF_Client_IsOnSchoolDroplist_new1] DEFAULT ((0)) NULL,
    [EmplInvestigatorByClient1]      VARCHAR (8)   NULL,
    [EmplInvestigatorByClient2]      VARCHAR (8)   NULL,
    [PersRefInvestigator1]           VARCHAR (8)   NULL,
    [PersRefInvestigator2]           VARCHAR (8)   NULL,
    [GetsEmpl_StudentCheck]          BIT           CONSTRAINT [DF_Client_GetsEmpl_StudentCheck_new1] DEFAULT ((0)) NOT NULL,
    [GetsProfLic_StudentCheck]       BIT           CONSTRAINT [DF_Client_GetsProfLic_StudentCheck_new1] DEFAULT ((0)) NOT NULL,
    [SchoolWillPay]                  BIT           CONSTRAINT [DF_Client_SchoolWillPay_new1] DEFAULT ((0)) NOT NULL,
    [AgreementIsRequired]            BIT           CONSTRAINT [DF_Client_AgreementIsRequired_new1] DEFAULT ((0)) NOT NULL,
    [AutoLinkHospitals]              BIT           CONSTRAINT [DF_Client_AutoLinkHospitals_new1] DEFAULT ((0)) NOT NULL,
    [AreNewLicensesSeparate]         BIT           CONSTRAINT [DF_Client_AreNewLicensesSeparate_new1] DEFAULT ((1)) NOT NULL,
    [CredentCheckEmployerStatusID]   INT           NULL,
    [LmsAutomateRunClosures]         BIT           CONSTRAINT [DF__CLIENT__LmsAutom__636F8578_new1] DEFAULT ((0)) NOT NULL,
    [GetsEdu_StudentCheck]           BIT           CONSTRAINT [DF_Client_GetsEdu_StudentCheck_new1] DEFAULT ((0)) NOT NULL,
    [EduInvestigator1]               VARCHAR (8)   NULL,
    [EduInvestigator2]               VARCHAR (8)   NULL,
    [OKtoContact]                    BIT           CONSTRAINT [DF__Client__OKtoCont__581DCE5D_new1] DEFAULT ((0)) NULL,
    [EmplInvestigatorByClient3]      VARCHAR (8)   NULL,
    [EmplInvestigatorByClient4]      VARCHAR (8)   NULL,
    [EmplInvestigatorByEmployer1]    VARCHAR (8)   NULL,
    [EmplInvestigatorByEmployer2]    VARCHAR (8)   NULL,
    [IsNameMismatchADeficiency]      BIT           CONSTRAINT [DF_Client_IsNameMismatchADeficiency_new1] DEFAULT ((1)) NOT NULL,
    [WebSite]                        VARCHAR (250) NULL,
    [CreatedDate]                    DATETIME      CONSTRAINT [DF_Client_CreatedDate_new1] DEFAULT (getdate()) NULL,
    [MVRService]                     BIT           CONSTRAINT [DF_Client_MVRService_new1] DEFAULT ((0)) NOT NULL,
    [MvrID]                          INT           NULL,
    [AffiliateID_PO]                 INT           NULL,
    [ZipCrimClientID]                VARCHAR (6)   NULL,
    [Accounting System Grouping]     VARCHAR (200) NULL,
    [Customer-Vendor]                VARCHAR (200) NULL,
    [Revenue Frequency]              VARCHAR (200) NULL,
    CONSTRAINT [PK_Client_new1] PRIMARY KEY CLUSTERED ([CLNO] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Client_Counties_new1] FOREIGN KEY ([CNTY_NO]) REFERENCES [dbo].[TblCounties] ([CNTY_NO])
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [Client_CLNO_AutoReportDelivery]
    ON [dbo].[Client_11302020]([AutoReportDelivery] ASC, [CLNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [Client_HEVNEmployerInternal]
    ON [dbo].[Client_11302020]([HEVNEmployerInternal] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [Client_HEVNEmployerStatusID]
    ON [dbo].[Client_11302020]([HEVNEmployerStatusID] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [Client_LmsEmployer]
    ON [dbo].[Client_11302020]([LmsEmployer] ASC)
    INCLUDE([CredentCheckEmployerStatusID]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IDX_Client_WebOrderParentCLNO]
    ON [dbo].[Client_11302020]([WebOrderParentCLNO] ASC, [IsInactive] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_Client_02]
    ON [dbo].[Client_11302020]([HEVNEmployerStatusID] ASC, [HEVNEmployerInternal] ASC, [LmsEmployer] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_Client_CredentCheckEmployerStatusID]
    ON [dbo].[Client_11302020]([CredentCheckEmployerStatusID] ASC)
    INCLUDE([CLNO], [HEVNEmployerStatusID], [HEVNEmployerInternal], [LmsEmployer]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_Client_IsInactive_Inc]
    ON [dbo].[Client_11302020]([IsInactive] ASC)
    INCLUDE([CLNO], [Name], [AffiliateID], [WebOrderParentCLNO]) WITH (FILLFACTOR = 70);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Parent Company for this client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Client_11302020', @level2type = N'COLUMN', @level2name = N'ParentCLNO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The path to the client LOGO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Client_11302020', @level2type = N'COLUMN', @level2name = N'CompanyLogoPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'For RefMod by Emplyer - means not real Client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Client_11302020', @level2type = N'COLUMN', @level2name = N'NonClient';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'For HEVN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Client_11302020', @level2type = N'COLUMN', @level2name = N'DescriptiveName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = medical', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Client_11302020', @level2type = N'COLUMN', @level2name = N'Medical';

