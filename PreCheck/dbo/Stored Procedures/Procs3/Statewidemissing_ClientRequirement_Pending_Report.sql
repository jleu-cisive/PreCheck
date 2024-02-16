
-- =============================================
-- Author:		Vairavan  A
-- Create date: 09/28/2021
-- Description: Statewide Missing Client Requirements and Pending Reports
--Ticket No - 11305 Client Requirements and Pending Reports - Statewide Missing
--Parameters should be dates, and have optional CLNO and Affiliate options.  When left as "0" should assume All. 
--Modified by Arindam Mitra on 02/02/2023 to add AffiliateId and Submission Date for ticket #70131
-- EXEC [Statewidemissing_ClientRequirement_Pending_Report] '05/01/2022','06/30/2022',0,0
-- =============================================
CREATE PROCEDURE [dbo].[Statewidemissing_ClientRequirement_Pending_Report]
-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime,
@CLNO int,
@AffiliateID int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
		drop table if exists #tmp
		
		drop table if exists #tmp_statewide
	
		Select a.APNO as [Report #],
			   b.AppStatusValue as  [Report Status],
			   c.CLNO,c.Name as  [Client Name],
			   a.First as  [Applicant First],
			   a.Last as  [Applicant Last],
			   a.DL_State as [Applicant State],
			   a.Investigator  as [AI Investigator],
			   sw.[Description] AS [Statewide],
			   PackageDesc, 
			 --  case when sc.StateCrimNotes is not null then 'True' else 'False' end as   [Has Statewide Crim]
			    cast('False' as varchar(25)) as   [Has Statewide Crim],
				cast('' as varchar(500)) as  [County/State (concatenated)],
				c.AffiliateID AS [AffiliateID], cast(a.ApDate as date) AS [Submission Date] --code added by Arindam for ticket id #70131
				into #tmp
		from APPL  a with (nolock)
			inner join 
			AppStatusDetail b with(nolock)
			on(a.ApStatus=b.AppStatusItem)
			inner join 
			Client c with(nolock)
			on(a.CLNO=c.CLNO)
			INNER JOIN
			dbo.refRequirementText rrt(NOLOCK)
			ON c.CLNO = rrt.CLNO
			LEFT OUTER JOIN
			dbo.refStatewide sw(NOLOCK) 
			ON rrt.StatewideID = sw.StateWideID
			left join 
			PackageMain d with(nolock)
			on(a.PackageID = d.PackageID)
		where sw.[Description] is not null
		AND  A.ApDate >= @StartDate  
		AND  A.ApDate <= @EndDate
		AND  C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
		AND  C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) 

		Select distinct cc.APNO,cast(Case when (a.[Statewide] like '%Always%' or a.[Statewide] like '%Only%') then 1 else 0 end as bit) as Is_alwaysorOnly,
			           cast(Case when cc.County like '%state%' then 1 else 0 end as bit) as Is_statewide,
					   cc.County
					   into #tmp_statewide
		from #tmp a 
			 inner join 
			 Crim cc with(nolock)
		on(a.[Report #] = cc.APNO)
		where cc.County like '%state%'

		Update a 
		set a.[Has Statewide Crim] = case when  b.Is_alwaysorOnly = 1 and b.Is_statewide = 1 then 'True' else 'False' end,
			a.[County/State (concatenated)]  =  case when  b.Is_alwaysorOnly = 1 and b.Is_statewide = 1 then b.County else NULL end
		from #tmp  a 
			 inner join 
			 #tmp_statewide b
		on(a.[Report #] = b.APNO) 
		

		Select *
		from #tmp

	/*
		Select a.APNO as [Report #],
			   b.AppStatusValue as  [Report Status],
			   c.CLNO,c.Name as  [Client Name],
			   a.First as  [Applicant First],
			   a.Last as  [Applicant Last],
			   a.Investigator  as [AI Investigator],
			   sw.[Description] AS [Statewide],
			   PackageDesc, 
			   case when sc.StateCrimNotes is not null then 'True' else 'False' end as   [Has Statewide Crim]--,sc.StateCrimNotes
		from APPL  a with (nolock)
			inner join 
			AppStatusDetail b with(nolock)
			on(a.ApStatus=b.AppStatusItem)
			inner join 
			Client c with(nolock)
			on(a.CLNO=c.CLNO)
			INNER JOIN
			dbo.refRequirementText rrt(NOLOCK)
			ON c.CLNO = rrt.CLNO
			LEFT OUTER JOIN
			dbo.refStatewide sw(NOLOCK) 
			ON rrt.StatewideID = sw.StateWideID
			left join 
			PackageMain d with(nolock)
			on(a.PackageID = d.PackageID)
			left join 
			refStateCrimNotes sc with(nolock)
			on(c.StateCrimNotesID= sc.StateCrimNotesID)
		where sw.[Description] is not null
		AND  A.ApDate >= @StartDate  
		AND  A.ApDate <= @EndDate
		AND  C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
		AND  C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) 
		Union 
		Select a.APNO as [Report #],
		       b.AppStatusValue as [Report Status],
			   c.CLNO,
			   c.Name as [Client Name],
			   a.First as [Applicant First],
			   a.Last as [Applicant Last],
			   a.Investigator as [AI Investigator],
			   sw.[Description] AS [Statewide],
			   PackageDesc, 
			   case when sc.StateCrimNotes is not null then 'True' else 'False' end as  [Has Statewide Crim]--,sc.StateCrimNotes
		from APPL  a with (nolock)
			inner join 
			AppStatusDetail b with(nolock)
			on(a.ApStatus=b.AppStatusItem)
			inner join 
			Client c with(nolock)
			on(a.CLNO=c.CLNO)
			INNER JOIN
			dbo.refRequirementText rrt(NOLOCK)
			ON c.CLNO = rrt.CLNO
			LEFT OUTER JOIN
			dbo.refStatewide sw(NOLOCK) 
			ON rrt.StatewideID = sw.StateWideID
			left join 
			PackageMain d with(nolock)
			on(a.PackageID = d.PackageID)
			left join 
			refStateCrimNotes sc with(nolock)
			on(c.StateCrimNotesID= sc.StateCrimNotesID)
		where sc.StateCrimNotesID is null
		and   A.ApDate >= @StartDate  
		AND   A.ApDate <= @EndDate
		AND   C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
		AND   C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) 
		
		*/

	

END
