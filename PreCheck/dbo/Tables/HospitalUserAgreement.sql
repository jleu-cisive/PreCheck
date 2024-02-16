CREATE TABLE [dbo].[HospitalUserAgreement] (
    [HospitalUserAgreementID] INT            IDENTITY (1, 1) NOT NULL,
    [text]                    VARCHAR (8000) NULL,
    [version]                 VARCHAR (5)    NULL,
    CONSTRAINT [PK_HospitalUserAgreement] PRIMARY KEY CLUSTERED ([HospitalUserAgreementID] ASC) WITH (FILLFACTOR = 50)
);

