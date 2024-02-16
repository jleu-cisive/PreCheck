CREATE TABLE [dbo].[ApplSectionsETALog] (
    [ApplSectionsETALogID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]        INT          NOT NULL,
    [Apno]                 INT          NOT NULL,
    [SectionKeyID]         INT          NOT NULL,
    [OldValue]             DATETIME     NULL,
    [NewValue]             DATETIME     NOT NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_ApplSectionsETALog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50) NULL,
    [UpdateDate]           DATETIME     CONSTRAINT [DF_ApplSectionsETALog_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]            VARCHAR (50) NULL,
    CONSTRAINT [PK_ApplSectionsETALogID] PRIMARY KEY CLUSTERED ([ApplSectionsETALogID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ApplSectionsETALog_ApplSections] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);

