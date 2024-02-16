CREATE TABLE [dbo].[Empl] (
    [EmplID]                   INT           IDENTITY (153901, 1) NOT NULL,
    [Apno]                     INT           NOT NULL,
    [Employer]                 VARCHAR (30)  NOT NULL,
    [Location]                 VARCHAR (250) NULL,
    [SectStat]                 CHAR (1)      CONSTRAINT [DF_Empl_SectStat] DEFAULT ('0') NOT NULL,
    [Worksheet]                BIT           CONSTRAINT [DF_Empl_Worksheet] DEFAULT (1) NOT NULL,
    [Phone]                    VARCHAR (20)  NULL,
    [Supervisor]               VARCHAR (25)  NULL,
    [SupPhone]                 VARCHAR (20)  NULL,
    [Dept]                     VARCHAR (30)  NULL,
    [RFL]                      VARCHAR (30)  NULL,
    [DNC]                      BIT           CONSTRAINT [DF_Empl_DNC] DEFAULT (0) NOT NULL,
    [SpecialQ]                 BIT           CONSTRAINT [DF_Empl_SpecialQ] DEFAULT (0) NOT NULL,
    [Ver_Salary]               BIT           CONSTRAINT [DF_Empl_Ver_Salary] DEFAULT (0) NOT NULL,
    [From_A]                   VARCHAR (12)  NULL,
    [To_A]                     VARCHAR (12)  NULL,
    [Position_A]               VARCHAR (50)  NULL,
    [Salary_A]                 VARCHAR (15)  NULL,
    [From_V]                   VARCHAR (30)  NULL,
    [To_V]                     VARCHAR (30)  NULL,
    [Position_V]               VARCHAR (50)  NULL,
    [Salary_V]                 VARCHAR (50)  NULL,
    [Emp_Type]                 CHAR (1)      CONSTRAINT [DF_Empl_Emp_Type] DEFAULT ('N') NOT NULL,
    [Rel_Cond]                 CHAR (1)      CONSTRAINT [DF_Empl_Rel_Cond] DEFAULT ('N') NOT NULL,
    [Rehire]                   VARCHAR (1)   NULL,
    [Ver_By]                   VARCHAR (50)  NULL,
    [Title]                    VARCHAR (50)  NULL,
    [Priv_Notes]               VARCHAR (MAX) NULL,
    [Pub_Notes]                VARCHAR (MAX) NULL,
    [web_status]               INT           CONSTRAINT [DF_Empl_web_status] DEFAULT (0) NULL,
    [web_updated]              DATETIME      CONSTRAINT [DF_Empl_web_updated] DEFAULT (getdate()) NULL,
    [Includealias]             CHAR (1)      CONSTRAINT [DF_Empl_includealias] DEFAULT ('y') NULL,
    [Includealias2]            CHAR (1)      CONSTRAINT [DF_Empl_includealias2] DEFAULT ('y') NULL,
    [Includealias3]            CHAR (1)      CONSTRAINT [DF_Empl_includealias3] DEFAULT ('y') NULL,
    [Includealias4]            CHAR (1)      CONSTRAINT [DF_Empl_includealias4] DEFAULT ('y') NULL,
    [PendingUpdated]           DATETIME      NULL,
    [Time_In]                  DATETIME      CONSTRAINT [DF_Empl_Time_In] DEFAULT (getdate()) NULL,
    [Last_Updated]             DATETIME      CONSTRAINT [DF_Empl_LastUpdated] DEFAULT (getdate()) NULL,
    [city]                     VARCHAR (50)  NULL,
    [state]                    CHAR (2)      NULL,
    [zipcode]                  CHAR (5)      NULL,
    [Investigator]             VARCHAR (8)   NULL,
    [EmployerID]               INT           NULL,
    [InvestigatorAssigned]     DATETIME      NULL,
    [PendingChanged]           DATETIME      NULL,
    [TempInvestigator]         VARCHAR (10)  NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      CONSTRAINT [DF_Empl_CreatedDate] DEFAULT (getdate()) NULL,
    [EnteredBy]                VARCHAR (50)  NULL,
    [EnteredDate]              DATETIME      NULL,
    [IsCamReview]              BIT           CONSTRAINT [DF_Empl_IsCamReview] DEFAULT ((0)) NULL,
    [Last_Worked]              DATETIME      NULL,
    [ClientEmployerID]         INT           NULL,
    [AutoFaxStatus]            INT           NULL,
    [IsOnReport]               BIT           DEFAULT ((0)) NOT NULL,
    [IsHidden]                 BIT           DEFAULT ((0)) NOT NULL,
    [IsHistoryRecord]          BIT           DEFAULT ((0)) NOT NULL,
    [EmploymentStatus]         VARCHAR (50)  NULL,
    [IsOKtoContact]            BIT           DEFAULT ((0)) NOT NULL,
    [OKtoContactInitial]       VARCHAR (15)  NULL,
    [EmplVerifyID]             INT           NULL,
    [GetNextDate]              DATETIME      NULL,
    [SubStatusID]              INT           NULL,
    [ClientAdjudicationStatus] INT           NULL,
    [ClientRefID]              VARCHAR (25)  NULL,
    [IsIntl]                   BIT           NULL,
    [DateOrdered]              DATETIME      NULL,
    [OrderId]                  VARCHAR (20)  NULL,
    [Email]                    VARCHAR (50)  NULL,
    [AdverseRFL]               BIT           DEFAULT ((0)) NULL,
    [InUse_TimeStamp]          DATETIME      NULL,
    [LastModifiedDate]         DATETIME      CONSTRAINT [DF_Empl_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]           VARCHAR (20)  NULL,
    [SectSubStatusID]          INT           NULL,
    [City_V]                   VARCHAR (50)  NULL,
    [State_V]                  VARCHAR (20)  NULL,
    [Country_V]                VARCHAR (50)  NULL,
    [RecipientName_V]          VARCHAR (150) NULL,
    CONSTRAINT [PK_Empl] PRIMARY KEY CLUSTERED ([EmplID] ASC, [Apno] ASC) ON [PS1_Empl] ([Apno]),
    CONSTRAINT [FK_Empl_SectSubStatus] FOREIGN KEY ([SectSubStatusID]) REFERENCES [dbo].[SectSubStatus] ([SectSubStatusID])
) ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_Empl_InvIsOnRprt]
    ON [dbo].[Empl]([Investigator] ASC, [IsOnReport] ASC, [EmplID] ASC, [Apno] ASC, [SectStat] ASC, [EmployerID] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_SecStatInv]
    ON [dbo].[Empl]([SectStat] ASC, [Investigator] ASC, [IsOnReport] ASC, [Apno] ASC)
    INCLUDE([Last_Worked]) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IDX_Empl_investigator_IsOnReport]
    ON [dbo].[Empl]([Investigator] ASC, [IsOnReport] ASC)
    INCLUDE([EmplID], [Apno], [Employer], [web_status], [web_updated], [city], [state], [zipcode], [DateOrdered], [OrderId]) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_Empl_SectStat_IsOnReport_Inc]
    ON [dbo].[Empl]([SectStat] ASC, [IsOnReport] ASC)
    INCLUDE([EmplID], [Apno], [Employer], [From_A], [To_A], [Pub_Notes]) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IDX_Empl_SectStat]
    ON [dbo].[Empl]([SectStat] ASC)
    INCLUDE([Apno]) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IDX_Empl_SectStat_Investigator]
    ON [dbo].[Empl]([SectStat] ASC, [Last_Worked] ASC, [Investigator] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IDX_dbo_Empl_IsOnReport_IsHidden_1]
    ON [dbo].[Empl]([IsOnReport] ASC, [IsHidden] ASC)
    INCLUDE([EmplID], [Apno], [Employer], [SectStat], [Last_Updated], [SectSubStatusID])
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IDX_Empl_IsonReport_SectStat_Inc]
    ON [dbo].[Empl]([IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([Apno])
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [OrderId_Includes]
    ON [dbo].[Empl]([OrderId] ASC)
    INCLUDE([EmplID], [Apno], [Employer], [Location], [SectStat], [Worksheet], [Phone], [Supervisor], [SupPhone], [Dept], [RFL], [DNC], [SpecialQ], [Ver_Salary], [From_A], [To_A], [Position_A], [Salary_A], [From_V], [To_V], [Position_V], [Salary_V], [Emp_Type], [Rel_Cond], [Rehire], [Ver_By], [Title], [Priv_Notes], [Pub_Notes], [web_status], [web_updated], [Includealias], [Includealias2], [Includealias3], [Includealias4], [PendingUpdated], [Time_In], [Last_Updated], [city], [state], [zipcode], [Investigator], [EmployerID], [InvestigatorAssigned], [PendingChanged], [TempInvestigator], [InUse], [CreatedDate], [EnteredBy], [EnteredDate], [IsCamReview], [Last_Worked], [ClientEmployerID], [AutoFaxStatus], [IsOnReport], [IsHidden], [IsHistoryRecord], [EmploymentStatus], [IsOKtoContact], [OKtoContactInitial], [EmplVerifyID], [GetNextDate], [SubStatusID], [ClientAdjudicationStatus], [ClientRefID], [IsIntl], [DateOrdered], [Email], [AdverseRFL], [InUse_TimeStamp], [LastModifiedDate], [LastModifiedBy], [SectSubStatusID]) WITH (FILLFACTOR = 90)
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_Empl_IsOnReport_IsHidden_SectStat]
    ON [dbo].[Empl]([IsOnReport] ASC, [IsHidden] ASC, [SectStat] ASC)
    INCLUDE([EmplID], [Apno], [CreatedDate])
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_Empl_Investigator_IsOnReprot_SectStat]
    ON [dbo].[Empl]([Investigator] ASC, [IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([SectSubStatusID])
    ON [PS1_Empl] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_Empl_Apno_IsOnReport_SectStat]
    ON [dbo].[Empl]([Apno] ASC, [IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([EmplID])
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Empl_ApNo_Inc]
    ON [dbo].[Empl]([Apno] ASC)
    INCLUDE([SectStat], [Last_Updated])
    ON [PS1_Empl] ([Apno]);


GO

CREATE TRIGGER [dbo].[web_empl_history] on [dbo].[Empl]
FOR UPDATE
AS


if update(web_status)
 INSERT web_status_history (history_appno,emplid,history_date,history_status)
SELECT I.apno, I.emplid, Current_TimeStamp,I.web_status
  FROM inserted I INNER JOIN  deleted D
ON I.Emplid = D.EmplID 
WHERE ISNULL(I.web_status,-1) <> ISNULL(D.web_status,-1)
GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated and web_updated for client traceability. Disabled old triggers and combined them into a new one
*/

CREATE TRIGGER [dbo].[Empl_Updated] on [dbo].[Empl]
for update
as
BEGIN
	if update(sectstat) 
		 update  E set
		   pendingupdated = convert(varchar,getdate(),101),Last_updated = Current_Timestamp
		FROM dbo.Empl E INNER JOIN inserted I 
		ON (E.EmplID = I.emplid)
		INNER JOIN  deleted D
		ON I.Emplid = D.EmplID 
		where  isnull(i.sectstat,'') <> isnull(d.sectstat,'') 


	if update(From_V) or update(To_V) or update(Position_V) or update(Salary_V) or update(Pub_Notes) or update(ver_by) or  update(Rel_Cond) or update(Rehire) or update(Title)  or update(Emp_Type)
			update  E set
			Last_updated = Current_Timestamp
			FROM dbo.Empl E INNER JOIN inserted I 
			ON (E.EmplID = I.emplid)
			INNER JOIN  deleted D
			ON I.Emplid = D.EmplID 
			Where  (Isnull(I.From_V,'') <> Isnull(D.From_V,'')) 
			or  (Isnull(I.To_V,'') <> Isnull(D.To_V,'')) 
			or  (Isnull(I.Position_V,'') <> Isnull(D.Position_V,'')) 
			or  (Isnull(I.Salary_V,'') <> Isnull(D.Salary_V,''))   
			or (Isnull(I.Pub_Notes,'') <> Isnull(D.Pub_Notes,'')) 
			or (IsNull(I.ver_by,'') <>  IsNull(D.ver_by,''))
			or (IsNull(I.Rel_Cond,'') <>  IsNull(D.Rel_Cond,''))
			or (IsNull(I.Rehire,'') <>  IsNull(D.Rehire,''))
			or (IsNull(I.Title,'') <>  IsNull(D.Title,''))
			or (IsNull(I.Emp_Type,'') <>  IsNull(D.Emp_Type,''))

	if update(web_status)
		 update  E set
		   web_updated = Current_Timestamp
		FROM dbo.Empl E INNER JOIN inserted I 
		ON (E.EmplID = I.emplid)
		INNER JOIN  deleted D
		ON I.Emplid = D.EmplID AND D.web_status <> I.web_status 


End
GO

CREATE TRIGGER [PendingUpdate] on [dbo].[Empl]
FOR UPDATE
AS
-- below statement is commented as the both conditions are doing the same --- Kiran - 8/22/2012

--if update(sectstat) AND (select isnull(sectstat,-1) from inserted) <> (select isnull(sectstat,-1) from deleted)
-- update  empl set
--   pendingupdated = convert(varchar,getdate(),101)
-- where emplid = (select   emplid from inserted)


if update(sectstat)
 update  empl set
   pendingupdated = convert(varchar,getdate(),101)
 where emplid IN (select   emplid from inserted)


GO
DISABLE TRIGGER [dbo].[PendingUpdate]
    ON [dbo].[Empl];


GO




CREATE TRIGGER [Webupdate] on [dbo].[Empl]
FOR UPDATE
AS

--if update(web_status) AND (select isnull(web_status,-1) from inserted) <> (select isnull(web_status,-1) from deleted)
-- update  empl set
--   web_updated = getdate()
--from inserted, deleted
--where (empl.emplid = inserted.emplid) and (deleted.web_status <> inserted.web_status)



-- below statement is commented as the both conditions are doing the same --- Kiran - 8/22/2012
--if update(web_status) AND (select isnull(web_status,-1) from inserted) <> (select isnull(web_status,-1) from deleted)
if update(web_status)
 update  E set
   web_updated = getdate()
FROM dbo.Empl E INNER JOIN inserted I 
ON (E.EmplID = I.emplid)
INNER JOIN  deleted D
ON I.Emplid = D.EmplID AND D.web_status <> I.web_status 




GO
DISABLE TRIGGER [dbo].[Webupdate]
    ON [dbo].[Empl];

