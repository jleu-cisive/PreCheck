CREATE TABLE [dbo].[ProfLic] (
    [ProfLicID]                     INT           IDENTITY (36980, 1) NOT NULL,
    [Apno]                          INT           NOT NULL,
    [SectStat]                      CHAR (1)      CONSTRAINT [DF_ProfLic_SectStat] DEFAULT ('0') NOT NULL,
    [Worksheet]                     BIT           CONSTRAINT [DF_ProfLic_Worksheet] DEFAULT ((1)) NOT NULL,
    [Lic_Type]                      VARCHAR (100) NULL,
    [Lic_No]                        VARCHAR (20)  NULL,
    [Year]                          VARCHAR (10)  NULL,
    [Expire]                        DATETIME      NULL,
    [State]                         VARCHAR (8)   NULL,
    [Status]                        VARCHAR (50)  NULL,
    [Priv_Notes]                    VARCHAR (MAX) NULL,
    [Pub_Notes]                     VARCHAR (MAX) NULL,
    [Web_status]                    INT           CONSTRAINT [DF_ProfLic_Web_status] DEFAULT ((0)) NULL,
    [includealias]                  CHAR (1)      NULL,
    [includealias2]                 CHAR (1)      NULL,
    [includealias3]                 CHAR (1)      NULL,
    [includealias4]                 CHAR (1)      NULL,
    [pendingupdated]                DATETIME      NULL,
    [web_updated]                   DATETIME      NULL,
    [time_in]                       DATETIME      CONSTRAINT [DF_ProfLic_time_in] DEFAULT (getdate()) NULL,
    [Organization]                  VARCHAR (30)  NULL,
    [Contact_Name]                  VARCHAR (30)  NULL,
    [Contact_Title]                 VARCHAR (30)  NULL,
    [Contact_Date]                  DATETIME      NULL,
    [Investigator]                  VARCHAR (30)  NULL,
    [Last_Updated]                  DATETIME      CONSTRAINT [DF_ProfLic_LastUpdated] DEFAULT (getdate()) NULL,
    [InUse]                         VARCHAR (8)   NULL,
    [CreatedDate]                   DATETIME      CONSTRAINT [DF_ProfLic_CreatedDate] DEFAULT (getdate()) NULL,
    [Status_A]                      VARCHAR (20)  NULL,
    [ToPending]                     DATETIME      NULL,
    [FromPending]                   DATETIME      NULL,
    [Last_Worked]                   DATETIME      NULL,
    [IsCAMReview]                   BIT           CONSTRAINT [DF__ProfLic__IsCAMRe__288EB6CC] DEFAULT ((0)) NOT NULL,
    [IsOnReport]                    BIT           CONSTRAINT [DF__ProfLic__IsOnRep__2982DB05] DEFAULT ((0)) NOT NULL,
    [IsHidden]                      BIT           CONSTRAINT [DF__ProfLic__IsHidde__2A76FF3E] DEFAULT ((0)) NOT NULL,
    [IsHistoryRecord]               BIT           CONSTRAINT [DF__ProfLic__IsHisto__2B6B2377] DEFAULT ((0)) NOT NULL,
    [ClientAdjudicationStatus]      INT           NULL,
    [ClientRefID]                   VARCHAR (25)  NULL,
    [Lic_Type_V]                    VARCHAR (100) NULL,
    [Lic_No_V]                      VARCHAR (20)  NULL,
    [State_V]                       VARCHAR (8)   NULL,
    [Expire_V]                      DATETIME      NULL,
    [Year_V]                        VARCHAR (10)  NULL,
    [GenerateCertificate]           BIT           CONSTRAINT [DF_ProfLic_GenerateCertificate] DEFAULT ((0)) NULL,
    [CertificateAvailabilityStatus] INT           CONSTRAINT [DF_ProfLic_CertificateAvailabilityStatus] DEFAULT ((2)) NULL,
    [DisclosedPastAction]           BIT           NULL,
    [InUse_TimeStamp]               DATETIME      NULL,
    [NameOnLicense_V]               VARCHAR (200) NULL,
    [Speciality_V]                  VARCHAR (50)  NULL,
    [LifeTime_V]                    BIT           CONSTRAINT [DF_ProfLic_LifeTime] DEFAULT ((0)) NULL,
    [MultiState_V]                  VARCHAR (15)  NULL,
    [BoardActions_V]                VARCHAR (10)  NULL,
    [ContactMethod_V]               VARCHAR (50)  NULL,
    [LicenseTypeID]                 INT           NULL,
    [SectSubStatusID]               INT           NULL,
    [Is_Investigator_Qualified]     BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ProfLic] PRIMARY KEY CLUSTERED ([ProfLicID] ASC, [Apno] ASC) ON [PS1_ProfLic] ([Apno]),
    CONSTRAINT [FK_PersLic_SectSubStatus] FOREIGN KEY ([SectSubStatusID]) REFERENCES [dbo].[SectSubStatus] ([SectSubStatusID]),
    CONSTRAINT [FK_ProfLic_Appl] FOREIGN KEY ([Apno]) REFERENCES [dbo].[Appl] ([APNO])
) ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_ProfLic_Apno]
    ON [dbo].[ProfLic]([Apno] ASC, [ProfLicID] ASC, [GenerateCertificate] ASC) WITH (FILLFACTOR = 75)
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_SectStat]
    ON [dbo].[ProfLic]([SectStat] ASC, [Investigator] ASC, [IsOnReport] ASC, [Apno] ASC)
    INCLUDE([ProfLicID]) WITH (FILLFACTOR = 75)
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IDX_ProfLic_Apno]
    ON [dbo].[ProfLic]([IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([Apno])
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IsOnReport_IsHidden_SectStat_Includes]
    ON [dbo].[ProfLic]([IsOnReport] ASC, [IsHidden] ASC, [SectStat] ASC)
    INCLUDE([ProfLicID], [Apno], [CreatedDate], [BoardActions_V], [SectSubStatusID]) WITH (FILLFACTOR = 100)
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [SectStat_Last_Worked]
    ON [dbo].[ProfLic]([SectStat] ASC, [Last_Worked] ASC) WITH (FILLFACTOR = 100)
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_ProfLic_webupdated_last_worked]
    ON [dbo].[ProfLic]([web_updated] ASC, [Last_Worked] ASC)
    ON [PS1_ProfLic] ([ProfLicID]);


