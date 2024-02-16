-- Alter Procedure Win_Service_AutoOrdering_20131024

/********************************************************************************************************************/
-- [Win_Service_AutoOrdering] '10/16/2013'
-- =============================================
-- Author:		Najma,Begum
-- Create date: 05/24/2012
-- Description:	Get county, empl etc automation data
-- =============================================
-- Updated By:		Najma,Begum
-- Update date:8/3/2012
-- Description:	Updated the Logic while pulling past convections
-- =============================================
-- Updated By:		Najma,Begum
-- Update date:3/2013
-- Description:	Updated the Logic to get what clients qualify for autoordering
--				and removed the need to check whether stucheck or not.
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AutoOrdering_20131024]

	-- Add the parameters for the stored procedure here
@Date datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- use below statements to Stop Auto County ordering
--*************************************************************************
--update dbo.Appl
--
--set Appl.NeedsReview = 'S2',InUse = NULL
-- WHERE Appl.NeedsReview like '%3' and dbo.Appl.InUse ='CNTY_S' and dbo.Appl.EnteredVia='StuWeb';
--*************************************************************************

	DECLARE @TblApno AS Table( [id] INT, ssn varchar(11) );


	INSERT INTO @TblApno([id], ssn)
	--SELECT Apno, ssn FROM dbo.Appl with(nolock) WHERE Appl.NeedsReview in('W3','X3','S3','R3') --and dbo.Appl.InUse is NULL;
	SELECT Apno, ssn FROM dbo.Appl with(nolock) WHERE Appl.NeedsReview like '%2' and dbo.Appl.InUse ='CNTY_S' --and dbo.Appl.EnteredVia='StuWeb';


	--CR	
	--SELECT a.ssn,a.apno,a.city,a.[state],a.zip as zipcode,a.enteredvia FROM dbo.Appl a with(nolock) inner join @TblApno n on a.apno = n.id;
	SELECT a.ssn,a.apno,a.city,a.[state],a.zip as zipcode,a.enteredvia, a.clno,IsNULL(c.value, 'False') as autoorder FROM dbo.Appl a with(nolock) inner join @TblApno n on a.apno = n.id left join clientconfiguration c on a.clno = c.clno and c.configurationkey='AutoOrder';
	

--Client
	select a.apno,a.clno,A_County, c.State,IsNull(c.IsStatewide,0) as IsStateWide,
s.CNTY_NO,rs.description as 'clientrule'
		
from Appl a with(nolock) inner join refRequirementText  r with(nolock) on a.clno = r.clno
left join StateWideCountyRules s with(nolock) on r.statewideID = s.statewideID
inner join dbo.TblCounties  c with(nolock) on c.CNTY_NO = s.CNTY_NO
inner join refStatewideRules rs with(nolock) on s.StatewideRulesID = rs.StatewideRulesID
 inner join @TblApno n on a.apno = n.id;
 
 --ClientPref
 select a.apno,a.clno,a.Packageid, p.IncludedCount
from appl a inner join PackageService p on a.Packageid = p.packageid and p.ServiceType = 0
 inner join @TblApno n on a.apno = n.id
