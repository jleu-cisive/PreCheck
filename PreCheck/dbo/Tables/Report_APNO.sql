﻿CREATE TABLE [dbo].[Report_APNO] (
    [APNO] INT NOT NULL
);


GO
CREATE CLUSTERED INDEX [IX_Report_APNO_01]
    ON [dbo].[Report_APNO]([APNO] ASC) WITH (FILLFACTOR = 50);

