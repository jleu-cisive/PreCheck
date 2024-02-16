CREATE TABLE [dbo].[BusinessRule] (
    [BRNumber]      VARCHAR (10) NOT NULL,
    [BRTitle]       VARCHAR (50) NOT NULL,
    [BRDescription] TEXT         NULL,
    CONSTRAINT [PK_BusinessRule] PRIMARY KEY CLUSTERED ([BRNumber] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

