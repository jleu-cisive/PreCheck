CREATE TABLE [dbo].[MedInteg] (
    [APNO]                     INT           NOT NULL,
    [SectStat]                 CHAR (1)      CONSTRAINT [DF_MedInteg_SectStat] DEFAULT ('0') NOT NULL,
    [Report]                   VARCHAR (MAX) NULL,
    [Last_Updated]             DATETIME      CONSTRAINT [DF_MedInteg_LastUpdated] DEFAULT (getdate()) NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      NULL,
    [IsHidden]                 BIT           DEFAULT ((0)) NOT NULL,
    [IsCAMReview]              BIT           DEFAULT ((0)) NOT NULL,
    [ClientAdjudicationStatus] INT           NULL,
    CONSTRAINT [PK_MedInteg] PRIMARY KEY CLUSTERED ([APNO] ASC) ON [PS1_MedInteg] ([APNO]),
    CONSTRAINT [FK_MedInteg_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
) ON [PS1_MedInteg] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_ClientAdjudicationStatus]
    ON [dbo].[MedInteg]([ClientAdjudicationStatus] ASC, [APNO] ASC) WITH (FILLFACTOR = 75)
    ON [PS1_MedInteg] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_SectStat]
    ON [dbo].[MedInteg]([SectStat] ASC, [APNO] ASC) WITH (FILLFACTOR = 75)
    ON [PS1_MedInteg] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_MedInteg_IsHidden_SectStat]
    ON [dbo].[MedInteg]([IsHidden] ASC, [SectStat] ASC)
    INCLUDE([APNO])
    ON [PS1_MedInteg] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_MedInteg_ApNo]
    ON [dbo].[MedInteg]([APNO] ASC)
    INCLUDE([SectStat], [Last_Updated])
    ON [PS1_MedInteg] ([APNO]);


GO


/*
Author: schapyala
Created: 04/09/14
Purpose: To update last_updated for client traceability
*/

CREATE TRIGGER [dbo].[MedInteg_LastUpdated] on [dbo].[MedInteg]
for update
as

if update(sectstat) or update(Report)
	 update  M 
	 set Last_updated = Current_Timestamp
	FROM dbo.MedInteg M INNER JOIN inserted I 
	ON (M.APNO = I.APNO)
	INNER JOIN  deleted D
	ON (I.APNO = D.APNO) 
	where  isnull(i.sectstat,'') <> isnull(d.sectstat,'')
	or isnull(i.Report,'') <> isnull(d.Report,'')

