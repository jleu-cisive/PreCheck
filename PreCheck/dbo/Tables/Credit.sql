CREATE TABLE [dbo].[Credit] (
    [APNO]                     INT           NOT NULL,
    [Vendor]                   CHAR (1)      NOT NULL,
    [RepType]                  CHAR (1)      NOT NULL,
    [Qued]                     BIT           CONSTRAINT [DF_Credit_Qued] DEFAULT (0) NOT NULL,
    [Pulled]                   BIT           CONSTRAINT [DF_Credit_Pulled] DEFAULT (0) NOT NULL,
    [SectStat]                 CHAR (1)      CONSTRAINT [DF_Credit_SectStat] DEFAULT ('0') NOT NULL,
    [Report]                   VARCHAR (MAX) NULL,
    [Last_Updated]             DATETIME      CONSTRAINT [DF_Credit_LastUpdated] DEFAULT (getdate()) NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      NULL,
    [IsHidden]                 BIT           DEFAULT ((0)) NOT NULL,
    [IsCAMReview]              BIT           DEFAULT ((0)) NOT NULL,
    [ClientAdjudicationStatus] INT           NULL,
    [PositiveIDReport]         XML           NULL,
    CONSTRAINT [FK_Credit_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [PK_Credit] UNIQUE CLUSTERED ([APNO] ASC, [Vendor] ASC, [RepType] ASC) WITH (FILLFACTOR = 50) ON [PS1_Credit] ([APNO])
) ON [PS1_Credit] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_SectStat]
    ON [dbo].[Credit]([SectStat] ASC, [APNO] ASC) WITH (FILLFACTOR = 75)
    ON [PS1_Credit] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [RepType_CreatedDate_Includes]
    ON [dbo].[Credit]([RepType] ASC, [CreatedDate] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 100)
    ON [PS1_Credit] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Credit_ApNo]
    ON [dbo].[Credit]([APNO] ASC)
    INCLUDE([SectStat], [Last_Updated])
    ON [PS1_Credit] ([APNO]);


GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated for client traceability
*/

CREATE TRIGGER [dbo].[Credit_LastUpdated] on [dbo].[Credit]
for update
as

if update(sectstat) or update(Report)
	 update  C 
	 set Last_updated = Current_Timestamp
	FROM dbo.Credit C 
	INNER JOIN inserted I 
	ON (C.APNO = I.APNO) AND (C.RepType = I.RepType)
	INNER JOIN  deleted D
	ON (I.APNO = D.APNO) AND (I.RepType = D.RepType)  
	where  (isnull(i.sectstat,'') <> isnull(d.sectstat,''))
	Or (isnull(i.Report, '') <> isnull(d.Report, ''))


