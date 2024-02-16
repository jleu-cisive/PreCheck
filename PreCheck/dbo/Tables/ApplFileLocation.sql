CREATE TABLE [dbo].[ApplFileLocation] (
    [ApplFileLocationID] INT           IDENTITY (1, 1) NOT NULL,
    [APNOStart]          INT           NULL,
    [APNOEnd]            INT           NULL,
    [FilePath]           VARCHAR (150) NULL,
    [GroupSize]          INT           NULL,
    [SubFolder]          VARCHAR (100) NULL,
    [refApplTypeID]      INT           NOT NULL,
    [SearchRoot]         BIT           NULL,
    CONSTRAINT [PK_ApplFileLocation] PRIMARY KEY CLUSTERED ([ApplFileLocationID] ASC) WITH (FILLFACTOR = 50)
);

