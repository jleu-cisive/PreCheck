CREATE TABLE [dbo].[ClientRates] (
    [ClientRatesID] INT         IDENTITY (1, 1) NOT NULL,
    [CLNO]          SMALLINT    NOT NULL,
    [RateType]      VARCHAR (4) NOT NULL,
    [ServiceID]     INT         NULL,
    [Rate]          SMALLMONEY  NULL,
    CONSTRAINT [PK_ClientRates_1] PRIMARY KEY CLUSTERED ([ClientRatesID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientRates_Client] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO]),
    CONSTRAINT [FK_ClientRates_DefaultRates] FOREIGN KEY ([ServiceID]) REFERENCES [dbo].[DefaultRates] ([ServiceID]),
    CONSTRAINT [PK_ClientRates] UNIQUE NONCLUSTERED ([CLNO] ASC, [RateType] ASC) WITH (FILLFACTOR = 50) ON [FG_INDEX]
);

