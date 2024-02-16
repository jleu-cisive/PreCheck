CREATE TABLE [dbo].[ApplSectionsETA] (
    [ApplSectionsETAID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]     INT          NOT NULL,
    [Apno]              INT          NOT NULL,
    [SectionKeyID]      INT          NOT NULL,
    [ETADate]           DATETIME     NOT NULL,
    [CreatedDate]       DATETIME     CONSTRAINT [DF_ApplSectionsETA_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50) CONSTRAINT [DF_ApplSectionsETA_CreatedBy] DEFAULT ('DeriveETAFromTATService') NOT NULL,
    [UpdateDate]        DATETIME     CONSTRAINT [DF_ApplSectionsETA_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]         VARCHAR (50) CONSTRAINT [DF_ApplSectionsETA_UpdatedBy] DEFAULT ('DeriveETAFromTATService') NOT NULL,
    CONSTRAINT [PK_ApplSectionsETAID] PRIMARY KEY CLUSTERED ([ApplSectionsETAID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ApplSectionsETA_ApplSections] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplSectionsETA_Apno_SectionKeyID]
    ON [dbo].[ApplSectionsETA]([Apno] ASC, [SectionKeyID] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_ApplSectionsETA_ApplSectionID]
    ON [dbo].[ApplSectionsETA]([ApplSectionID] ASC)
    INCLUDE([ApplSectionsETAID], [Apno], [SectionKeyID]);


GO
CREATE NONCLUSTERED INDEX [IX_ApplSectionsETA_SectionKeyID_INC]
    ON [dbo].[ApplSectionsETA]([SectionKeyID] ASC)
    INCLUDE([ETADate]);

