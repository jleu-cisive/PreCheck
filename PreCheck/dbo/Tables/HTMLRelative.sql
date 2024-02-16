CREATE TABLE [dbo].[HTMLRelative] (
    [HTMLRelativeID]   INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]             INT           NULL,
    [Section]          VARCHAR (30)  NULL,
    [StartIdentifier]  VARCHAR (255) NULL,
    [NextIdentifier]   VARCHAR (255) NULL,
    [AltIdentifier]    VARCHAR (255) NULL,
    [Jump1]            VARCHAR (255) NULL,
    [IsRelativeStatic] BIT           CONSTRAINT [DF_HTMLRelative_IsRelativeStatic] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_HTMLRelative] PRIMARY KEY CLUSTERED ([HTMLRelativeID] ASC) WITH (FILLFACTOR = 50)
);

