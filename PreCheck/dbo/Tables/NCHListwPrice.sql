CREATE TABLE [dbo].[NCHListwPrice] (
    [SchoolName]             NVARCHAR (500) NULL,
    [SchoolCode]             NVARCHAR (50)  NULL,
    [City]                   NVARCHAR (50)  NULL,
    [State]                  NVARCHAR (50)  NULL,
    [ActivationDate]         NVARCHAR (50)  NULL,
    [FeesRetailandCorporate] NVARCHAR (50)  NULL,
    [FeesColleague]          NVARCHAR (50)  NULL
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_NCHListwPrice_SchoolCode]
    ON [dbo].[NCHListwPrice]([SchoolCode] ASC)
    INCLUDE([FeesRetailandCorporate]) WITH (FILLFACTOR = 70)
    ON [PRIMARY];

