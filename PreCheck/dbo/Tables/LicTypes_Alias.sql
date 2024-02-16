CREATE TABLE [dbo].[LicTypes_Alias] (
    [LiceTypeAliasId] INT          IDENTITY (1, 1) NOT NULL,
    [LicType]         VARCHAR (50) NULL,
    [LicTypeAlias]    VARCHAR (50) NULL
) ON [PRIMARY];

