CREATE TABLE [dbo].[SectionAliasSearch] (
    [SectionAliasId] INT          IDENTITY (1, 1) NOT NULL,
    [SectionCode]    VARCHAR (50) NOT NULL,
    [Alias]          VARCHAR (50) NULL,
    [SectionType]    NCHAR (10)   NULL
);