GO
CREATE NONCLUSTERED INDEX [IX_ProfLic_Last_Worked]
    ON [dbo].[ProfLic]([Last_Worked] ASC)
    INCLUDE([SectStat], [web_updated], [Investigator])
    ON [PS1_ProfLic] ([ProfLicID]);


GO
CREATE NONCLUSTERED INDEX [IX_ProfLic_ApNo_IsOnReport_SectStat]
    ON [dbo].[ProfLic]([Apno] ASC, [IsOnReport] ASC, [SectStat] ASC)
    INCLUDE([ProfLicID]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_ProfLic_ApNo_Inc]
    ON [dbo].[ProfLic]([Apno] ASC)
    INCLUDE([SectStat], [Last_Updated])
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE NONCLUSTERED INDEX [IX_ProfLic_SectStat]
    ON [dbo].[ProfLic]([SectStat] ASC)
    INCLUDE([Apno], [Last_Updated])
    ON [PS1_ProfLic] ([Apno]);


GO
CREATE TRIGGER [dbo].[Lic_web_history] on [dbo].[ProfLic]
for update
as
if update(web_status)
BEGIN
 

	insert dbo.web_lic_history(history_apno,proflicid,history_date,history_status)
	Select I.apno, I.proflicid, CURRENT_TIMESTAMP,I.web_status 
	FROM  INSERTED I 
	 INNER JOIN DELETED D
	 ON I.ProfLicID = D.ProfLicID
	 WHERE 	ISNULL(I.web_status,-1) <> ISNULL(D.web_status,-1)
END 
GO
CREATE TRIGGER [dbo].[Lwebupdate] on [dbo].[ProfLic]
for update
 as
--if update(web_status) AND (select isnull(web_status,-1) from inserted) <> (select isnull(web_status,-1) from deleted)
--update proflic
--set web_updated = getdate()
--where proflicid = (select proflicid from inserted)
Return
--schapyala updated to handle batch updates -5/5/13
	UPDATE A SET  web_updated = CURRENT_TIMESTAMP 
	 FROM dbo.proflic A INNER JOIN INSERTED I 
	 ON A.proflicid = I.proflicid
	 INNER JOIN DELETED D
	 ON I.proflicid = D.proflicid
	 WHERE 	ISNULL(I.web_status,-1) <> ISNULL(D.web_status,-1)
