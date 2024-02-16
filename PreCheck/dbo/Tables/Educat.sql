CREATE TABLE [dbo].[Educat] (
    [EducatID]                 INT           IDENTITY (19337, 1) NOT NULL,
    [APNO]                     INT           NOT NULL,
    [School]                   VARCHAR (100) NOT NULL,
    [SectStat]                 CHAR (1)      CONSTRAINT [DF_Educat_SectStat] DEFAULT ('0') NOT NULL,
    [Worksheet]                BIT           CONSTRAINT [DF_Educat_Worksheet] DEFAULT (1) NOT NULL,
    [State]                    VARCHAR (2)   NULL,
    [Phone]                    VARCHAR (20)  NULL,
    [Degree_A]                 VARCHAR (50)  NULL,
    [Studies_A]                VARCHAR (50)  NULL,
    [From_A]                   VARCHAR (12)  NULL,
    [To_A]                     VARCHAR (12)  NULL,
    [Name]                     VARCHAR (100) NULL,
    [Degree_V]                 VARCHAR (50)  NULL,
    [Studies_V]                VARCHAR (50)  NULL,
    [From_V]                   VARCHAR (12)  NULL,
    [To_V]                     VARCHAR (12)  NULL,
    [Contact_Name]             VARCHAR (30)  NULL,
    [Contact_Title]            VARCHAR (30)  NULL,
    [Contact_Date]             DATETIME      NULL,
    [Investigator]             VARCHAR (30)  NULL,
    [Priv_Notes]               VARCHAR (MAX) NULL,
    [Pub_Notes]                VARCHAR (MAX) NULL,
    [web_status]               INT           CONSTRAINT [DF_Educat_web_status] DEFAULT (0) NULL,
    [includealias]             CHAR (1)      CONSTRAINT [DF_Educat_includealias] DEFAULT ('y') NULL,
    [includealias2]            CHAR (1)      CONSTRAINT [DF_Educat_includealias2] DEFAULT ('y') NULL,
    [includealias3]            CHAR (1)      CONSTRAINT [DF_Educat_includealias3] DEFAULT ('y') NULL,
    [includealias4]            CHAR (1)      CONSTRAINT [DF_Educat_includealias4] DEFAULT ('y') NULL,
    [pendingupdated]           DATETIME      NULL,
    [web_updated]              DATETIME      NULL,
    [Time_In]                  DATETIME      CONSTRAINT [DF_Educat_Time_In] DEFAULT (getdate()) NULL,
    [Last_Updated]             DATETIME      CONSTRAINT [DF_Educat_LastUpdated] DEFAULT (getdate()) NULL,
    [city]                     VARCHAR (50)  NULL,
    [zipcode]                  CHAR (5)      NULL,
    [CampusName]               VARCHAR (25)  NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      CONSTRAINT [DF_Educat_CreatedDate] DEFAULT (getdate()) NULL,
    [ToPending]                DATETIME      NULL,
    [FromPending]              DATETIME      NULL,
    [Completed]                BIT           NULL,
    [Last_Worked]              DATETIME      NULL,
    [SchoolID]                 INT           NULL,
    [IsCAMReview]              BIT           DEFAULT ((0)) NOT NULL,
    [IsOnReport]               BIT           DEFAULT ((0)) NOT NULL,
    [IsHidden]                 BIT           DEFAULT ((0)) NOT NULL,
    [IsHistoryRecord]          BIT           DEFAULT ((0)) NOT NULL,
    [HasGraduated]             BIT           DEFAULT ((0)) NOT NULL,
    [HighestCompleted]         VARCHAR (50)  NULL,
    [EducatVerifyID]           INT           NULL,
    [GetNextDate]              DATETIME      NULL,
    [SubStatusID]              INT           NULL,
    [ClientAdjudicationStatus] INT           NULL,
    [ClientRefID]              VARCHAR (25)  NULL,
    [IsIntl]                   BIT           NULL,
    [DateOrdered]              DATETIME      NULL,
    [OrderId]                  VARCHAR (20)  NULL,
    [InUse_TimeStamp]          DATETIME      NULL,
    [InvestigatorAssignedDate] DATETIME      NULL,
    [SectSubStatusID]          INT           NULL,
    [GraduationYear]           INT           NULL,
    [EducationLevelCode]       VARCHAR (25)  NULL,
    [EducationLevel]           VARCHAR (50)  NULL,
    [SchoolCode]               VARCHAR (50)  NULL,
    [StudiesCode]              VARCHAR (50)  NULL,
    [GraduationDate_V]         DATETIME      NULL,
    [City_V]                   VARCHAR (50)  NULL,
    [State_V]                  VARCHAR (20)  NULL,
    [Country_V]                VARCHAR (50)  NULL,
    [RecipientName_V]          VARCHAR (150) NULL,
    CONSTRAINT [PK_Educat] PRIMARY KEY CLUSTERED ([EducatID] ASC, [APNO] ASC) ON [PS1_Educat] ([APNO]),
    CONSTRAINT [FK_educat_SectSubStatus] FOREIGN KEY ([SectSubStatusID]) REFERENCES [dbo].[SectSubStatus] ([SectSubStatusID])
) ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IsOnReport_SectSubStatusID_SectStat_Includes]
    ON [dbo].[Educat]([IsOnReport] ASC, [SectSubStatusID] ASC, [SectStat] ASC)
    INCLUDE([EducatID], [APNO], [School], [Degree_A], [Studies_A], [From_A], [To_A], [Pub_Notes])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Educat_Sectstat_Investigator_IsOnReport]
    ON [dbo].[Educat]([Investigator] ASC, [IsOnReport] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Educat_SectStat_IsOnReport_Inc]
    ON [dbo].[Educat]([SectStat] ASC, [IsOnReport] ASC)
    INCLUDE([EducatID], [APNO], [School], [Degree_A], [Studies_A], [From_A], [To_A], [Pub_Notes])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Educat_Last_Worked]
    ON [dbo].[Educat]([Last_Worked] ASC)
    INCLUDE([SectStat], [Investigator], [web_updated]) WITH (FILLFACTOR = 90)
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Educat_SectStat]
    ON [dbo].[Educat]([SectStat] ASC, [Investigator] ASC, [Last_Worked] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 90)
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [Investigator_IsOnReport_Includes]
    ON [dbo].[Educat]([Investigator] ASC, [IsOnReport] ASC)
    INCLUDE([EducatID], [APNO], [School], [SectStat], [State], [Phone], [web_status], [web_updated], [Time_In], [city], [zipcode], [CreatedDate])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [web_status_InUse_Includes]
    ON [dbo].[Educat]([web_status] ASC, [InUse] ASC)
    INCLUDE([EducatID], [APNO], [School], [SectStat], [State], [Degree_A], [Studies_A], [From_A], [To_A], [Degree_V], [Studies_V], [From_V], [To_V], [Investigator], [city], [zipcode])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IsOnReport_IsHidden_SectStat_Includes]
    ON [dbo].[Educat]([IsOnReport] ASC, [IsHidden] ASC, [SectStat] ASC)
    INCLUDE([APNO], [EducatID], [CreatedDate]) WITH (FILLFACTOR = 90)
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Educat_Apno_Inc]
    ON [dbo].[Educat]([APNO] ASC)
    INCLUDE([School], [IsOnReport], [IsHidden], [Degree_V], [Studies_V], [SectStat], [web_status], [InvestigatorAssignedDate], [Last_Updated])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Educat_Investigator_IsOnReport_SectStat]
    ON [dbo].[Educat]([Investigator] ASC, [IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([SectSubStatusID])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Educat_SectStat_Inc]
    ON [dbo].[Educat]([SectStat] ASC)
    INCLUDE([APNO])
    ON [PS1_Educat] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Educat_OrderID]
    ON [dbo].[Educat]([OrderId] ASC)
    INCLUDE([web_status])
    ON [PS1_Educat] ([APNO]);


