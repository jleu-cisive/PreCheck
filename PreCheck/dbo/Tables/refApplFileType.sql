CREATE TABLE [dbo].[refApplFileType] (
    [refApplFileTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]       VARCHAR (100) NOT NULL,
    [Abbreviation]      VARCHAR (20)  NOT NULL,
    [IsAppLevel]        BIT           CONSTRAINT [DF_refApplFileType_IsAppLevel] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_refApplFileType] PRIMARY KEY CLUSTERED ([refApplFileTypeID] ASC) WITH (FILLFACTOR = 50)
);

