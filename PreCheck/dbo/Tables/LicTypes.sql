﻿CREATE TABLE [dbo].[LicTypes] (
    [Lic_Type] VARCHAR (30) NOT NULL,
    CONSTRAINT [PK_LicTypes] PRIMARY KEY NONCLUSTERED ([Lic_Type] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA]
) ON [PRIMARY];

