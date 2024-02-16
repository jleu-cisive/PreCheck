CREATE TABLE [dbo].[zzBkUp_VendorAccounts_09292022] (
    [VendorAccountId]              INT            IDENTITY (1, 1) NOT NULL,
    [VendorAccountName]            VARCHAR (50)   NULL,
    [UserName]                     VARCHAR (100)  NULL,
    [Password]                     VARCHAR (50)   NULL,
    [ServiceType]                  VARCHAR (50)   NULL,
    [LastUpdated]                  DATETIME       NULL,
    [IsActive]                     BIT            NULL,
    [ConfigSettings]               XML            NULL,
    [XsltFrom]                     XML            NULL,
    [XsltTo]                       XML            NULL,
    [AIMSTypeFullName]             VARCHAR (1000) NULL,
    [AssemblyFullName]             VARCHAR (1000) NULL,
    [PCuid]                        VARCHAR (1000) NULL,
    [PCPass]                       VARCHAR (1000) NULL,
    [PasswordLastUpdated]          DATETIME       NULL,
    [PasswordChangeIntervalInDays] INT            NULL
);

