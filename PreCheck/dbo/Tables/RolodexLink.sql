CREATE TABLE [dbo].[RolodexLink] (
    [RolodexLinkID]  INT IDENTITY (1, 1) NOT NULL,
    [refSectionCode] INT NOT NULL,
    [SectionID]      INT NOT NULL,
    [RolodexID]      INT NOT NULL,
    CONSTRAINT [PK_AutoFaxLog] PRIMARY KEY CLUSTERED ([RolodexLinkID] ASC) WITH (FILLFACTOR = 50)
);

