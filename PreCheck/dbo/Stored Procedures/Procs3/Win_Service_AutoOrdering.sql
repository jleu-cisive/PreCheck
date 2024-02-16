-- Stored Procedure

-- Alter Procedure Win_Service_AutoOrdering

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
-- Updated By: Deepak Vodethela	
-- Update date: 11/30/2016
-- Description:	Added Age and DOB to be retreived for the AutoOrder process. And also, if Age is 18 the AutoOrder = false condition has been added.
-- =============================================
-- Updated By: Larry Ouch
-- Update date: 07/20/2018
-- Description:	Added a configuration for the minimum AutoOrder age.  Also sorted the SelfDisclose data by createdate.
-- =============================================
-- Updated By: Yves
-- Update date: 06/19/2019
-- Description:	add datasets for past employment and education with prehceck
-- =============================================
-- Updated By: Karan Send
-- Update date: 12/08/2022
-- Description:	A modification is done to call procedure ApplyJobRequirementBySectionNew
-- =============================================
-- Updated By: Tanay Dubey
-- Update date: 02/20/2023
-- Description:	Added a condition to check if first/last name is invalid for an applicant and if so 
--				insert it in SP [ApplCountiesExceptionLog] as an exception to stop it from Auto Ordering
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AutoOrdering]

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

	---Setting up Job Requirements Here for clients
	Exec [dbo].[ApplyJobRequirementBySection]

	DECLARE @TblApno AS Table( [id] INT, ssn varchar(11) );	
	 DECLARE @TblExcludeApno AS Table(apno INT, first varchar(5000),last varchar(5000));


	INSERT INTO @TblApno([id], ssn)
	--SELECT Apno, ssn FROM dbo.Appl with(nolock) WHERE Appl.NeedsReview in('W3','X3','S3','R3') --and dbo.Appl.InUse is NULL;
	SELECT Apno, ssn FROM dbo.Appl with(nolock) WHERE Appl.NeedsReview like '%2' and dbo.Appl.InUse ='CNTY_S' --and dbo.Appl.EnteredVia='StuWeb';

    INSERT into  @TblExcludeAPno
    SELECT 
		a.apno
		,a.first
		,a.last 
	from  @TblApno tb inner join appl a with(nolock)  on a.apno=tb.id 
	left join ApplCountiesExceptionLog acel on a.apno=acel.apno and acel.sourceid = (SELECT sourceid from BRSources where source='Applicant') and acel.ruleid=(SELECT ruleid from BRAutoOrderRules where description ='Invalid first and/or last name' and ruletypeid=1)
    WHERE 
		((len(a.first)=1 or len(a.last)=1) --Rule #1
		OR
		((isnull(a.first,'') = '') or (isnull(a.last,'') = '')) --Rule #2
		OR
		(a.first  like '%[0-9]%' or a.last  like '%[0-9]%' )) --Rule #3
		AND
		acel.apno is null --to stop it from adding duplicate exceptions 
	
    INSERT into ApplCountiesExceptionLog (apno,sourceid,ruleid,logdate)
    SELECT 
		tbl.apno
		,(SELECT sourceid from BRSources where source='Applicant')
		,(SELECT ruleid from BRAutoOrderRules where description ='Invalid first and/or last name' and ruletypeid=1)
		,getdate() 
	FROM @TblExcludeAPno tbl 

	DELETE tb from @TblApno tb inner join @TblExcludeAPno tbl on tb.id=tbl.apno
	
	DECLARE @MinAutoOrderAge AS INT;

	SET @MinAutoOrderAge = (SELECT CAST(Value AS INT) FROM ClientConfiguration WHERE ConfigurationKey = 'AutoOrder_MinimumAge');
	--select * from @TblApno

	--CR	
	--SELECT a.ssn,a.apno,a.city,a.[state],a.zip as zipcode,a.enteredvia FROM dbo.Appl a with(nolock) inner join @TblApno n on a.apno = n.id;
	SELECT a.ssn,a.apno,A.DOB,ISNULL(CONVERT(int,DATEDIFF(d, A.DOB, CURRENT_TIMESTAMP)/365.25),0) AS AGE,a.city,a.[state],a.zip as zipcode,a.enteredvia, a.clno,
			@MinAutoOrderAge AS MinAutoOrderAge,
			--IsNULL(c.value, 'False') as autoorder 
			-- The below item will take care of the apps which do not have DOB and should not qulify for Autoorder.
			CASE WHEN A.DOB is null THEN 'False' 
				 WHEN CONVERT(int,DATEDIFF(d, A.DOB, CURRENT_TIMESTAMP)/365.25) < @MinAutoOrderAge THEN 'False'
				 ELSE IsNULL(c.value, 'False') END as autoorder			

	FROM dbo.Appl a with(nolock) 
	inner join @TblApno n on a.apno = n.id 
	left join clientconfiguration c on a.clno = c.clno and c.configurationkey='AutoOrder';


	--Client
	select a.apno,a.clno,A_County, c.State,IsNull(c.IsStatewide,0) as IsStateWide,
			s.CNTY_NO,rs.description as 'clientrule'
	from Appl a with(nolock) 
	inner join refRequirementText  r with(nolock) on a.clno = r.clno
	left join StateWideCountyRules s with(nolock) on r.statewideID = s.statewideID
	inner join dbo.Counties  c with(nolock) on c.CNTY_NO = s.CNTY_NO
	inner join refStatewideRules rs with(nolock) on s.StatewideRulesID = rs.StatewideRulesID
	inner join @TblApno n on a.apno = n.id;

	 --ClientPref
	-- select a.apno,a.clno,a.Packageid, p.IncludedCount
	--from appl a inner join PackageService p on a.Packageid = p.packageid and p.ServiceType = 0
	-- inner join @TblApno n on a.apno = n.id
	--where a.Packageid >0
	--and p.ServiceType = 0
	DECLARE @DefaultMaxCount INT

	--get Max allowed count before switching to manual ordering from Auto Ordering --> Exception processing
	SELECT @DefaultMaxCount = Value 
	FROM [precheck].[dbo].[BRAutoOrderRules]
	WHERE RuleID = 6

	select a.apno,a.clno,a.Packageid, 
	Case when NumOfRecord = -1 then @DefaultMaxCount else NumOfRecord end IncludedCount
	from dbo.appl a (nolock) inner join dbo.refRequirement p (nolock) on a.clno = p.CLNO and p.RecordType = 'crim'
	inner join @TblApno n on a.apno = n.id


	--Empl
	select apno, city,[state], zipcode, To_A, emplid from dbo.empl e with(nolock) inner join @TblApno a on e.apno = a.id;
	--Edu
	select apno, city,[state], zipcode, To_A, educatid from dbo.educat e with(nolock) inner join @TblApno a on e.apno = a.id;

	--PID
	 Select pid.ssn, pid.aliases,pid.counties,t.apno, pid.ResponseID 
	 from [dbo].[positiveidresponselog] pid with(nolock)   
	 INNER JOIN (SELECT pid.ssn, max(pid.searchdate)as sd, a.id as apno 
				 FROM [dbo].[positiveidresponselog] pid with(nolock) 
				 inner join @TblApno a on REPLACE(pid.ssn, '-', '')  = REPLACE(a.ssn, '-', '') and pid.searchdate >= DateAdd(mm,-1,@Date)  --@Date
				 group by pid.ssn,a.id) t on pid.ssn = t.ssn and pid.SearchDate = t.sd

	--IsSelfDisclosed
	--SELECT TOP 1 ad.Apno, ISNULL(ad.Crim_SelfDisclosed, 0) Crim_SelfDisclosed
	--FROM   dbo.ApplAdditionalData ad with(nolock) inner join @TblApno a on ad.ssn = a.ssn 
	--WHERE  DateDiff(YY,ad.DateCreated,current_timestamp)<=10 
	--ORDER BY ad.DateCreated Desc;

	/*NOTE-NB:03/18/2013:-Changed to below stmt because the above always returns Top 1 which is not
	--correct; each apno if has self disclosure must return its data not just top 1 which means only one
	--apno which ever it is based on datecreated in desc order will be returned and not the rest of the qualified ones*/

  	SELECT  distinct id APNO, ISNULL(ad.Crim_SelfDisclosed, 0) Crim_SelfDisclosed, ad.DateCreated
	FROM   dbo.ApplAdditionalData ad with(nolock) inner join @TblApno a on ltrim(rtrim(replace(ad.ssn,'-',''))) = ltrim(rtrim(replace(a.ssn,'-','') ))
	WHERE  DateDiff(YY,ad.DateCreated,current_timestamp)<=10 
	ORDER BY ad.DateCreated Desc;

	--Self disclosed
		SELECT  distinct ac.Apno, ac.City , ac.State,ac.Country,ac.CrimDate, ac.applicantcrimid
		FROM   dbo.ApplicantCrim ac with(nolock) where ac.Apno in (Select [id] from @TblApno) --OR ac.SSN in (Select ssn from @TblApno);
		union all
		SELECT  distinct id as Apno, ac.City , ac.State,ac.Country,ac.CrimDate, ac.applicantcrimid
		FROM   dbo.ApplicantCrim ac with(nolock) inner join @TblApno a on ltrim(rtrim(replace(ac.ssn,'-',''))) = ltrim(rtrim(replace(a.ssn,'-','') ))
		 where ac.Apno is null 	

	--Past Convictions

	--DECLARE @TblPastConvictions AS Table( OApno INT, County varchar(50),CNTY_NO INT, Apno INT, CrimID INT, CaseNo varchar(50),Offense varchar(1000),Disp_Date DateTime,Disposition varchar(500) );

	--INSERT INTO @TblPastConvictions
	--SELECT C.Apno as OApno,C.County, C.CNTY_NO,  ap.ID as Apno, C.CrimID, C.CaseNo,C.Offense,C.Disp_Date,C.Disposition 
 --   FROM   dbo.Appl A with(nolock) 
	--inner join dbo.Crim C with(nolock) ON A.APNO = C.APNO 
	--inner join @TblApno ap on A.SSN= ap.SSN
	--where     C.[Clear]   = 'F' AND    C.IsHidden = 0 AND len(A.SSN) > 0 ;

	----This will only return distinct hits (all) from the latest background check performed (when the same hit is reported historically) for that individual
	--Select Distinct OApno,County,CNTY_NO, Apno, CrimID 
	--From @TblPastConvictions 
	--where crimid in(
	--     --Only include the latest hit where the caseno matches
	--	 select max(crimid) from @TblPastConvictions group by CNTY_NO, CaseNo
	--	 union all
	--	 --Only include the latest hit where the CNTY_NO,Offense,Disp_Date,Disposition matches
	--	 select max(crimid) from @TblPastConvictions group by CNTY_NO, Offense,Disp_Date,Disposition
	--	 ) 
	--Past Convictions

	DECLARE @TblPastConvictions AS Table( OApno INT, County varchar(50),CNTY_NO INT, Apno INT, CrimID INT, CaseNo varchar(50),Offense varchar(1000),Disp_Date DateTime,Disposition varchar(500),State varchar(25), isStatewide bit );

	INSERT INTO @TblPastConvictions
	SELECT C.Apno as OApno,C.County, C.CNTY_NO,  ap.ID as Apno, C.CrimID, C.CaseNo,C.Offense,C.Disp_Date,C.Disposition, co.State, isnull(co.isStatewide,0) isStatewide
    FROM   dbo.Appl A with(nolock) 
	inner join dbo.Crim C with(nolock) ON A.APNO = C.APNO 
	inner join dbo.Counties co with(nolock) ON co.CNTY_NO = C.CNTY_NO 
	inner join @TblApno ap on A.SSN= ap.SSN
	where     C.[Clear]   = 'F' AND    C.IsHidden = 0 AND len(A.SSN) > 0 ;

	--This will only return distinct hits (all) from the latest background check performed (when the same hit is reported historically) for that individual
	Select Distinct OApno,County,CNTY_NO, Apno, CrimID, State,isStatewide
	From @TblPastConvictions 
	where crimid in(
	     --Only include the latest hit where the caseno matches
		 select max(crimid) from @TblPastConvictions group by CNTY_NO, CaseNo
		 union all
		 --Only include the latest hit where the CNTY_NO,Offense,Disp_Date,Disposition matches
		 select max(crimid) from @TblPastConvictions group by CNTY_NO, Offense,Disp_Date,Disposition
		 ) 

	-- License
	SELECT lic.Apno, count(1)RecordCount FROM   dbo.ProfLic lic with(nolock) inner join @TblApno a on lic.Apno = a.[id] group by lic.Apno;

	--DL
	SELECT dl.Apno, count(1) RecordCount FROM   dbo.DL dl with(nolock) inner join @TblApno a on dl.Apno = a.[id] group by dl.Apno;

	-- Previous addresses
	SELECT Distinct adr.Apno, adr.City, adr.State, adr.Zip as zipcode, adr.DateStart, adr.DateEnd, adr.appladdressid
		FROM   dbo.ApplAddress adr with(nolock) where adr.Apno in(Select [id] from @TblApno) --OR adr.SSN in (Select ssn from @TblApno);
		Union all
		SELECT Distinct id as Apno, adr.City, adr.State, adr.Zip as zipcode, adr.DateStart, adr.DateEnd, adr.appladdressid
		FROM   dbo.ApplAddress adr with(nolock) inner join @TblApno a on ltrim(rtrim(replace(adr.ssn,'-',''))) = ltrim(rtrim(replace(a.ssn,'-','') ))
		where adr.Apno is null
	--	--Aliases
	--	SELECT apno,alias1_first, alias1_middle, alias1_last,alias2_first, alias2_middle, alias2_last,alias3_first, alias3_middle, alias3_last, alias4_first, alias4_middle, alias4_last FROM appl with(nolock) inner join @TblApno a on appl.Apno = a.[id]

		/*
	2019-10-10
	Santosh, Yves, Deepak: need to revisit the logic to ensure the process pulls aliases from the applalias table
	*/

	--	
	--Aliases

      SELECT apno,[first] as alias0_first,middle as alias0_middle,[last] as alias0_last,alias1_first, alias1_middle, alias1_last,alias2_first, alias2_middle, alias2_last,alias3_first, alias3_middle, alias3_last, alias4_first, alias4_middle, alias4_last FROM appl with(nolock) inner join @TblApno a on appl.Apno = a.[id]

	--Past Employment with precheck
	SELECT ta.id AS apno, a.APNO AS PastReport, e.city,e.state, e.zipcode, e.To_A, e.emplid FROM @TblApno ta
		INNER JOIN dbo.Appl a WITH(nolock) ON a.SSN =ta.ssn AND a.APNO <>  ta.id
		INNER JOIN dbo.Empl e WITH(nolock) ON e.Apno = a.APNO
		INNER JOIN appl aa with (nolock) on aa.apno = ta.id
		INNER JOIN dbo.ClientConfiguration cc ON cc.CLNO = aa.CLNO
			AND cc.ConfigurationKey = 'ZIPCRIM' 
			AND cc.value = 'TRUE'
		WHERE [dbo].[ZipCrimReportReachedMaxAttempts](ta.id, 5) = 0

	--Past Education with precheck
	SELECT ta.id AS apno, a.APNO AS PastReport, e.city,e.state, e.zipcode, e.To_A, e.EducatID FROM @TblApno ta
		INNER JOIN dbo.Appl a WITH(nolock) ON a.SSN =ta.ssn AND a.APNO <>  ta.id
		INNER JOIN dbo.Educat e WITH(nolock) ON e.Apno = a.APNO
		INNER JOIN appl aa with (nolock) on aa.apno = ta.id
		INNER JOIN dbo.ClientConfiguration cc ON cc.CLNO = aa.CLNO 
			AND cc.ConfigurationKey = 'ZIPCRIM' 
			AND cc.value = 'TRUE'
		WHERE [dbo].[ZipCrimReportReachedMaxAttempts](ta.id, 5) = 0

		
END
