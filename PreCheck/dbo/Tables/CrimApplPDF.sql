CREATE TABLE [dbo].[CrimApplPDF] (
    [CrimApplPDFID] INT           IDENTITY (1, 1) NOT NULL,
    [APNO]          INT           NOT NULL,
    [NameSearched]  VARCHAR (150) NULL,
    [PDF]           IMAGE         NOT NULL,
    CONSTRAINT [PK_CrimApplPDF] PRIMARY KEY CLUSTERED ([CrimApplPDFID] ASC)
) TEXTIMAGE_ON [PRIMARY];

