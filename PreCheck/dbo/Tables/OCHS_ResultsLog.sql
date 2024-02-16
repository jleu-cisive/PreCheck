CREATE TABLE [dbo].[OCHS_ResultsLog] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [ProviderID]    VARCHAR (25) NULL,
    [XMLResponse]   XML          NOT NULL,
    [LastUpdated]   DATETIME     CONSTRAINT [DF_OCHS_ResultsLog_LastUpdated] DEFAULT (getdate()) NOT NULL,
    [ProcessStatus] VARCHAR (12) NULL,
    CONSTRAINT [PK_OCHS_ResultsLog] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (DATA_COMPRESSION = PAGE)
);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_ResultsLog_01]
    ON [dbo].[OCHS_ResultsLog]([ProviderID] ASC)
    INCLUDE([ProcessStatus]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_ResultsLog_Lastupdated]
    ON [dbo].[OCHS_ResultsLog]([LastUpdated] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE STATISTICS [_WA_Sys_00000004_328300B1]
    ON [dbo].[OCHS_ResultsLog]([LastUpdated]);

