CREATE TABLE [dbo].[ApplSectionsTAT] (
    [ApplSectionsTATID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]     INT          NOT NULL,
    [KeyID]             INT          NOT NULL,
    [TAT]               FLOAT (53)   NOT NULL,
    [CreatedDate]       DATETIME     CONSTRAINT [DF_ApplSectionsTAT_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50) CONSTRAINT [DF_ApplSectionsTAT_CreatedBy] DEFAULT ('CalculateTATService') NOT NULL,
    [UpdateDate]        DATETIME     CONSTRAINT [DF_ApplSectionsTAT_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]         VARCHAR (50) CONSTRAINT [DF_ApplSectionsTAT_UpdatedBy] DEFAULT ('CalculateTATService') NOT NULL,
    [DLState]           VARCHAR (2)  NULL,
    CONSTRAINT [PK_ApplSectionsTATID] PRIMARY KEY CLUSTERED ([ApplSectionsTATID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ApplSectionsTAT_ApplSections] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplSectionsTAT_ApplSectionID_TAT]
    ON [dbo].[ApplSectionsTAT]([ApplSectionID] ASC, [TAT] ASC)
    INCLUDE([DLState]) WITH (FILLFACTOR = 60);


GO
CREATE NONCLUSTERED INDEX [IX_ApplSectionsTAT_ApplSectionID_KeyID,TAT]
    ON [dbo].[ApplSectionsTAT]([ApplSectionID] ASC, [KeyID] ASC, [TAT] ASC);

