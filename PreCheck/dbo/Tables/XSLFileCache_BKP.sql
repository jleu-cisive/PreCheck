CREATE TABLE [dbo].[XSLFileCache_BKP] (
    [XSLFileCacheID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]           INT          NULL,
    [XSLName]        VARCHAR (30) NULL,
    [XSLData]        TEXT         NULL,
    [XSLTFileData]   XML          NULL,
    [XSLTNameSpace]  VARCHAR (50) NULL
);

