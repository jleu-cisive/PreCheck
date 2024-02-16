CREATE TABLE [dbo].[CrimVendorURL] (
    [CrimVendorURLID] INT           IDENTITY (1, 1) NOT NULL,
    [R_ID]            INT           NOT NULL,
    [URL]             VARCHAR (255) NULL,
    [DynamicURL]      BIT           NULL,
    [LastName]        VARCHAR (50)  NULL,
    [FirstName]       VARCHAR (50)  NULL,
    [MiddleName]      VARCHAR (50)  NULL,
    [SSN]             VARCHAR (50)  NULL,
    [SSN_Last4]       VARCHAR (50)  NULL,
    [DOB_Month]       VARCHAR (50)  NULL,
    [DOB_Day]         VARCHAR (50)  NULL,
    [DOB_Year]        VARCHAR (50)  NULL,
    [DOB_Full]        VARCHAR (50)  NULL,
    [SubmitButton]    VARCHAR (50)  NULL,
    CONSTRAINT [PK_CrimVendorURL] PRIMARY KEY CLUSTERED ([CrimVendorURLID] ASC) WITH (FILLFACTOR = 50)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to table, dbo.Iris_Researchers.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CrimVendorURL', @level2type = N'COLUMN', @level2name = N'R_ID';

