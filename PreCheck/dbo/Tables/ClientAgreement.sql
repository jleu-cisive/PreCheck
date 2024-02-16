CREATE TABLE [dbo].[ClientAgreement] (
    [ClientAgreementID] INT       IDENTITY (1, 1) NOT NULL,
    [CLNO]              SMALLINT  NOT NULL,
    [ClientContactID]   INT       NULL,
    [AgreeDate]         DATETIME  NULL,
    [AgreementVersion]  CHAR (50) NULL,
    CONSTRAINT [PK_ClientAgreement] PRIMARY KEY CLUSTERED ([ClientAgreementID] ASC) WITH (FILLFACTOR = 50)
);

