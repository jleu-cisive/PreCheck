-- =============================================
-- Author:		Vairavan  A
-- Create date: 11/17/2022
--Ticket No - 62753 New QReport to be called CLNO Change
-- EXEC [Qreport_ClnoChange] '05/01/2022','06/30/2022',0,0
-- =============================================
Create PROCEDURE [dbo].[Qreport_ClnoChange_Backup]
-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime,
@AffiliateID int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
select  Tablename, cast(NULL as smallint) as CLNO,id as Report#,cast(NULL as varchar(100) ) as ClientName,cast(NULl as int) as Affiliate,
       OldValue,NewValue,ChangeDate,cast(NULL as datetime ) as Appdate,UserID,cast(null as varchar(255)) as  EnteredVia,cast(NULL as Varchar(max)) as  Priv_Notes 
into #tmp
from changelog with(nolock)
where tablename like '%CLNO%'

Update a
set a.Appdate    = b.apdate,
	a.EnteredVia = b.EnteredVia,
	a.Priv_Notes = b.Priv_Notes,
	a.clno =   b.CLNO
from 
	(
	select *
	from #tmp
	where tablename = 'Appl.CLNO'
	)a 
	inner join 
	APPL b with(nolock)
	on(a.Report# = b.apno)
	--select * from #tmp where tablename = 'Appl.CLNO'


Update a
set  a.clno =   b.CLNO,
	a.Appdate    = b.NoteDate,
	a.EnteredVia = b.NoteType,
	a.Priv_Notes = b.NoteText
from 
	(
	select *
	from #tmp
	where tablename = 'ClientNotes.clno'
	)a 
	inner join 
	clientnotes b with(nolock)
	on(a.Report# = b.NoteID)

Update a
set  a.clno =   b.CLNO,
	a.Appdate    = b.date,
	a.EnteredVia = b.EnteredVia,
	a.Priv_Notes = NULL
from 
	(
	select *
	from #tmp
	where tablename = 'ReleaseForm.CLNO'
	)a 
	inner join 
	ReleaseForm b with(nolock)
	on(a.Report# = b.ReleaseFormID)

Update a
set  a.clno =   b.CLNO
from 
	(
	select *
	from #tmp
	where tablename = 'refRequirementText.CLNO'
	)a 
	inner join 
	refRequirementText b with(nolock)
	on(a.Report# = b.RequirementTextID)


Update a
set a.ClientName = b.Name,
	a.Affiliate = b.AffiliateID
from 
	(
	select *
	from #tmp
	--where tablename = 'Appl.CLNO'
	)a 
	inner join 
	client b with(nolock)
	on(a.CLNO = b.CLNO)
select * from #tmp

select top 10 ApDate,EnteredVia,Priv_Notes
from appl with(nolock)
where apno  in (85421,
85831,
85832,
85833,
85834,
0,
1,
2,
3,
83297) 

select top 10 name as clientname,AffiliateID
from client with(nolock)
where clno = 1052


END
