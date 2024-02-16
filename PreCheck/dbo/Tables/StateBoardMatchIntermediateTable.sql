CREATE TABLE [dbo].[StateBoardMatchIntermediateTable] (
    [InputID]                     UNIQUEIDENTIFIER NOT NULL,
    [ConsumerName]                VARCHAR (100)    NULL,
    [StateBoardDataID]            INT              NULL,
    [TargetTableName]             VARCHAR (100)    NULL,
    [TargetTableID]               INT              NULL,
    [MatchScenario]               VARCHAR (100)    NULL,
    [StateBoardMatchID]           INT              NULL,
    [StateBoardDisciplinaryRunID] INT              NULL,
    [StateBoardSourceID]          INT              NULL,
    [EmailReferenceID]            VARCHAR (200)    NULL,
    [ClientID]                    INT              NULL,
    [FacilityID]                  INT              NULL,
    [DepartmentID]                INT              NULL,
    [EmailAddress]                VARCHAR (200)    NULL
) ON [PRIMARY];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'StateBoardDataID is from StateBoardFinalDataID, and part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatchIntermediateTable', @level2type = N'COLUMN', @level2name = N'StateBoardDataID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatchIntermediateTable', @level2type = N'COLUMN', @level2name = N'TargetTableName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatchIntermediateTable', @level2type = N'COLUMN', @level2name = N'TargetTableID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'part of 2nd key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StateBoardMatchIntermediateTable', @level2type = N'COLUMN', @level2name = N'MatchScenario';

