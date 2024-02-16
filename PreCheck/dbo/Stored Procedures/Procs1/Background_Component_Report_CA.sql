
-- =========================================================================================
-- Author:		Prasanna
-- Create date: 10/04/2016
-- Description:	WellStar (Renamed to Client) Background Report 
--Modified By: schapyala
--Modified On: 02/16/2017
--Modification: Renamed the SP to [Background_Component_Report] as there is nothing wellstar specific. Added Section with All as default
-- Exec [dbo].[Background_Component_Report] '13055','All',0,'03/01/2020','06/25/2020'
-- Modified By: Radhika Dereddy on 07/25/2017
--Description : insert a column titled Release Signed Date and Certification Received Date 
-- Modified By: Prasanna on 06/22/2020
--Description : HDT#74099 Add ability to search by AffiliateID and by date
--Modified by Radhika Dereddy on 07/14/2021 to add sub status
-- =========================================================================================
CREATE PROCEDURE [dbo].[Background_Component_Report_CA] 
	
	@CLNO int,
	@Section VARCHAR(20)='All', 
	@AffiliateID int,
	@StartDate DATE, 
	@EndDate DATE
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--IF @StartDate IS NULL
	--	BEGIN
	--		SET @StartDate = CAST(DATEADD(day,-7, GETDATE()) AS Date)
	--		SET @EndDate = CAST(GETDATE() AS Date)
	--	END

	IF @Section = 'Reference Report' -- Used by Personal Reference Report (QReport)
	  SELECT [Client ID],[AffiliateID] [Affiliate ID],[Report Number],[Release Signed Date], [Certification Received Date], [Report Status],Recruiter,[Last Name], [First Name], [Original Complete Date],[Reopen Date],[Complete Date],
			Section,sectstat [Section Status], SectSubStatus [Section SubStatus], [Criminal Degree], ReferenceName,Email RefererenceEmail,Phone ReferencePhone, PublicNotes [Public Notes] FROM
	  (
		 select a.clno as 'Client ID'
		 , c.AffiliateID
		 , a.apno as [Report Number]
		 , FORMAT(r.Date,   'MM/dd/yyyy hh:mm tt') as [Release Signed Date]
		 , FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') as [Certification Received Date]
		 , ApStatus as [Report Status]
		 , a.attn   as Recruiter
		 , a.last   as [Last Name]
		 , a.first  as [First Name]
		 , FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date'
		 , FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'
		 , FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'
		 , 'Personal Reference' as Section
		 , sectstat
		 , isnull(sss.SectSubStatus,'') as SectSubStatus
		 ,  ' ' as  [Criminal Degree]
		 , e.Name as ReferenceName 
		 , e.Email
		 , e.Phone  
		 , Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
		 from appl a 
			 inner join client c on c.clno = a.CLNO
			 inner join  dbo.persref e on a.apno = e.apno 
			 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
			 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
			 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
		 where e.isonreport = 1 
			 and e.ishidden = 0 
			 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
			 AND a.ApStatus = 'F' 
			 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
			 AND A.ApDate >= @StartDate AND A.ApDate < DATEADD(day, 1, @EndDate)

		UNION ALL

		 select a.clno as 'Client ID'
		 , c.AffiliateID
		 , a.apno as [Report Number]
		 , FORMAT(r.Date,   'MM/dd/yyyy hh:mm tt') as [Release Signed Date]
		 , FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') as [Certification Received Date]
		 , ApStatus as [Report Status]
		 , a.attn   as Recruiter
		 , a.last   as [Last Name]
		 , a.first  as [First Name]
		 , FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date'
		 , FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'
		 , FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'
		 ,'Personal Reference' as Section
		 , sectstat
		 , isnull(sss.SectSubStatus,'') as SectSubStatus
		 , ' ' as  [Criminal Degree]
		 , e.Name as ReferenceName
		 , e.Email
		 , e.Phone
		 , Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
		 from appl a 
		 inner join client c on c.clno = a.CLNO
		 inner join dbo.persref e on a.apno = e.apno 
		 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
		 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
		 where e.isonreport = 1 
		  and e.ishidden = 0 
		  and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
		  AND a.ApStatus = 'P'
		  AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID)
		  AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
	  )y  
	ELSE
  	 select [Client ID],AffiliateID [Affiliate ID],[Report Number], [Release Signed Date], [Certification Received Date], [Report Status], Recruiter, [Last Name], [First Name],[Original Complete Date],[Reopen Date],
	  [Complete Date],Section, ISNULL(s.Description,SectStat) [Section Status],SectSubStatus [Section SubStatus], [Criminal Degree],  PublicNotes  [Public Notes]  from
	 (
			SELECT [Client ID],AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date],
			 [Complete Date],Section,sectstat,SectSubStatus,  [Criminal Degree], PublicNotes FROM
			(
				select a.clno as [Client ID], c.AffiliateID, a.apno as [Report Number]
				,FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date]
				,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				apStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date',
				'Employment' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus,
				 ' ' as  [Criminal Degree],
				Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
 				from appl a 
				inner join client c on c.clno = a.CLNO
				inner join  dbo.empl e on a.apno = e.apno 
				inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 and a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

					UNION ALL

				select a.clno as [Client ID], c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				apStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date',
				 'Employment' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus,
				  ' ' as  [Criminal Degree],
				  Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				from appl a 
				inner join client c on c.clno = a.CLNO
				inner join  dbo.empl e on a.apno = e.apno
				inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				where e.isonreport = 1 
				and e.ishidden = 0 
				and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				and a.ApStatus = 'P'
				AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
			) Y 
			WHERE @Section IN ('All','Employment')
	
		 UNION ALL 

		   SELECT [Client ID], AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date], [Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubStatus, [Criminal Degree], PublicNotes FROM
			(
				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number], FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',				 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Education' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, 
				  ' ' as  [Criminal Degree],
				 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.educat e on a.apno = e.apno 
				  inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn	 
				  Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				  Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				 AND a.ApStatus = 'F'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number], FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date',
				 'Education' as Section,sectstat, isnull(sss.SectSubStatus,'') as SectSubStatus,
				  ' ' as  [Criminal Degree],
				 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.educat e on a.apno = e.apno 
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				 and a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
		   ) Y 
		   WHERE @Section IN ('All','Education')

		 UNION ALL 

			SELECT [Client ID],AffiliateID, [Report Number], [Release Signed Date], [Certification Received Date], [Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat, SectSubStatus, [Criminal Degree],  PublicNotes FROM
			(
				 select a.clno as 'Client ID', c.AffiliateID, a.apno as [Report Number], FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				 ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',				 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','License' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, 
				  ' ' as  [Criminal Degree],
				 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.proflic e on a.apno = e.apno 
				 inner join  dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
		  		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID', c.AffiliateID, a.apno as [Report Number], FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',				 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','License' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, 
				  ' ' as  [Criminal Degree],
				 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.proflic e on a.apno = e.apno
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
		  		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'p'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
			) y
			WHERE @Section IN ('All','License')

		 UNION ALL 

			SELECT [Client ID], AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubstatus, [Criminal Degree], PublicNotes FROM
			(
				 select a.clno as 'Client ID', c.AffiliateID, a.apno as [Report Number], FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',				 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Criminal' as Section,css.crimdescription sectstat, '' SectSubStatus,
				 CASE 
					  WHEN e.Degree = '1' THEN 'Petty Misdemeanor'
					  WHEN e.Degree = '2' THEN 'Traffic Misdemeanor'
					  WHEN e.Degree = '3' THEN 'Criminal Traffic'
					  WHEN e.Degree = '4' THEN 'Traffic'
					  WHEN e.Degree = '5' THEN 'Ordinance Violation'
					  WHEN e.Degree = '6' THEN 'Infraction'
					  WHEN e.Degree = '7' THEN 'Disorderly Persons'
					  WHEN e.Degree = '8' THEN 'Summary Offense'
					  WHEN e.Degree = '9' THEN 'Indictable Crime'
					  WHEN e.Degree = 'F' THEN 'Felony'
					  WHEN e.Degree = 'M' THEN 'Misdemeanor'
					  WHEN e.Degree = 'O' THEN 'Other'
					  WHEN e.Degree = 'U' THEN 'Unknown'
				     END as [Criminal Degree],
				  Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.crim e on a.apno = e.apno 
				 inner join crimsectstat css on css.crimsect = e.[Clear]
				  inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
		  		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',				 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Criminal' as Section,css.crimdescription sectstat,''SectSubStatus,
				 CASE 
					  WHEN e.Degree = '1' THEN 'Petty Misdemeanor'
					  WHEN e.Degree = '2' THEN 'Traffic Misdemeanor'
					  WHEN e.Degree = '3' THEN 'Criminal Traffic'
					  WHEN e.Degree = '4' THEN 'Traffic'
					  WHEN e.Degree = '5' THEN 'Ordinance Violation'
					  WHEN e.Degree = '6' THEN 'Infraction'
					  WHEN e.Degree = '7' THEN 'Disorderly Persons'
					  WHEN e.Degree = '8' THEN 'Summary Offense'
					  WHEN e.Degree = '9' THEN 'Indictable Crime'
					  WHEN e.Degree = 'F' THEN 'Felony'
					  WHEN e.Degree = 'M' THEN 'Misdemeanor'
					  WHEN e.Degree = 'O' THEN 'Other'
					  WHEN e.Degree = 'U' THEN 'Unknown'
				     END as [Criminal Degree],
				  Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.crim e on a.apno = e.apno 
				 inner join crimsectstat css on css.crimsect = e.[Clear]
				  inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
    	  		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
			) y 
			WHERE @Section IN ('All','Criminal')

		 UNION ALL 

			SELECT [Client ID],AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubStatus, [Criminal Degree],  PublicNotes FROM
			(
				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date], 
				 ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Personal Reference' as Section,sectstat, isnull(sss.SectSubStatus,'') as SectSubStatus, 
				 ' ' as  [Criminal Degree],
				 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.persref e on a.apno = e.apno 
				  inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',			 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Personal Reference' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, 
				  ' ' as  [Criminal Degree],
				 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
		 		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 inner join  dbo.persref e on a.apno = e.apno 
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

			)y 
			WHERE @Section IN ('All','Reference')


	 UNION ALL 

			SELECT [Client ID],AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubStatus, [Criminal Degree],  PublicNotes FROM
			(
				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date], 
				 ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','PID' as Section,sectstat, ' ' as SectSubStatus, 
				 ' ' as  [Criminal Degree],
				  ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.Credit AS e WITH (NOLOCK) ON e.Apno = a.apno and e.RepType = 'S'
			     inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',			 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','PID' as Section,sectstat,' ' as SectSubStatus,
				  ' ' as  [Criminal Degree],
				 ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
		 		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				  inner join  dbo.Credit AS e WITH (NOLOCK) ON e.Apno = a.apno and e.RepType = 'S'
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				-- Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

			)y 
			WHERE @Section IN ('All','PID')

	 UNION ALL 

			SELECT [Client ID],AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubStatus, [Criminal Degree],  PublicNotes FROM
			(
				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date], 
				 ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Sanction' as Section,sectstat, ' ' as SectSubStatus, 
				 ' ' as  [Criminal Degree],
				  ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.MedInteg AS e WITH (NOLOCK) ON e.Apno = a.apno
			     inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',			 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Sanction' as Section,sectstat,' ' as SectSubStatus,
				  ' ' as  [Criminal Degree],
				 ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
		 		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				  inner join dbo.MedInteg AS e WITH (NOLOCK) ON e.Apno = a.apno 
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				-- Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

			)y 
			WHERE @Section IN ('All','Sanction')

	 UNION ALL 

			SELECT [Client ID],AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubStatus, [Criminal Degree],  PublicNotes FROM
			(
				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date], 
				 ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','MVR' as Section,sectstat, ' ' as SectSubStatus, 
				 ' ' as  [Criminal Degree],
				  ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.DL AS e WITH (NOLOCK) ON e.Apno = a.apno
			     inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',			 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','MVR' as Section,sectstat,' ' as SectSubStatus,
				  ' ' as  [Criminal Degree],
				 ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
		 		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				 inner join dbo.DL AS e WITH (NOLOCK) ON e.Apno = a.apno 
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				-- Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

			)y 
			WHERE @Section IN ('All','MVR')
	 UNION ALL 

			SELECT [Client ID],AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],[Report Status],Recruiter,[Last Name], [First Name],[Original Complete Date],[Reopen Date], [Complete Date],Section,sectstat,SectSubStatus, [Criminal Degree],  PublicNotes FROM
			(
				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date], 
				 ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Credit' as Section,sectstat, ' ' as SectSubStatus, 
				 ' ' as  [Criminal Degree],
				  ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
				 inner join  dbo.Credit AS e WITH (NOLOCK) ON e.Apno = a.apno and e.RepType = 'C'
			     inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno as 'Client ID',c.AffiliateID, a.apno as [Report Number],FORMAT(r.Date, 'MM/dd/yyyy hh:mm tt') as [Release Signed Date],FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as [Certification Received Date],
				  ApStatus as [Report Status],a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Complete Date',
				 FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date',			 
				 FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date','Credit' as Section,sectstat,' ' as SectSubStatus,
				  ' ' as  [Criminal Degree],
				 ' ' as PublicNotes
				 from appl a 
				 inner join client c on c.clno = a.CLNO
		 		 Inner Join refAffiliate rf on c.Affiliateid = rf.Affiliateid
				  inner join  dbo.Credit AS e WITH (NOLOCK) ON e.Apno = a.apno and e.RepType = 'C'
				 inner join dbo.ReleaseForm r on a.clno = r.clno and a.ssn=r.ssn
				-- Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				 AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

			)y 
			WHERE @Section IN ('All','Credit')
	 ) Z 
	 LEFT JOIN dbo.SectStat S ON Z.SectStat = S.Code
	 ORDER by [Report Number]


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
	  
END
