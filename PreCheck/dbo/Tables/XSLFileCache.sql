CREATE TABLE [dbo].[XSLFileCache] (
    [XSLFileCacheID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]           INT          NULL,
    [XSLName]        VARCHAR (30) NULL,
    [XSLData]        TEXT         NULL,
    [XSLTFileData]   XML          NULL,
    [XSLTNameSpace]  VARCHAR (50) NULL,
    CONSTRAINT [PK_XSLFileCache] PRIMARY KEY CLUSTERED ([XSLFileCacheID] ASC)
) TEXTIMAGE_ON [PRIMARY];

