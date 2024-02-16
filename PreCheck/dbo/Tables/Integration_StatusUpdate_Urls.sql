CREATE TABLE [dbo].[Integration_StatusUpdate_Urls] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Apno]       INT           NOT NULL,
    [Url]        VARCHAR (300) NULL,
    [CreateDate] DATETIME      NULL
) ON [PRIMARY];

