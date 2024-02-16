CREATE TABLE [dbo].[Civil] (
    [CivilID]      INT           IDENTITY (1437, 1) NOT NULL,
    [APNO]         INT           NOT NULL,
    [County]       VARCHAR (25)  NULL,
    [Clear]        VARCHAR (1)   NULL,
    [Ordered]      VARCHAR (14)  NULL,
    [Name]         VARCHAR (30)  NULL,
    [Plaintiff]    VARCHAR (30)  NULL,
    [CaseNo]       VARCHAR (14)  NULL,
    [Date_Filed]   DATETIME      NULL,
    [CaseType]     VARCHAR (30)  NULL,
    [Disp_Date]    DATETIME      NULL,
    [Pub_Notes]    VARCHAR (MAX) NULL,
    [Priv_Notes]   VARCHAR (MAX) NULL,
    [Last_Updated] DATETIME      NULL,
    [CNTY_NO]      INT           NULL,
    [InUse]        VARCHAR (8)   NULL,
    [CreatedDate]  DATETIME      NULL,
    CONSTRAINT [PK_Civil] PRIMARY KEY NONCLUSTERED ([CivilID] ASC, [APNO] ASC) WITH (FILLFACTOR = 50) ON [PS1_Civil] ([APNO]),
    CONSTRAINT [FK_Civil_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_Civil_Counties] FOREIGN KEY ([CNTY_NO]) REFERENCES [dbo].[TblCounties] ([CNTY_NO])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_Civil_Apno_County]
    ON [dbo].[Civil]([APNO] ASC, [County] ASC) WITH (FILLFACTOR = 50)
    ON [PS1_Civil] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Civil_County]
    ON [dbo].[Civil]([County] ASC, [Clear] ASC, [APNO] ASC) WITH (FILLFACTOR = 50)
    ON [PS1_Civil] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Civil_ApNo]
    ON [dbo].[Civil]([APNO] ASC)
    INCLUDE([Clear], [Last_Updated])
    ON [PRIMARY];


GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated for client traceability
*/

CREATE TRIGGER [dbo].[Civil_LastUpdated] on [dbo].[Civil]
for update
as

if update(clear) or update(Ordered) or update(CaseNo) or update(Date_Filed) or update(CaseType) or update(Disp_Date) or update(Pub_Notes)  
	update  C set
	Last_updated = Current_Timestamp
	FROM dbo.Civil C INNER JOIN inserted I 
	ON (C.CivilID = I.CivilID)
	INNER JOIN  deleted D
	ON I.CivilID = D.CivilID
	Where (isnull(i.clear,'') <> isnull(d.clear,'') )
		or (isnull(i.Ordered,'') <> isnull(d.Ordered,''))
		or (isnull(i.CaseNo,'') <> isnull(d.CaseNo,''))
		or (isnull(i.CaseType,'') <> isnull(d.CaseType,''))
		or (isnull(i.Pub_Notes,'') <> isnull(d.Pub_Notes,''))
		or (isnull(i.Date_Filed,'1/1/1900') <> isnull(d.Date_Filed,'1/1/1900')) 
		or (isnull(i.Disp_Date,'1/1/1900') <> isnull(d.Disp_Date,'1/1/1900')) 

