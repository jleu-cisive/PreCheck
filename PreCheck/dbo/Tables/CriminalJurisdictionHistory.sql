CREATE TABLE [dbo].[CriminalJurisdictionHistory] (
    [CrimJHistID]      INT          IDENTITY (1, 1) NOT NULL,
    [CrimJID]          INT          NOT NULL,
    [CrimJName]        VARCHAR (30) NOT NULL,
    [SearchSourceID]   TINYINT      NOT NULL,
    [DefaultRate]      SMALLMONEY   NOT NULL,
    [Enabled]          BIT          NOT NULL,
    [LastModifiedUser] VARCHAR (30) NOT NULL,
    [LastModifiedDate] DATETIME     NOT NULL,
    CONSTRAINT [PK_CriminalJurisdictionHistory] PRIMARY KEY CLUSTERED ([CrimJHistID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_CriminalJurisdictionHistory_CrimJID]
    ON [dbo].[CriminalJurisdictionHistory]([CrimJID] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

