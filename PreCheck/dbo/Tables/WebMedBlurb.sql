CREATE TABLE [dbo].[WebMedBlurb] (
    [Medblurbid] INT          IDENTITY (1, 1) NOT NULL,
    [Blurb]      TEXT         NULL,
    [category]   VARCHAR (50) NULL,
    CONSTRAINT [PK_WebMedBlurb] PRIMARY KEY CLUSTERED ([Medblurbid] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

