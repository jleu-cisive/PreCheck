CREATE TABLE [dbo].[ReleaseFormAcknowledgement] (
    [AcknowledgeId]   INT          IDENTITY (1, 1) NOT NULL,
    [ReleaseFormId]   INT          NOT NULL,
    [AcknowledgeDate] DATETIME     NULL,
    [CLNO]            INT          NOT NULL,
    [ClientApno]      VARCHAR (50) NOT NULL
);