GO

CREATE TRIGGER [edupendingupdate] on [dbo].[Educat]
for update
as
-- below statement is commented as the both conditions are doing the same --- Kiran - 8/22/2012

 --if update(sectstat)  AND (select isnull(sectstat,-1) from inserted) <> (select isnull(sectstat,-1) from deleted)
if update(sectstat) 
 update educat
 set pendingupdated = convert(varchar, getdate(), 101)
where educatid IN (select educatid from inserted)


GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated and web_updated for client traceability. Disabled old triggers and combined them into a new one
*/

CREATE TRIGGER [dbo].[Educat_Updated] on [dbo].[Educat]
for update
as

if update(sectstat) 
	 update  E set
	   pendingupdated = convert(varchar,getdate(),101),Last_updated = Current_Timestamp
	FROM dbo.Educat E INNER JOIN inserted I 
	ON (E.EducatID = I.Educatid)
	INNER JOIN  deleted D
	ON I.EducatID = D.EducatID  
	where  isnull(i.sectstat,'') <> isnull(d.sectstat,'')

if update(From_V) or update(To_V) or update(Degree_V) or update(Studies_V) or update(Pub_Notes) or update(Contact_Name) or update(Contact_Title) or update(Contact_Date)
	update  E set
	Last_updated = Current_Timestamp
	FROM dbo.Educat E INNER JOIN inserted I 
	ON (E.EducatID = I.EducatID)
	INNER JOIN  deleted D
	ON I.EducatID = D.EducatID
	Where  (Isnull(I.From_V,'') <> Isnull(D.From_V,'')) 
	or  (Isnull(I.To_V,'') <> Isnull(D.To_V,'')) 
	or  (Isnull(I.Degree_V,'') <> Isnull(D.Degree_V,'')) 
	or  (Isnull(I.Studies_V,'') <> Isnull(D.Studies_V,'')) 
	or  (Isnull(I.Pub_Notes,'') <> Isnull(D.Pub_Notes,'')) 
	or  (Isnull(I.Contact_Name,'') <> Isnull(D.Contact_Name,'')) 
	or  (Isnull(I.Contact_Title,'') <> Isnull(D.Contact_Title,'')) 
	or  (Isnull(I.Contact_Date,'1/1/1900') <> Isnull(D.Contact_Date,'1/1/1900')) 

