CREATE TABLE [dbo].[ClientDisclosure] (
    [ClientDisclosureId] INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]               INT           NULL,
    [DisclosureTypeId]   INT           NULL,
    [DisclosureBlurb]    VARCHAR (MAX) NULL,
    CONSTRAINT [PK_ClientDisclosure] PRIMARY KEY CLUSTERED ([ClientDisclosureId] ASC)
);

