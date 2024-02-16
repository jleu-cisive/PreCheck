CREATE TABLE [dbo].[DefaultRates] (
    [ServiceID]   INT          IDENTITY (1, 1) NOT NULL,
    [RateType]    VARCHAR (4)  NOT NULL,
    [DefaultRate] SMALLMONEY   NULL,
    [ServiceName] VARCHAR (20) NULL,
    CONSTRAINT [PK_DefaultRates] PRIMARY KEY NONCLUSTERED ([ServiceID] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA]
) ON [PRIMARY];

