CREATE TABLE [dbo].[ApplAdjudicationAuditTrail] (
    [ApplAdjudicationAuditTrailID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                         INT          NOT NULL,
    [ApplSectionID]                INT          NOT NULL,
    [SectionID]                    INT          NULL,
    [UserID_CAM]                   VARCHAR (20) NULL,
    [UserID_MGR]                   VARCHAR (20) NULL,
    [ReviewDate_CAM]               DATETIME     NULL,
    [ReviewDate_MGR]               DATETIME     NULL,
    [NotifiedDate_CAM]             DATETIME     CONSTRAINT [DF_ApplAdjudicationAuditTrail_NotifiedDate_CAM] DEFAULT ('1/1/1900') NULL,
    [NotifiedDate_MGR]             DATETIME     NULL,
    [NotifiedDate_Client]          DATETIME     NULL,
    CONSTRAINT [PK_ApplAdjudicationAuditTrail] PRIMARY KEY CLUSTERED ([ApplAdjudicationAuditTrailID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ApplAdjAuditTrail_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
);


GO
CREATE NONCLUSTERED INDEX [IX_APNO_SECTION]
    ON [dbo].[ApplAdjudicationAuditTrail]([APNO] ASC, [ApplSectionID] ASC, [SectionID] ASC)
    INCLUDE([ReviewDate_MGR]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplAdjudicationAuditTrail_UserIDCAM_NotifiedDateCAM]
    ON [dbo].[ApplAdjudicationAuditTrail]([UserID_CAM] ASC, [NotifiedDate_CAM] ASC)
    INCLUDE([APNO], [ApplSectionID], [SectionID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [ApplSectionID_Includes]
    ON [dbo].[ApplAdjudicationAuditTrail]([ApplSectionID] ASC, [NotifiedDate_MGR] ASC)
    INCLUDE([ApplAdjudicationAuditTrailID], [APNO], [SectionID]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAdjudicationAuditTrail_ReviewDate_CAM]
    ON [dbo].[ApplAdjudicationAuditTrail]([ReviewDate_CAM] ASC);

