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
/* Modified By: Vairavan A
-- Modified Date: 07/01/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*
EXEC Background_Component_Report '13055','All','0','03/01/2020','06/25/2020'
EXEC Background_Component_Report '13055','All','4','03/01/2020','06/25/2020'
EXEC Background_Component_Report '13055','All','4:8','03/01/2020','06/25/2020'
*/
-- =========================================================================================
CREATE PROCEDURE [dbo].[Background_Component_Report] 
	
	@CLNO int,
	@Section VARCHAR(20)='All', 
	--@AffiliateID int,--code commented by vairavan for ticket id -53763
    @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763
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

	
	--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

	IF @Section = 'Reference Report' -- Used by Personal Reference Report (QReport)
	  SELECT CLNO,[AffiliateID],[Report Number],[Release Signed Date], [Certification Received Date], ReportStatus,Recruiter,[Last Name], [First Name], CompDate,
			Section,sectstat, SectSubStatus, ReferenceName,Email RefererenceEmail,Phone ReferencePhone, PublicNotes FROM
	  (
		 select a.clno, c.AffiliateID, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], ApStatus as ReportStatus,
		 a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
		 a.CompDate,'Personal Reference' as Section,sectstat,  isnull(sss.SectSubStatus,'') as SectSubStatus,e.Name as ReferenceName , e.Email,e.Phone , 
		 Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
		 from appl a  with(nolock)
		 inner join client c  with(nolock) on c.clno = a.CLNO
		 inner join  dbo.persref e  with(nolock) on a.apno = e.apno 
		 inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
		 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
		 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
		 where e.isonreport = 1 
		 and e.ishidden = 0 
		 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
		 AND a.ApStatus = 'F' 
		 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
		 AND A.ApDate >= @StartDate AND A.ApDate < DATEADD(day, 1, @EndDate)

			UNION ALL

		 select a.clno, c.AffiliateID, a.apno as [Report Number],  r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
		  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
		 a.CompDate,'Personal Reference' as Section, sectstat, isnull(sss.SectSubStatus,'') as SectSubStatus, e.Name as ReferenceName, e.Email,e.Phone,
		  Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
		 from appl a   with(nolock)
		 inner join client c  with(nolock) on c.clno = a.CLNO
		 inner join dbo.persref e with(nolock)  on a.apno = e.apno 
		 inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
		 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
		 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
		 where e.isonreport = 1 
		  and e.ishidden = 0 
		  and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
		  AND a.ApStatus = 'P'
		   --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
		  AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
	  )y  
	ELSE
  	 select CLNO,AffiliateID,[Report Number], [Release Signed Date], [Certification Received Date], ReportStatus, Recruiter, [Last Name], [First Name],
	  CompDate,Section, ISNULL(s.Description,SectStat) SectionStatus,SectSubStatus, PublicNotes from
	 (
			SELECT CLNO,AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],ReportStatus,Recruiter,[Last Name], [First Name],
			 CompDate,Section,sectstat,SectSubStatus, PublicNotes FROM
			(
				select a.clno as CLNO, c.AffiliateID, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				apStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				a.CompDate,'Employment' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus,
				Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
 				from appl a   with(nolock)
				inner join client c  with(nolock) on c.clno = a.CLNO
				inner join  dbo.empl e   with(nolock) on a.apno = e.apno 
				inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
				inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				Left join dbo.SectSubStatus sss with (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 and a.ApStatus = 'F' 
				 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

					UNION ALL

				select a.clno as CLNO, c.AffiliateID, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				apStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Employment' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				from appl a   with(nolock)
				inner join client c  with(nolock) on c.clno = a.CLNO
				inner join  dbo.empl e   with(nolock)on a.apno = e.apno
				inner join dbo.ReleaseForm r with(nolock) on a.clno = r.clno and a.ssn=r.ssn
				Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				Left join dbo.SectSubStatus sss with (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				where e.isonreport = 1 
				and e.ishidden = 0 
				and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				and a.ApStatus = 'P'
		 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
				AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
			) Y 
			WHERE @Section IN ('All','Employment')
	
		 UNION ALL 

		   SELECT CLNO, AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date], ReportStatus,Recruiter,[Last Name], [First Name], CompDate,Section,sectstat,SectSubStatus,PublicNotes FROM
			(
				 select a.clno,c.AffiliateID, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Education' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a   with(nolock)
				 inner join client c  with(nolock) on c.clno = a.CLNO
				 inner join  dbo.educat e  with(nolock) on a.apno = e.apno 
				  inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn	 
				  Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				  Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				 AND a.ApStatus = 'F'
				 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno,c.AffiliateID, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Education' as Section,sectstat, isnull(sss.SectSubStatus,'') as SectSubStatus,Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a  with(nolock)
				 inner join client c  with(nolock) on c.clno = a.CLNO
				 inner join  dbo.educat e  with(nolock) on a.apno = e.apno 
				 inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				 and a.ApStatus = 'P'
				 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
		   ) Y 
		   WHERE @Section IN ('All','Education')

		 UNION ALL 

			SELECT CLNO,AffiliateID, [Report Number], [Release Signed Date], [Certification Received Date], ReportStatus,Recruiter,[Last Name], [First Name], CompDate,Section,sectstat, SectSubStatus, PublicNotes FROM
			(
				 select a.clno, c.AffiliateID, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				 ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'License' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a  with(nolock)
				 inner join client c  with(nolock) on c.clno = a.CLNO
				 inner join  dbo.proflic e  with(nolock) on a.apno = e.apno 
				  inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
		  		 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
		 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno, c.AffiliateID, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'License' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a  with(nolock)  
				 inner join client c with(nolock)  on c.clno = a.CLNO
				 inner join  dbo.proflic e with(nolock)  on a.apno = e.apno
				  inner join dbo.ReleaseForm r with(nolock)  on a.clno = r.clno and a.ssn=r.ssn
		  		 Inner Join refAffiliate rf with(nolock)  on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'p'
			 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
			) y
			WHERE @Section IN ('All','License')

		 UNION ALL 

			SELECT CLNO, AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],ReportStatus,Recruiter,[Last Name], [First Name], CompDate,Section,sectstat,SectSubstatus,PublicNotes FROM
			(
				 select a.clno, c.AffiliateID, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Criminal' as Section,css.crimdescription sectstat, '' SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes 
				 from appl a  with(nolock) 
				 inner join client c  with(nolock) on c.clno = a.CLNO
				 inner join  dbo.crim e  with(nolock) on a.apno = e.apno 
				 inner join crimsectstat css  with(nolock) on css.crimsect = e.[Clear]
				  inner join dbo.ReleaseForm r with(nolock)  on a.clno = r.clno and a.ssn=r.ssn
		  		 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO) 
				 AND a.ApStatus = 'F' 
		 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno,c.AffiliateID, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Criminal' as Section,css.crimdescription sectstat,''SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a  with(nolock) 
				 inner join client c  with(nolock) on c.clno = a.CLNO
				 inner join  dbo.crim e with(nolock)  on a.apno = e.apno 
				 inner join crimsectstat css with(nolock)  on css.crimsect = e.[Clear]
				  inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
    	  		 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				 where e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
			 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))
			) y 
			WHERE @Section IN ('All','Criminal')

		 UNION ALL 

			SELECT CLNO,AffiliateID,[Report Number],[Release Signed Date], [Certification Received Date],ReportStatus,Recruiter,[Last Name], [First Name], CompDate,Section,sectstat,SectSubStatus, PublicNotes FROM
			(
				 select a.clno,c.AffiliateID, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], 
				 ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Personal Reference' as Section,sectstat, isnull(sss.SectSubStatus,'') as SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a  with(nolock) 
				 inner join client c  with(nolock) on c.clno = a.CLNO
				 inner join  dbo.persref e  with(nolock) on a.apno = e.apno 
				  inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
				 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'F' 
				 --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763 
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

				 UNION ALL

				 select a.clno,c.AffiliateID, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date],
				  ApStatus as ReportStatus,a.attn as Recruiter,a.last as [Last Name],a.first as [First Name],
				 a.CompDate,'Personal Reference' as Section,sectstat,isnull(sss.SectSubStatus,'') as SectSubStatus, Replace(REPLACE(e.pub_notes , char(10),';'),char(13),';')as PublicNotes
				 from appl a  with(nolock) 
				 inner join client c  with(nolock) on c.clno = a.CLNO
		 		 Inner Join refAffiliate rf  with(nolock) on c.Affiliateid = rf.Affiliateid
				 inner join  dbo.persref e  with(nolock) on a.apno = e.apno 
				 inner join dbo.ReleaseForm r  with(nolock) on a.clno = r.clno and a.ssn=r.ssn
				 Left join dbo.SectSubStatus sss with(nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
				 where e.isonreport = 1 
				 and e.ishidden = 0 
				 and c.clno = IIF(@CLNO=0, C.CLNO, @CLNO)
				 AND a.ApStatus = 'P'
				  --AND C.AffiliateID = IIF(@AffiliateID = 0,C.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
				 AND (A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate))

			)y 
			WHERE @Section IN ('All','Reference')
	 ) Z 
	 LEFT JOIN dbo.SectStat S ON Z.SectStat = S.Code
	 ORDER by [Report Number]


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
	  
END
