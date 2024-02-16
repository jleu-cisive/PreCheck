CREATE TABLE [dbo].[ClientCrimRate] (
    [ClientCrimRateID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]             SMALLINT     NOT NULL,
    [County]           VARCHAR (25) NOT NULL,
    [Rate]             SMALLMONEY   CONSTRAINT [DF_ClientCrimRate_Rate] DEFAULT (0) NOT NULL,
    [CNTY_NO]          INT          NULL,
    [ExcludeFromRules] BIT          CONSTRAINT [DF_ClientCrimRate_ExcludeFromRules] DEFAULT (0) NOT NULL,
    CONSTRAINT [PK_ClientCrimRate] PRIMARY KEY CLUSTERED ([ClientCrimRateID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientCrimRate_Client] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO]),
    CONSTRAINT [FK_ClientCrimRate_Counties] FOREIGN KEY ([CNTY_NO]) REFERENCES [dbo].[TblCounties] ([CNTY_NO])
);