GO
DISABLE TRIGGER [dbo].[Lwebupdate]
    ON [dbo].[ProfLic];


GO
CREATE TRIGGER [dbo].[Licpendingupdated] on [dbo].[ProfLic]
for update
as
--if update(sectstat) AND (select isnull(sectstat,-1) from inserted) <> (select isnull(sectstat,-1) from deleted)
--update proflic
-- set pendingupdated = convert(varchar,getdate(),101)
--where proflicid = (select proflicid from inserted)
Return
--schapyala updated to handle batch updates -5/5/13
	UPDATE A SET  pendingupdated = convert(varchar,CURRENT_TIMESTAMP,101) 
	 FROM dbo.proflic A INNER JOIN INSERTED I 
	 ON A.proflicid = I.proflicid
	 INNER JOIN DELETED D
	 ON I.proflicid = D.proflicid
	 WHERE 	ISNULL(I.sectstat,-1) <> ISNULL(D.sectstat,-1)

GO
DISABLE TRIGGER [dbo].[Licpendingupdated]
    ON [dbo].[ProfLic];


GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated and web_updated for client traceability. Disabled old triggers and combined them into a new one
*/

CREATE TRIGGER [dbo].[ProfLic_Updated] on [dbo].[ProfLic]
for update
as
BEGIN
if update(sectstat) 
	 update  E set
	   pendingupdated = convert(varchar,getdate(),101),Last_updated = Current_Timestamp
	FROM dbo.proflic E INNER JOIN inserted I 
	ON (E.proflicid = I.proflicid)
	INNER JOIN  deleted D
	ON I.proflicid = D.proflicid 
	Where isnull(i.sectstat,'') <> isnull(d.sectstat,'')

if update(Lic_Type_V) or update(Lic_No_V) or update(State_V) or update(Expire_V) or update(Year_V) or update(Speciality_V)  or update(LifeTime_V) or update(MultiState_V) or update(BoardActions_V) or update(ContactMethod_V)  or update(Pub_Notes) or update(Organization) or update(Contact_Name) or update(Contact_Title) or update(Contact_Date) or update(NameOnLicense_V)
	update  E set
	Last_updated = Current_Timestamp
	FROM dbo.proflic E INNER JOIN inserted I 
	ON (E.proflicid = I.proflicid)
	INNER JOIN  deleted D
	ON I.proflicid = D.proflicid 
	Where (isnull(i.Lic_Type_V,'') <> isnull(d.Lic_Type_V,'')) 
	or  (isnull(i.Lic_No_V,'') <> isnull(d.Lic_No_V,'')) 
	or (isnull(i.State_V,'') <> isnull(d.State_V,'')) 
	or (isnull(i.Expire_V,'') <> isnull(d.Expire_V,'')) 
	or (isnull(i.Year_V,'') <> isnull(d.Year_V,'')) 
	or (isnull(i.Speciality_V,'') <> isnull(d.Speciality_V,'')) 
	or (isnull(i.LifeTime_V,0) <> isnull(d.LifeTime_V,0)) 
	or (isnull(i.MultiState_V,'') <> isnull(d.MultiState_V,''))
	or (isnull(i.BoardActions_V,'') <> isnull(d.BoardActions_V,'')) 
	or (isnull(i.ContactMethod_V,'') <> isnull(d.ContactMethod_V,'')) 
	or  (Isnull(I.Pub_Notes,'') <> Isnull(D.Pub_Notes,'')) 
	or  (Isnull(I.Organization,'') <> Isnull(D.Organization,'')) 
	or  (Isnull(I.Contact_Name,'') <> Isnull(D.Contact_Name,'')) 
	or  (Isnull(I.Contact_Title,'') <> Isnull(D.Contact_Title,'')) 
	or  (Isnull(I.NameOnLicense_V,'') <> Isnull(D.NameOnLicense_V,'')) 
	or  (Isnull(I.Contact_Date,'1/1/1900') <> Isnull(D.Contact_Date,'1/1/1900')) 


if update(web_status)
	 update  E set
	   web_updated = CURRENT_TIMESTAMP
	FROM dbo.proflic E INNER JOIN inserted I 
	ON (E.proflicid = I.proflicid)
	INNER JOIN  deleted D
	ON I.proflicid = D.proflicid 
	WHERE ISNULL(I.web_status,-1) <> ISNULL(D.web_status,-1)


End