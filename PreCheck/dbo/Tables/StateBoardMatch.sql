CREATE TABLE [dbo].[StateBoardMatch] (
    [StateBoardDataID]                   INT              NOT NULL,
    [TargetTableName]                    VARCHAR (100)    NOT NULL,
    [TargetTableID]                      INT              NOT NULL,
    [MatchScenario]                      VARCHAR (100)    NOT NULL,
    [StateBoardMatchID]                  INT              IDENTITY (1, 1) NOT NULL,
    [MatchingIsAMatch]                   INT              NOT NULL,
    [MatchingSetDateTime]                DATETIME         NOT NULL,
    [MatchingSetByUser]                  VARCHAR (100)    NOT NULL,
    [MatchingInsertedDateTime]           DATETIME         NOT NULL,
    [MatchingHasBeenDecided]             BIT              NOT NULL,
    [MatchingComment]                    VARCHAR (4000)   NULL,
    [MatchingLatestInitialEmailBatchID]  UNIQUEIDENTIFIER NULL,
    [MatchingLatestFollowUpEmailBatchID] UNIQUEIDENTIFIER NULL,
    [MatchToResolveSetDateTime]          DATETIME         NULL,
    [MatchResolvedDateTime]              DATETIME         NULL,
    CONSTRAINT [PK_StateBoardMatch] PRIMARY KEY CLUSTERED ([StateBoardDataID] ASC, [TargetTableName] ASC, [TargetTableID] ASC, [MatchScenario] ASC) WITH (FILLFACTOR = 50)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'StateBoardDataID is from StateBoardFinalDataID, and part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'StateBoardDataID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'TargetTableName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'TargetTableID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchScenario';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=false, 1=true, 2=unknown', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchingIsAMatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchingInsertedDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Matching has been decided to be a match or not', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchingHasBeenDecided';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Optional Column', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchingLatestInitialEmailBatchID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Optional Column', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchingLatestFollowUpEmailBatchID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Wether a match should be resolved when an email sent out', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchToResolveSetDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Whether the match has been resolved or not.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatch', @level2type = N'COLUMN', @level2name = N'MatchResolvedDateTime';