where a.Packageid >0
and p.ServiceType = 0
	
	--Empl
	select apno, city,[state], zipcode, To_A, emplid from dbo.empl e with(nolock) inner join @TblApno a on e.apno = a.id;
	--Edu
	select apno, city,[state], zipcode, To_A, educatid from dbo.educat e with(nolock) inner join @TblApno a on e.apno = a.id;
	
	--PID
	 Select pid.ssn, pid.aliases,pid.counties,t.apno, pid.ResponseID from [dbo].[positiveidresponselog] pid with(nolock)   
		     INNER JOIN (SELECT pid.ssn, max(pid.searchdate)as sd, a.id as apno FROM [dbo].[positiveidresponselog] pid  inner join @TblApno a on REPLACE(pid.ssn, '-', '')  = REPLACE(a.ssn, '-', '') and pid.searchdate >= DateAdd(mm,-1,@Date)  --@Date
group by pid.ssn,a.id) t on pid.ssn = t.ssn and pid.SearchDate = t.sd

	--IsSelfDisclosed
	--SELECT TOP 1 ad.Apno, ISNULL(ad.Crim_SelfDisclosed, 0) Crim_SelfDisclosed
	--FROM   dbo.ApplAdditionalData ad with(nolock) inner join @TblApno a on ad.ssn = a.ssn 
	--WHERE  DateDiff(YY,ad.DateCreated,current_timestamp)<=10 
	--ORDER BY ad.DateCreated Desc;

	/*NOTE-NB:03/18/2013:-Changed to below stmt because the above always returns Top 1 which is not
	--correct; each apno if has self disclosure must return its data not just top 1 which means only one
	--apno which ever it is based on datecreated in desc order will be returned and not the rest of the qualified ones*/

	SELECT ad.Apno, ISNULL(ad.Crim_SelfDisclosed, 0) Crim_SelfDisclosed
	FROM   dbo.ApplAdditionalData ad with(nolock) inner join @TblApno a on ad.ssn = a.ssn 
	WHERE  DateDiff(YY,ad.DateCreated,current_timestamp)<=10 
	ORDER BY ad.DateCreated Desc;

	--Self disclosed
		SELECT Distinct ac.Apno, ac.City , ac.State,ac.Country,ac.CrimDate, ac.applicantcrimid
		FROM   dbo.ApplicantCrim ac with(nolock) where ac.Apno in (Select [id] from @TblApno) OR ac.SSN in (Select ssn from @TblApno);
				
		
	--Past Convictions
	
	DECLARE @TblPastConvictions AS Table( Apno INT, County varchar(50),CNTY_NO INT,CrimID INT, CaseNo varchar(50),Offense varchar(1000),Disp_Date DateTime,Disposition varchar(500) );

	INSERT INTO @TblPastConvictions
	SELECT C.Apno as Apno,C.County, C.CNTY_NO,  C.CrimID, C.CaseNo,C.Offense,C.Disp_Date,C.Disposition 
    FROM   dbo.Appl A with(nolock) 
	inner join dbo.Crim C with(nolock) ON A.APNO = C.APNO 
	inner join @TblApno ap on A.SSN= ap.SSN
	where     C.[Clear]   = 'F' AND    C.IsHidden = 0 AND len(A.SSN) > 0 ;

	--This will only return distinct hits (all) from the latest background check performed (when the same hit is reported historically) for that individual
	Select Distinct Apno,County,CNTY_NO,CrimID 
	From @TblPastConvictions 
	where crimid in(
	     --Only include the latest hit where the caseno matches
		 select max(crimid) from @TblPastConvictions group by CaseNo
		 union all
		 --Only include the latest hit where the CNTY_NO,Offense,Disp_Date,Disposition matches
		 select max(crimid) from @TblPastConvictions group by Offense,Disp_Date,Disposition
		 ) 
		
	-- License
	SELECT lic.Apno, count(1)RecordCount FROM   dbo.ProfLic lic with(nolock) inner join @TblApno a on lic.Apno = a.[id] group by lic.Apno;
	
	--DL
	SELECT dl.Apno, count(1) RecordCount FROM   dbo.DL dl with(nolock) inner join @TblApno a on dl.Apno = a.[id] group by dl.Apno;

	-- Previous addresses
	SELECT Distinct adr.Apno, adr.City, adr.State, adr.Zip as zipcode, adr.DateStart, adr.DateEnd, adr.appladdressid
		FROM   dbo.ApplAddress adr with(nolock) where adr.Apno in(Select [id] from @TblApno) OR adr.SSN in (Select ssn from @TblApno);

--	--Aliases
--	SELECT apno,alias1_first, alias1_middle, alias1_last,alias2_first, alias2_middle, alias2_last,alias3_first, alias3_middle, alias3_last, alias4_first, alias4_middle, alias4_last FROM appl with(nolock) inner join @TblApno a on appl.Apno = a.[id]
--	
--Aliases

      SELECT apno,[first] as alias0_first,middle as alias0_middle,[last] as alias0_last,alias1_first, alias1_middle, alias1_last,alias2_first, alias2_middle, alias2_last,alias3_first, alias3_middle, alias3_last, alias4_first, alias4_middle, alias4_last FROM appl with(nolock) inner join @TblApno a on appl.Apno = a.[id]

END
