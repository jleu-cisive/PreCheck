﻿CREATE TABLE [dbo].[Texts] (
    [TextID]    SMALLINT NOT NULL,
    [TextValue] TEXT     NULL,
    CONSTRAINT [PK_Texts] PRIMARY KEY CLUSTERED ([TextID] ASC) WITH (FILLFACTOR = 50)
) TEXTIMAGE_ON [PRIMARY];

