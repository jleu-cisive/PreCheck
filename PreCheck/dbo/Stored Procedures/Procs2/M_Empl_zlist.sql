

--[M_Empl_zlist] 'MRectenb','web_status'

CREATE PROCEDURE [dbo].[M_Empl_zlist]
(
	@investigator varchar(30)
	, @t_sortby varchar(20)
)
AS
SET NOCOUNT ON

--Added by Douglas DeGenaro on 10/03/2013 
SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

CREATE TABLE #Empl_temp(
	[APNO] [int] NOT NULL,
	[ApDate] [datetime] NULL,
	[Employer] [varchar](50) NOT NULL,
	[State] [varchar](2) NULL,
	[city] [char](16) NULL,
	[ApStatus] [char](1) NOT NULL,	
	[web_status] [int] NULL,		
	[web_updated] [datetime] NULL,	
	[Investigator] [varchar](30) NULL,
	[Name] [varchar](100) NULL,
	[PrecheckChallenge] [bit] NULL,
	[Rush] [bit] NULL,
	[HighProfile] [bit] NULL,	
	[EmplId] [int] NOT NULL,
	[First] [varchar](20) NOT NULL,	
	[Last] [varchar](20) NOT NULL,
	[SI] [varchar](3) NOT NULL,
	[DateOrdered] [datetime] NULL,
	[OrderId] [varchar](20) NULL
	)
		



insert into #Empl_temp 

Select a.* from
	(SELECT A.APNO, A.ApDate, E.Employer, E.State, E.City, A.ApStatus, E.web_status, E.web_updated, E.Investigator, C.Name 
			, A.PrecheckChallenge, A.Rush, C.HighProfile, E.EmplID, A.First, A.Last 
			, CASE  WHEN A.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI',E.DateOrdered,E.OrderId 
		FROM dbo.Appl A 
			INNER JOIN dbo.Empl E ON A.APNO = E.APNO 
			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO 
		WHERE A.ApStatus IN ('P','W') 
			AND E.DNC = 0 
			AND E.SectStat = '9' 
			AND E.IsOnReport = 1 
			AND E.Investigator =  @investigator
		union
		SELECT A.APNO, A.ApDate, E.Employer, E.State, E.City, A.ApStatus, E.web_status, E.web_updated, E.Investigator, C.Name 
			, A.PrecheckChallenge, A.Rush, C.HighProfile, E.EmplID, A.First, A.Last 
			, CASE  WHEN A.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI',E.DateOrdered,E.OrderId 
		FROM dbo.Appl A 
			INNER JOIN dbo.Empl E ON A.APNO = E.APNO 
			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO 
			INNER JOIN dbo.ApplSections_Followup af ON e.EmplID = af.ApplSectionID and e.APNO = af.Apno and af.sectionid ='Empl'
	WHERE --A.ApStatus IN ('P','W')
		--AND 
		E.IsOnReport = 1
		--AND E.SectStat = '9'
		AND E.Investigator = @investigator
		AND --((af.IsCompleted is null and af.Repeat_Followup is null) or 
		(af.IsCompleted = 0 and af.Repeat_Followup = 0)
		and (FollowupOn < DATEADD(d,1,getdate()))) a
	

IF @t_sortby = 'no'

	Set @t_sortby = ' ApDate ASC'
else
begin
-- below if loop is done to use sorting in sql 2005 mode
if charindex('.',@t_sortby)>1

Set @t_sortby = 'a.' + substring(@t_sortby,3,len(@t_sortby))
End
--select @t_sortby

Exec ('select * from #Empl_temp a order by ' + @t_sortby)

Drop Table #Empl_temp

SET NOCOUNT OFF




