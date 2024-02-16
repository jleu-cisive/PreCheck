CREATE TABLE [dbo].[ClientAdjudicationStatusCustom] (
    [ClientAdjudicationStatusCustomID] INT           IDENTITY (1, 1) NOT NULL,
    [DisplayName]                      VARCHAR (100) NOT NULL,
    [CLNO]                             INT           NOT NULL,
    [ClientAdjudicationStatusID]       INT           NOT NULL,
    CONSTRAINT [PK_ClientAdjudicationStatusCustom] PRIMARY KEY CLUSTERED ([ClientAdjudicationStatusCustomID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CLNO_STATUSID]
    ON [dbo].[ClientAdjudicationStatusCustom]([CLNO] ASC, [ClientAdjudicationStatusID] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

