CREATE TABLE [dbo].[JobsUpload] (
    [JobsUploadID] INT           IDENTITY (1, 1) NOT NULL,
    [Department]   VARCHAR (50)  NULL,
    [JobTitle]     VARCHAR (200) NULL,
    [FileName]     VARCHAR (200) NULL,
    [URL]          VARCHAR (200) NULL,
    CONSTRAINT [PK_JobUpload] PRIMARY KEY CLUSTERED ([JobsUploadID] ASC) WITH (FILLFACTOR = 50)
);

