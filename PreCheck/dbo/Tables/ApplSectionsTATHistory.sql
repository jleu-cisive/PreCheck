CREATE TABLE [dbo].[ApplSectionsTATHistory] (
    [ApplSectionsTATHistoryID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]            INT          NOT NULL,
    [KeyID]                    INT          NOT NULL,
    [TAT]                      FLOAT (53)   NOT NULL,
    [CreatedDate]              DATETIME     CONSTRAINT [DF_ApplSectionsTATHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                VARCHAR (50) CONSTRAINT [DF_ApplSectionsTATHistory_CreatedBy] DEFAULT ('CalculateTATService') NOT NULL,
    [UpdateDate]               DATETIME     CONSTRAINT [DF_ApplSectionsTATHistory_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]                VARCHAR (50) CONSTRAINT [DF_ApplSectionsTATHistory_UpdatedBy] DEFAULT ('CalculateTATService') NOT NULL,
    [DLState]                  VARCHAR (2)  NULL,
    CONSTRAINT [PK_ApplSectionsTATHistoryID] PRIMARY KEY CLUSTERED ([ApplSectionsTATHistoryID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ApplSectionsTATHistory_ApplSections] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);

