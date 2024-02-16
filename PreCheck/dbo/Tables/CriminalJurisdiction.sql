CREATE TABLE [dbo].[CriminalJurisdiction] (
    [CrimJID]          INT          IDENTITY (1, 1) NOT NULL,
    [CrimJName]        VARCHAR (30) NOT NULL,
    [SearchSourceID]   TINYINT      NOT NULL,
    [DefaultRate]      SMALLMONEY   NOT NULL,
    [Enabled]          BIT          CONSTRAINT [DF_CriminalJurisdiction_Enabled] DEFAULT (1) NOT NULL,
    [LastModifiedUser] VARCHAR (30) NOT NULL,
    [LastModifiedDate] DATETIME     CONSTRAINT [DF_CriminalJurisdiction_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CriminalJurisdiction] PRIMARY KEY CLUSTERED ([CrimJID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_CriminalJurisdiction_SearchSource] FOREIGN KEY ([SearchSourceID]) REFERENCES [dbo].[SearchSource] ([SearchSourceID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CriminalJurisdiction_CrimJName]
    ON [dbo].[CriminalJurisdiction]([CrimJName] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_CriminalJurisdiction_SearchSourceID]
    ON [dbo].[CriminalJurisdiction]([SearchSourceID] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE TRIGGER trigCriminalJurisdiction_History ON [dbo].[CriminalJurisdiction] 
FOR UPDATE 
AS
	DECLARE @CrimJID int
	DECLARE @CrimJName varchar(30)
	DECLARE @SearchSourceID tinyint
	DECLARE @DefaultRate smallmoney
	DECLARE @Enabled bit
	DECLARE @LastModifiedUser varchar(30)
	DECLARE @LastModifiedDate datetime
	SELECT
		@CrimJID = CrimJID, @CrimJName = CrimJName,
		@SearchSourceID = SearchSourceID,
		@DefaultRate = DefaultRate, @Enabled = Enabled,
		@LastModifiedUser = LastModifiedUser, 
		@LastModifiedDate = LastModifiedDate
	FROM Deleted
	INSERT INTO CriminalJurisdictionHistory
		(CrimJID, CrimJName, SearchSourceID, DefaultRate,
		Enabled, LastModifiedUser, LastModifiedDate)
	VALUES
		(@CrimJID,@CrimJName, @SearchSourceID, @DefaultRate, 
		@Enabled, @LastModifiedUser, @LastModifiedDate)
