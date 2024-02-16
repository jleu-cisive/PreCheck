CREATE TABLE [dbo].[EDrugScreening] (
    [APNO]  INT            NOT NULL,
    [Email] NVARCHAR (100) NOT NULL,
    [PIN]   NVARCHAR (50)  NOT NULL,
    [Flag]  BIT            CONSTRAINT [DF_EDrugScreening_Flag] DEFAULT ((0)) NOT NULL
) ON [PRIMARY];

