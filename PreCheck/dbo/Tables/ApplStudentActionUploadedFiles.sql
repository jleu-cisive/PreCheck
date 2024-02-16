CREATE TABLE [dbo].[ApplStudentActionUploadedFiles] (
    [ApplStudentUploadedFilesID] INT      IDENTITY (1, 1) NOT NULL,
    [CLNO]                       INT      NOT NULL,
    [DateLoaded]                 DATETIME NULL,
    [File]                       IMAGE    NULL,
    [IsAddRecord]                BIT      CONSTRAINT [DF_ApplStudentActionUploadedFiles_IsAddRecord] DEFAULT ((0)) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