if update(web_status)
Begin
	 update educat  
	 set web_updated = CURRENT_TIMESTAMP
	FROM dbo.Educat E INNER JOIN inserted I 
	ON (E.EducatID = I.Educatid)
	INNER JOIN  deleted D
	ON I.EducatID = D.EducatID AND D.web_status <> I.web_status


End
GO

CREATE TRIGGER [edu_web_history] on [dbo].[Educat]
 for update
as
-- below statement is commented as the both conditions are doing the same --- Kiran - 8/22/2012

--if update(web_status) AND (select isnull(web_status,-1) from inserted) <> (select isnull(web_status,-1) from deleted)
if update(web_status)
BEGIN
 insert web_edu_history(history_apno,educatid,history_date,history_status)
  select apno, educatid,getdate(),web_status
from inserted
END

GO

CREATE TRIGGER [ewebupdate] on [dbo].[Educat]
for update
 as
-- below statement is commented as the both conditions are doing the same --- Kiran - 8/22/2012

--if update(web_status)  AND (select isnull(web_status,-1) from inserted) <> (select isnull(web_status,-1) from deleted)
if update(web_status)
 update educat
 set web_updated = getdate()
where educatid in (select educatid from inserted)


GO
DISABLE TRIGGER [dbo].[ewebupdate]
    ON [dbo].[Educat];

