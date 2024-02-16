CREATE TABLE [dbo].[WinServiceSsnBlurb] (
    [WinServiceSsnBlurbID] INT          IDENTITY (1, 1) NOT NULL,
    [Blurb]                TEXT         NULL,
    [Name]                 VARCHAR (25) NULL,
    CONSTRAINT [PK_WinServiceSsnBlurb] PRIMARY KEY CLUSTERED ([WinServiceSsnBlurbID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

