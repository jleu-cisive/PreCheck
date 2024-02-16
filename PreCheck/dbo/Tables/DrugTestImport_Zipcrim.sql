CREATE TABLE [dbo].[DrugTestImport_Zipcrim] (
    [DrugTestImport_Zipcrim_ID] SMALLINT      IDENTITY (1, 1) NOT NULL,
    [ClientID]                  VARCHAR (10)  NOT NULL,
    [CaseType]                  VARCHAR (10)  NOT NULL,
    [LastName]                  VARCHAR (100) NOT NULL,
    [FirstName]                 VARCHAR (100) NOT NULL,
    [DOB]                       DATE          NOT NULL,
    [SSN]                       VARCHAR (11)  NOT NULL,
    [Email]                     VARCHAR (100) NOT NULL,
    [Phone]                     VARCHAR (12)  NULL,
    [Addr1]                     VARCHAR (100) NULL,
    [Addr2]                     VARCHAR (100) NULL,
    [City]                      VARCHAR (100) NOT NULL,
    [State]                     VARCHAR (2)   NOT NULL,
    [Zip]                       VARCHAR (10)  NOT NULL,
    [PreCheckOrderID]           INT           NULL,
    [PreCheckCLNO]              INT           NULL,
    CONSTRAINT [PK_DrugTestImport_Zipcrim] PRIMARY KEY CLUSTERED ([DrugTestImport_Zipcrim_ID] ASC)
);

