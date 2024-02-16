CREATE TABLE [dbo].[Partner_LogStatus] (
    [Partner_LogStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [PartnerID]           INT          NULL,
    [Section]             VARCHAR (15) NULL,
    [SectionID]           INT          NULL,
    [ApplAliasID]         INT          NULL,
    [AckStatus]           INT          NULL,
    [CrimStatus]          VARCHAR (1)  NULL,
    [Retries]             INT          NULL,
    [CreatedDate]         DATETIME     NULL,
    CONSTRAINT [PK_Partner_LogStatus] PRIMARY KEY CLUSTERED ([Partner_LogStatusId] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IX_Partner_LogStatus_ParterID_Section_CrimStatus_Retries]
    ON [dbo].[Partner_LogStatus]([PartnerID] ASC, [Section] ASC, [CrimStatus] ASC, [Retries] ASC)
    INCLUDE([SectionID]);


GO
CREATE NONCLUSTERED INDEX [IX_Partner_LogStatus_ParterID_Section]
    ON [dbo].[Partner_LogStatus]([PartnerID] ASC, [Section] ASC)
    INCLUDE([SectionID], [ApplAliasID], [CrimStatus]);


GO
CREATE NONCLUSTERED INDEX [IX_Partner_LogStatus_PartnerID_Section_SectionID_AppAliasID]
    ON [dbo].[Partner_LogStatus]([PartnerID] ASC, [Section] ASC, [SectionID] ASC, [ApplAliasID] ASC)
    INCLUDE([CrimStatus]);

