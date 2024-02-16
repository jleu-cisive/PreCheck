CREATE TABLE [dbo].[FileUploadActivity] (
    [FileUploadActivityID] INT           IDENTITY (1, 1) NOT NULL,
    [ClientFileName]       VARCHAR (300) NULL,
    [InternalFileName]     VARCHAR (300) NULL,
    [FileContent]          VARCHAR (100) NULL,
    [FileSize]             INT           NULL,
    [UploadDate]           DATETIME      NULL,
    [UserName]             VARCHAR (30)  NULL,
    [CLNO]                 INT           NULL,
    [Source]               VARCHAR (50)  NULL,
    CONSTRAINT [PK_FileUploadActivity] PRIMARY KEY CLUSTERED ([FileUploadActivityID] ASC) WITH (FILLFACTOR = 50)
);

