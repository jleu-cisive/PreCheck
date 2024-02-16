CREATE TABLE [dbo].[StudentCheckLog] (
    [StudentCheckLogID]  INT            IDENTITY (1, 1) NOT NULL,
    [Apno]               INT            NOT NULL,
    [Clno]               INT            NULL,
    [PackageID]          INT            NULL,
    [DrugTest]           VARCHAR (10)   NULL,
    [ClientSetup]        VARCHAR (10)   NULL,
    [NonElectronic]      VARCHAR (10)   NULL,
    [RedirectEDrugUrl]   VARCHAR (8000) NULL,
    [RedirectConfirmUrl] VARCHAR (8000) NULL,
    [BeforeAndAfter]     VARCHAR (10)   NULL,
    [CreatedDate]        DATETIME       NOT NULL
);

