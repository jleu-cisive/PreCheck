CREATE TABLE [dbo].[SexOffenderBlurb] (
    [SexOffenderBlurbID] INT            IDENTITY (1, 1) NOT NULL,
    [State]              VARCHAR (2)    NULL,
    [Blurb]              VARCHAR (1000) NULL,
    CONSTRAINT [PK_SexOffenderBlurb] PRIMARY KEY CLUSTERED ([SexOffenderBlurbID] ASC) WITH (FILLFACTOR = 50)
);

