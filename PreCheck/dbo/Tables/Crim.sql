CREATE TABLE [dbo].[Crim] (
    [CrimID]                     INT            IDENTITY (187309, 1) NOT NULL,
    [APNO]                       INT            NOT NULL,
    [County]                     VARCHAR (40)   NOT NULL,
    [Clear]                      VARCHAR (1)    NULL,
    [Ordered]                    VARCHAR (20)   NULL,
    [Name]                       VARCHAR (100)  NULL,
    [DOB]                        DATETIME       NULL,
    [SSN]                        VARCHAR (11)   NULL,
    [CaseNo]                     VARCHAR (50)   NULL,
    [Date_Filed]                 DATETIME       NULL,
    [Degree]                     VARCHAR (1)    NULL,
    [Offense]                    VARCHAR (1000) NULL,
    [Disposition]                VARCHAR (500)  NULL,
    [Sentence]                   VARCHAR (1000) NULL,
    [Fine]                       VARCHAR (100)  NULL,
    [Disp_Date]                  DATETIME       NULL,
    [Pub_Notes]                  VARCHAR (MAX)  NULL,
    [Priv_Notes]                 VARCHAR (MAX)  NULL,
    [txtalias]                   CHAR (2)       CONSTRAINT [DF_Crim_txtalias] DEFAULT ((0)) NULL,
    [txtalias2]                  CHAR (2)       CONSTRAINT [DF_Crim_txtalias2] DEFAULT ((0)) NULL,
    [txtalias3]                  CHAR (2)       CONSTRAINT [DF_Crim_txtalias3] DEFAULT ((0)) NULL,
    [txtalias4]                  CHAR (2)       CONSTRAINT [DF_Crim_txtalias4] DEFAULT ((0)) NULL,
    [uniqueid]                   FLOAT (53)     NULL,
    [txtlast]                    CHAR (2)       CONSTRAINT [DF_Crim_txtlast] DEFAULT (1) NULL,
    [Crimenteredtime]            DATETIME       CONSTRAINT [DF_Crim_Crimenteredtime] DEFAULT (getdate()) NULL,
    [Last_Updated]               DATETIME       CONSTRAINT [DF_Crim_Last_Updated] DEFAULT (getdate()) NULL,
    [CNTY_NO]                    INT            NULL,
    [IRIS_REC]                   VARCHAR (3)    NULL,
    [CRIM_SpecialInstr]          VARCHAR (MAX)  NULL,
    [Report]                     VARCHAR (MAX)  NULL,
    [batchnumber]                FLOAT (53)     NULL,
    [crim_time]                  VARCHAR (50)   NULL,
    [vendorid]                   VARCHAR (50)   NULL,
    [deliverymethod]             VARCHAR (50)   NULL,
    [countydefault]              VARCHAR (50)   NULL,
    [status]                     VARCHAR (50)   NULL,
    [b_rule]                     VARCHAR (50)   NULL,
    [tobeworked]                 BIT            NULL,
    [readytosend]                BIT            NULL,
    [NoteToVendor]               VARCHAR (50)   NULL,
    [test]                       VARCHAR (50)   NULL,
    [InUse]                      BIT            CONSTRAINT [DF_Crim_InUse] DEFAULT (0) NULL,
    [parentCrimID]               INT            NULL,
    [IrisFlag]                   VARCHAR (10)   NULL,
    [IrisOrdered]                DATETIME       NULL,
    [Temporary]                  BIT            CONSTRAINT [DF_Crim_Temporary] DEFAULT (0) NULL,
    [CreatedDate]                DATETIME       NULL,
    [IsCAMReview]                BIT            DEFAULT ((0)) NOT NULL,
    [IsHidden]                   BIT            DEFAULT ((0)) NOT NULL,
    [IsHistoryRecord]            BIT            DEFAULT ((0)) NOT NULL,
    [AliasParentCrimID]          INT            NULL,
    [InUseByIntegration]         VARCHAR (50)   NULL,
    [ClientAdjudicationStatus]   INT            NULL,
    [AutoCheckAlias]             BIT            NULL,
    [AdmittedRecord]             BIT            DEFAULT ((0)) NULL,
    [RefDispositionID]           INT            NULL,
    [RefCrimStageID]             INT            CONSTRAINT [DF_RefCrimStageID] DEFAULT ((1)) NULL,
    [PartnerReferenceLeadNumber] VARCHAR (50)   CONSTRAINT [DF_PartnerReferenceLeadNumber] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Crim] PRIMARY KEY CLUSTERED ([CrimID] ASC, [APNO] ASC) WITH (FILLFACTOR = 90) ON [PS1_Crim] ([APNO]),
    CONSTRAINT [FK_Crim_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_Crim_Counties] FOREIGN KEY ([CNTY_NO]) REFERENCES [dbo].[TblCounties] ([CNTY_NO])
) ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_2]
    ON [dbo].[Crim]([Clear] ASC, [CrimID] ASC, [readytosend] ASC, [status] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_AliasParentCrimID]
    ON [dbo].[Crim]([AliasParentCrimID] ASC, [CrimID] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_APNO_CntyNo]
    ON [dbo].[Crim]([APNO] ASC, [CNTY_NO] ASC, [CrimID] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_APNO_County]
    ON [dbo].[Crim]([APNO] ASC, [County] ASC, [CrimID] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_Clear]
    ON [dbo].[Crim]([APNO] ASC, [Clear] ASC, [IRIS_REC] ASC, [IsHidden] ASC, [status] ASC, [CNTY_NO] ASC, [vendorid] ASC, [Ordered] ASC, [batchnumber] ASC, [County] ASC, [CrimID] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_VendorID]
    ON [dbo].[Crim]([CrimID] ASC, [vendorid] ASC, [APNO] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_IrisRecBtchNum]
    ON [dbo].[Crim]([IRIS_REC] ASC, [batchnumber] ASC, [readytosend] ASC, [vendorid] ASC, [Clear] ASC, [Crimenteredtime] ASC, [APNO] ASC, [CrimID] ASC, [IrisOrdered] ASC) WITH (FILLFACTOR = 90)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IDX_Crim_IsHidden]
    ON [dbo].[Crim]([IsHidden] ASC, [Clear] ASC)
    INCLUDE([CrimID], [APNO], [County], [Ordered], [Crimenteredtime], [Last_Updated], [CNTY_NO], [vendorid], [deliverymethod], [IrisOrdered]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Crim_LastUpdated_IrisOrdered]
    ON [dbo].[Crim]([Last_Updated] ASC, [IrisOrdered] ASC)
    INCLUDE([CNTY_NO], [vendorid]) WITH (FILLFACTOR = 70)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [idx_Crim_Ordered]
    ON [dbo].[Crim]([Ordered] ASC)
    INCLUDE([CrimID], [APNO], [County], [Clear], [CNTY_NO], [vendorid]) WITH (FILLFACTOR = 95)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [batchnumber_readytosend_Includes]
    ON [dbo].[Crim]([batchnumber] ASC, [readytosend] ASC)
    INCLUDE([CrimID], [APNO], [Clear], [Crimenteredtime], [CNTY_NO], [IRIS_REC], [vendorid], [IrisOrdered]) WITH (FILLFACTOR = 100)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [batchnumber_IsHidden_Includes]
    ON [dbo].[Crim]([batchnumber] ASC, [IsHidden] ASC)
    INCLUDE([APNO], [Clear], [Crimenteredtime], [CNTY_NO], [IRIS_REC], [vendorid], [b_rule], [readytosend]) WITH (FILLFACTOR = 100)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_ParentCrimID]
    ON [dbo].[Crim]([parentCrimID] ASC)
    INCLUDE([CrimID], [APNO], [Clear])
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_Clear_Includes]
    ON [dbo].[Crim]([Clear] ASC)
    INCLUDE([APNO], [vendorid])
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_IsHidden_RefCrimStageID]
    ON [dbo].[Crim]([IsHidden] ASC, [RefCrimStageID] ASC)
    INCLUDE([CrimID], [Clear], [APNO], [County], [CNTY_NO])
    ON [PS1_Crim] ([CrimID]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_Cityno_LastUp_IrisOrd_Ordered]
    ON [dbo].[Crim]([CNTY_NO] ASC, [Last_Updated] ASC, [IrisOrdered] ASC)
    INCLUDE([Ordered]) WITH (FILLFACTOR = 95)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_IsHidden_Batchnumber_Status_Includes]
    ON [dbo].[Crim]([IsHidden] ASC, [batchnumber] ASC, [status] ASC)
    INCLUDE([CrimID], [APNO], [Ordered], [CNTY_NO], [IrisOrdered]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Crim_CNTY_NO_Includes]
    ON [dbo].[Crim]([CNTY_NO] ASC)
    INCLUDE([CrimID], [APNO], [County], [Clear], [Name], [CaseNo], [Date_Filed], [Degree], [Offense], [Disposition], [Sentence], [Fine], [Disp_Date], [vendorid], [IrisOrdered], [IsHidden]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Crim_Clear_IRIS_REC_batchnumber_IsHidden]
    ON [dbo].[Crim]([Clear] ASC, [IRIS_REC] ASC, [batchnumber] ASC, [IsHidden] ASC)
    INCLUDE([APNO], [Crimenteredtime], [CNTY_NO], [vendorid], [b_rule], [readytosend]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Crim_IsHidden_LastUpdated]
    ON [dbo].[Crim]([IsHidden] ASC, [Last_Updated] ASC)
    INCLUDE([APNO], [Clear]) WITH (FILLFACTOR = 95)
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_ClientAdjudicationStatus]
    ON [dbo].[Crim]([ClientAdjudicationStatus] ASC)
    INCLUDE([APNO])
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_CrimID]
    ON [dbo].[Crim]([CrimID] ASC)
    INCLUDE([PartnerReferenceLeadNumber])
    ON [PS1_Crim] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_Crim_ApNo_Inc]
    ON [dbo].[Crim]([APNO] ASC)
    INCLUDE([CrimID], [CNTY_NO], [IrisOrdered], [IsHidden], [RefCrimStageID], [PartnerReferenceLeadNumber], [Clear], [Last_Updated]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE TRIGGER [dbo].[UpdateCrimStatus] on [dbo].[Crim]
For UPDATE
AS
If Update(clear)
  update crim 
  set last_updated = getdate()
  from crim,inserted,deleted
   where crim.crimid = inserted.crimid and 
inserted.crimid = deleted.crimid and
isnull(deleted.clear,'') <> isnull(inserted.clear,'')
-- update crim 
--  set last_updated = getdate()
--  from inserted
--   where crim.crimid = inserted.crimid


GO
DISABLE TRIGGER [dbo].[UpdateCrimStatus]
    ON [dbo].[Crim];


GO









CREATE TRIGGER [dbo].[UpdateAliasFields] ON [dbo].[Crim] 
FOR INSERT

AS
UPDATE C SET  txtalias =  CASE WHEN (researcher_aliases_count = 'All' or isnull(TRY_PARSE(researcher_aliases_count as int),0)>0) AND isnull(rtrim(alias1_last), '')<> '' then 1 else 0 end,
			  txtalias2 = CASE WHEN (researcher_aliases_count = 'All' or isnull(TRY_PARSE(researcher_aliases_count as int),0)>1) AND isnull(rtrim(alias2_last), '')<> '' then 1 else 0 end,
			  txtalias3 = CASE WHEN (researcher_aliases_count = 'All' or isnull(TRY_PARSE(researcher_aliases_count as int),0)>2) AND isnull(rtrim(alias3_last), '')<> '' then 1 else 0 end,
			  txtalias4 = CASE WHEN (researcher_aliases_count = 'All' or isnull(TRY_PARSE(researcher_aliases_count as int),0)>3) AND isnull(rtrim(alias4_last), '')<> '' then 1 else 0 end
	 FROM dbo.Crim C INNER JOIN INSERTED I ON C.CrimID = I.CrimID
	 --INNER JOIN DELETED D ON I.CrimID = D.CrimID
	 INNER JOIN DBO.APPL A (NOLOCK) on I.APNO = A.APNO
	 INNER JOIN DBO.iris_researcher_charges RC (NOLOCK) ON I.VendorID = RC.researcher_id AND I.CNTY_NO = RC.CNTY_NO

/* schapyala commented this and added the above SQL to handle multiple inserts at a given time - 02/11/14
--cchaupin 5/20/08 to handle multiple records inserted on one command
if (Select Count(*) FROM Inserted) > 1
RETURN;

Declare @Crimid int
Declare @cnty_no int
Declare @my_vendorid int
Declare @appno int
Declare @my_Aliases varchar(20) 
Declare @my_Alias1 varchar(50) 
Declare @my_Alias2 varchar(50) 
Declare @my_Alias3 varchar(50) 
Declare @my_Alias4 varchar(50) 

      Set @Crimid = (Select crimid from inserted)
      Set @cnty_no = (Select CNTY_NO from inserted)
      Set @appno = (Select apno from inserted)
      Select @my_Alias1 = nullif(rtrim(alias1_last), ''),
                 @my_Alias2 = nullif(rtrim(alias2_last), ''),
                 @my_Alias3 = nullif(rtrim(alias3_last), ''),
                 @my_Alias4 = nullif(rtrim(alias4_last), '')
                 from appl   where apno = @appno
   
  set  @my_vendorid = (select Vendorid from crim where crimid = @crimid)
  set @my_Aliases = (select researcher_aliases_count from iris_researcher_charges where (researcher_id = @my_vendorid)  and (cnty_no = @cnty_no))
   
 If (@my_Aliases =  'ALL' and @cnty_no = 2480)
     Begin
					UPDATE Crim
                   SET txtalias = 1,txtalias2 = 1,txtalias3 = 1,txtalias4 = 1
                   WHERE (crimid = @crimid)

	End

 
     If (@my_Aliases =  'ALL' and @cnty_no <> 2480)
     Begin
         Begin
           IF (@my_alias1 is NULL) or (@my_alias1 = '')
               begin
                   UPDATE Crim
                   SET txtalias = 0
                   WHERE (crimid = @crimid)
               end
          else
              begin
                   UPDATE Crim
                   SET txtalias = 1
                   WHERE (crimid = @crimid)
               end
   
           IF (@my_alias2 is NULL) or (@my_alias2 = '')
               begin
                   UPDATE Crim
                   SET txtalias2 = 0
                   WHERE (crimid = @crimid)
               end
               else
               begin
                   UPDATE Crim
                   SET txtalias2 = 1
                   WHERE (crimid = @crimid)
               end

            IF (@my_alias3 is NULL) or (@my_alias3 = '')
               begin
                   UPDATE Crim
                   SET txtalias3 = 0
                   WHERE (crimid = @crimid)
               end
               else
               begin
                   UPDATE Crim
                   SET txtalias3 = 1
                   WHERE (crimid = @crimid)
               end

            IF (@my_alias4 is NULL) or (@my_alias4 = '')
               begin
                   UPDATE Crim
                   SET txtalias4 = 0
                   WHERE (crimid = @crimid)
               end
               else
               begin
                   UPDATE Crim
                   SET txtalias4 = 1
                   WHERE (crimid = @crimid)
               end
       END
	   
	          END      
*/
--       begin
--                   UPDATE Crim
--                   SET readytosend = 1,txtlast = 1
--                   WHERE (crimid = @crimid)
--       end




   
   













GO
DISABLE TRIGGER [dbo].[UpdateAliasFields]
    ON [dbo].[Crim];


GO

/*
Author: schapyala
Created: 04/07/14
Purpose: To update last_updated for client traceability
*/
CREATE TRIGGER [dbo].[Crim_LastUpdated] on [dbo].[Crim]
For UPDATE
AS

if update(clear) or update(Ordered) or update(CaseNo) or update(Date_Filed) or update(Degree) or update(Offense) or update(Disposition) or update(Sentence) or update(Fine) or update(Disp_Date) or update(Pub_Notes) or update(ClientAdjudicationStatus)  --or update(IsHidden) 
	update  C set
	Last_updated = Current_Timestamp
	FROM dbo.crim C INNER JOIN inserted I 
	ON (C.crimid = I.crimid)
	INNER JOIN  deleted D
	ON I.crimid = D.crimid
	Where (isnull(i.clear,'') <> isnull(d.clear,'') )
		or (isnull(i.Ordered,'') <> isnull(d.Ordered,''))
		or (isnull(i.CaseNo,'') <> isnull(d.CaseNo,''))
		or (isnull(i.Date_Filed,'1/1/1900') <> isnull(d.Date_Filed,'1/1/1900')) 
		or (isnull(i.Degree,'') <> isnull(d.Degree,'')) 
		or (isnull(i.Offense,'') <> isnull(d.Offense,'')) 
		or (isnull(i.Disposition,'') <> isnull(d.Disposition,'')) 
		or (isnull(i.Sentence,'') <> isnull(d.Sentence,'')) 
		or (isnull(i.Fine,'') <> isnull(d.Fine,''))  
		or (isnull(i.Disp_Date,'1/1/1900') <> isnull(d.Disp_Date,'1/1/1900')) 
		--or (isnull(i.IsHidden,0) <> isnull(d.IsHidden,0)) 
		or (isnull(i.ClientAdjudicationStatus,'') <> isnull(d.ClientAdjudicationStatus,'')) 
GO
CREATE TRIGGER [dbo].[Iris_OrderedSearch] ON [dbo].[Crim] 
FOR  UPDATE 
AS



if update(batchnumber)
 insert iris_searchesordered(APNO,Last,First,Middle,Ordered,CrimID,cnty_no,R_id,R_Name,txtlast,txtalias,
txtalias2,txtalias3,txtalias4,Researcher_Fel,Researcher_Mis,Researcher_fed,
 Researcher_alias,Researcher_combo,Researcher_other,Researcher_CourtFees,Researcher_Aliases_count)
select i.apno,a.last,a.first,a.middle,i.ordered,i.crimid,i.cnty_no,i.vendorid,r_name,i.txtlast,i.txtalias
,i.txtalias2,i.txtalias3,i.txtalias4,
cast(iris_researcher_charges.researcher_fel as money),
cast(iris_researcher_charges.researcher_mis as money),
cast(iris_researcher_charges.researcher_fed as money),
cast(iris_researcher_charges.researcher_alias as money),
cast(iris_researcher_charges.researcher_combo as money),
cast(iris_researcher_charges.researcher_other as money),
cast(iris_researcher_charges.researcher_courtfees as money),
iris_researcher_charges.researcher_aliases_count 
from inserted i inner join appl a on a.apno = i.apno
inner join deleted d on i.crimid = d.crimid
INNER JOIN
                      dbo.Iris_Researcher_Charges ON i.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no AND 
                      i.vendorid = dbo.Iris_Researcher_Charges.Researcher_id INNER JOIN
                      dbo.Iris_Researchers ON dbo.Iris_Researcher_Charges.Researcher_id = dbo.Iris_Researchers.R_id
where isnull(d.batchnumber,'') <> isnull(i.batchnumber,'')

-- insert iris_searchesordered(APNO,Last,First,Middle,Ordered,CrimID,cnty_no,R_id,R_Name,txtlast,txtalias,
--txtalias2,txtalias3,txtalias4,Researcher_Fel,Researcher_Mis,Researcher_fed,
-- Researcher_alias,Researcher_combo,Researcher_other,Researcher_CourtFees,Researcher_Aliases_count)
--select inserted.apno,appl.last,appl.first,appl.middle,ordered,crimid,inserted.cnty_no,vendorid,r_name,txtlast,txtalias
--,txtalias2,txtalias3,txtalias4,
--cast(iris_researcher_charges.researcher_fel as money),
--cast(iris_researcher_charges.researcher_mis as money),
--cast(iris_researcher_charges.researcher_fed as money),
--cast(iris_researcher_charges.researcher_alias as money),
--cast(iris_researcher_charges.researcher_combo as money),
--cast(iris_researcher_charges.researcher_other as money),
--cast(iris_researcher_charges.researcher_courtfees as money),
--iris_researcher_charges.researcher_aliases_count 
--from inserted join appl on appl.apno = inserted.apno
--INNER JOIN
--                      dbo.Iris_Researcher_Charges ON inserted.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no AND 
--                      inserted.vendorid = dbo.Iris_Researcher_Charges.Researcher_id INNER JOIN
--                      dbo.Iris_Researchers ON dbo.Iris_Researcher_Charges.Researcher_id = dbo.Iris_Researchers.R_id




GO
DISABLE TRIGGER [dbo].[Iris_OrderedSearch]
    ON [dbo].[Crim];


GO
CREATE trigger [dbo].[web_criminal_history] on [dbo].[Crim]
for update
as
if update(clear)

 insert crim_web_history(clear,apno,crimid,cnty_no,crimenteredtime,changedate,batchnumber,ordered,status,userid,iris_flag)
	select i.clear,i.apno,i.crimid,i.cnty_no,i.crimenteredtime,getdate(),i.batchnumber,i.ordered,i.status,a.inuse,i.irisflag
	from inserted i inner join appl a on a.apno=i.apno
inner join deleted d on i.crimid = d.crimid
where isnull(i.clear,'') <> isnull(d.clear,'')
-- insert crim_web_history(clear,apno,crimid,cnty_no,crimenteredtime,changedate,batchnumber,ordered,status,userid,iris_flag)
--	select clear,inserted.apno,crimid,cnty_no,crimenteredtime,getdate(),batchnumber,ordered,status,appl.inuse,irisflag
--	from inserted join appl on appl.apno=inserted.apno

GO
DISABLE TRIGGER [dbo].[web_criminal_history]
    ON [dbo].[Crim];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Crim', @level2type = N'COLUMN', @level2name = N'Last_Updated';

