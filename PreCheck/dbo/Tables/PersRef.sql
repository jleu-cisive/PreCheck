CREATE TABLE [dbo].[PersRef] (
    [PersRefID]                INT           IDENTITY (19325, 1) NOT NULL,
    [APNO]                     INT           NOT NULL,
    [SectStat]                 CHAR (1)      CONSTRAINT [DF_PersRef_SectStat] DEFAULT ('0') NOT NULL,
    [Worksheet]                BIT           CONSTRAINT [DF_PersRef_Worksheet] DEFAULT (1) NOT NULL,
    [Name]                     VARCHAR (25)  NOT NULL,
    [Phone]                    VARCHAR (20)  NULL,
    [Rel_V]                    VARCHAR (50)  NULL,
    [Years_V]                  SMALLINT      NULL,
    [Priv_Notes]               VARCHAR (MAX) NULL,
    [Pub_Notes]                VARCHAR (MAX) NULL,
    [Last_Updated]             DATETIME      CONSTRAINT [DF_PersRef_LastUpdated] DEFAULT (getdate()) NULL,
    [Investigator]             VARCHAR (8)   NULL,
    [Emplid]                   INT           NULL,
    [PendingUpdated]           DATETIME      NULL,
    [Web_Status]               INT           CONSTRAINT [DF_PersRef_Web_Status] DEFAULT (0) NULL,
    [web_updated]              DATETIME      NULL,
    [time_in]                  DATETIME      CONSTRAINT [DF_PersRef_time_in] DEFAULT (getdate()) NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      CONSTRAINT [DF_PersRef_CreatedDate] DEFAULT (getdate()) NULL,
    [Last_Worked]              DATETIME      NULL,
    [IsCAMReview]              BIT           DEFAULT ((0)) NOT NULL,
    [IsOnReport]               BIT           DEFAULT ((0)) NOT NULL,
    [IsHidden]                 BIT           DEFAULT ((0)) NOT NULL,
    [IsHistoryRecord]          BIT           DEFAULT ((0)) NOT NULL,
    [ClientAdjudicationStatus] INT           NULL,
    [Email]                    VARCHAR (50)  NULL,
    [JobTitle]                 VARCHAR (100) NULL,
    [InUse_TimeStamp]          DATETIME      NULL,
    [InvestigatorAssignedDate] DATETIME      NULL,
    [SectSubStatusID]          INT           NULL,
    [DateOrdered]              DATETIME      NULL,
    [OrderId]                  VARCHAR (50)  NULL,
    CONSTRAINT [PK_PersRef] PRIMARY KEY CLUSTERED ([PersRefID] ASC, [APNO] ASC) ON [PS1_Persref] ([APNO]),
    CONSTRAINT [FK_PersRef_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_PersRef_SectSubStatus] FOREIGN KEY ([SectSubStatusID]) REFERENCES [dbo].[SectSubStatus] ([SectSubStatusID])
) ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [emplid_isonreport_index]
    ON [dbo].[PersRef]([Emplid] ASC, [IsOnReport] ASC, [APNO] ASC) WITH (FILLFACTOR = 50)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_PersRef_Apno]
    ON [dbo].[PersRef]([APNO] ASC) WITH (FILLFACTOR = 50)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_PersRef_SecStatInv]
    ON [dbo].[PersRef]([SectStat] ASC, [Investigator] ASC, [IsOnReport] ASC, [APNO] ASC)
    INCLUDE([PersRefID], [Last_Worked]) WITH (FILLFACTOR = 50)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_PersRef_SectStat_Investigator_IsonReport]
    ON [dbo].[PersRef]([SectStat] ASC, [Investigator] ASC, [IsOnReport] ASC)
    INCLUDE([PersRefID], [APNO], [Name], [Web_Status]) WITH (FILLFACTOR = 70)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_PersRef_SectStat]
    ON [dbo].[PersRef]([SectStat] ASC, [Investigator] ASC, [Last_Worked] ASC) WITH (FILLFACTOR = 70)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_PersRef_Last_Worked]
    ON [dbo].[PersRef]([Last_Worked] ASC)
    INCLUDE([SectStat], [Investigator], [web_updated]) WITH (FILLFACTOR = 70)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_PersRef_APNO]
    ON [dbo].[PersRef]([IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([APNO])
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [SectStat_IsOnReport_Includes]
    ON [dbo].[PersRef]([SectStat] ASC, [IsOnReport] ASC)
    INCLUDE([PersRefID], [APNO], [Name], [Pub_Notes]) WITH (FILLFACTOR = 100)
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_PersRef_OrderID]
    ON [dbo].[PersRef]([OrderId] ASC, [DateOrdered] ASC)
    INCLUDE([SectStat], [Web_Status])
    ON [PS1_Persref] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_PersRef_Investigator_IsOnReport_SectStat]
    ON [dbo].[PersRef]([Investigator] ASC, [IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([SectSubStatusID], [PersRefID], [APNO], [Name], [Web_Status], [web_updated], [Email])
    ON [PS1_Persref] ([SectSubStatusID]);


GO
CREATE NONCLUSTERED INDEX [IX_PersRef_IsOnReport_IsHidden]
    ON [dbo].[PersRef]([IsOnReport] ASC, [IsHidden] ASC, [SectStat] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_PersRef_ApNo_Inc]
    ON [dbo].[PersRef]([APNO] ASC)
    INCLUDE([SectStat], [Last_Updated])
    ON [PS1_Persref] ([APNO]);


GO
CREATE TRIGGER [dbo].[Webrefupdate] on [dbo].[PersRef]
FOR UPDATE
AS
--if update(web_status) AND (select isnull(web_status,-1) from inserted) <> (select isnull(web_status,-1) from deleted)
-- update  persref set
--   web_updated = getdate()
-- where persrefid = (select   persrefid from inserted)
Return
--schapyala updated to handle batch updates -5/5/13
	UPDATE A SET  web_updated = CURRENT_TIMESTAMP 
	 FROM dbo.persref A INNER JOIN INSERTED I 
	 ON A.PersRefID = I.PersRefID
	 INNER JOIN DELETED D
	 ON I.PersRefID = D.PersRefID
	 WHERE 	ISNULL(I.web_status,-1) <> ISNULL(D.web_status,-1)
GO
DISABLE TRIGGER [dbo].[Webrefupdate]
    ON [dbo].[PersRef];


GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated and web_updated for client traceability. Disabled old triggers and combined them into a new one
*/

CREATE TRIGGER [dbo].[PersRef_Updated] on [dbo].[PersRef]
for update
as
BEGIN
	if update(sectstat) 
		 update  E set
		   pendingupdated = convert(varchar,getdate(),101),Last_updated = Current_Timestamp
		FROM dbo.[PersRef] E INNER JOIN inserted I 
		ON (E.PersRefID = I.PersRefID)
		INNER JOIN  deleted D
		ON I.PersRefID = D.PersRefID 
		Where isnull(i.sectstat,'') <> isnull(d.sectstat,'')

	if  update(Rel_V) or update(Years_V)  or update(Pub_Notes) 
		update  E set
		Last_updated = Current_Timestamp
		FROM dbo.[PersRef] E INNER JOIN inserted I 
		ON (E.PersRefID = I.PersRefID)
		INNER JOIN  deleted D
		ON I.PersRefID = D.PersRefID 
		Where isnull(i.Rel_V,'') <> isnull(d.Rel_V,'') 
		or  isnull(i.Years_V,'') <> isnull(d.Years_V,'') 
		or  (Isnull(I.Pub_Notes,'') <> Isnull(D.Pub_Notes,'')) 

	if update(web_status)
		UPDATE A SET  web_updated = CURRENT_TIMESTAMP 
		 FROM dbo.persref A INNER JOIN INSERTED I 
		 ON A.PersRefID = I.PersRefID
		 INNER JOIN DELETED D
		 ON I.PersRefID = D.PersRefID
		 WHERE 	ISNULL(I.web_status,-1) <> ISNULL(D.web_status,-1)


End
GO
CREATE TRIGGER [dbo].[Ref_PendingUpdate] on [dbo].[PersRef]
FOR UPDATE
AS
--if update(sectstat) AND (select isnull(sectstat,-1) from inserted) <> (select isnull(sectstat,-1) from deleted)
-- update  persref set
--   pendingupdated = convert(varchar,getdate(),101)
-- where persrefid = (select   persrefid from inserted)
Return
--schapyala updated to handle batch updates -5/5/13
	UPDATE A SET  pendingupdated = convert(varchar,CURRENT_TIMESTAMP,101) 
	 FROM dbo.persref A INNER JOIN INSERTED I 
	 ON A.PersRefID = I.PersRefID
	 INNER JOIN DELETED D
	 ON I.PersRefID = D.PersRefID
	 WHERE 	ISNULL(I.sectstat,-1) <> ISNULL(D.sectstat,-1)

GO
DISABLE TRIGGER [dbo].[Ref_PendingUpdate]
    ON [dbo].[PersRef];

