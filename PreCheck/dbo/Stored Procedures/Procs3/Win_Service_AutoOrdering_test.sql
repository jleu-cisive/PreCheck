-- Alter Procedure Win_Service_AutoOrdering_test



--Win_Service_AutoOrdering_test '6/29/2012'
-- =============================================
-- Author:		Najma,Begum
-- Create date: 05/24/2012
-- Description:	Get county, empl etc automation data
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AutoOrdering_test]

	-- Add the parameters for the stored procedure here
@Date datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @TblApno AS Table( [id] INT, ssn varchar(11) );


	INSERT INTO @TblApno([id], ssn)
	--SELECT Apno, ssn FROM dbo.Appl with(nolock) WHERE Appl.NeedsReview in('W3','X3','S3','R3') --and dbo.Appl.InUse is NULL;
	SELECT top 10 Apno, ssn FROM dbo.Appl with(nolock) WHERE Appl.NeedsReview like '%2' and --dbo.Appl.InUse ='CNTY_S' 

 dbo.Appl.EnteredVia='StuWeb'
order by APNO desc;


	--CR	
	SELECT a.ssn,a.apno,a.city,a.[state],a.zip as zipcode,a.enteredvia FROM dbo.Appl a with(nolock) inner join @TblApno n on a.apno = n.id;
	
	

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
	select apno, city,[state], zipcode, To_A from dbo.empl e with(nolock) inner join @TblApno a on e.apno = a.id;
	--Edu
	select apno, city,[state], zipcode, To_A from dbo.educat e with(nolock) inner join @TblApno a on e.apno = a.id;
	
	--PID
--	 select a.id as apno, pid.ssn, pid.aliases,pid.counties from [dbo].[positiveidresponselog] pid with(nolock) inner join @TblApno a on REPLACE(pid.ssn, '-', '')  = REPLACE(a.ssn, '-', '')
--     where searchdate in (SELECT max(pid.searchdate) FROM [dbo].[positiveidresponselog] pid inner join @TblApno a on REPLACE(pid.ssn, '-', '')  = REPLACE(a.ssn, '-', '') and pid.searchdate > @Date);

	--IsSelfDisclosed
	SELECT TOP 1 ad.Apno, ISNULL(ad.Crim_SelfDisclosed, 0) Crim_SelfDisclosed
	FROM   dbo.ApplAdditionalData ad with(nolock) inner join @TblApno a on ad.ssn = a.ssn 
	WHERE  DateDiff(YY,ad.DateCreated,current_timestamp)<=10 
	ORDER BY ad.DateCreated Desc;

	--Self disclosed
		SELECT Distinct ac.Apno, ac.City , ac.State,ac.Country,ac.CrimDate
		FROM   dbo.ApplicantCrim ac with(nolock) where ac.Apno in (Select [id] from @TblApno) OR ac.SSN in (Select ssn from @TblApno);
				
		
	--Past Convictions
	
	SELECT distinct C.Apno,C.County, C.CNTY_NO
	FROM   dbo.Appl A with(nolock) inner join dbo.Crim C with(nolock) ON A.APNO = C.APNO where A.SSN in (Select ssn from @TblApno) AND
	C.[Clear] 	= 'F'	AND    C.IsHidden = 0;
		
	-- License
	SELECT lic.Apno, count(1)RecordCount FROM   dbo.ProfLic lic with(nolock) inner join @TblApno a on lic.Apno = a.[id] group by lic.Apno;
	
	--DL
	SELECT dl.Apno, count(1) RecordCount FROM   dbo.DL dl with(nolock) inner join @TblApno a on dl.Apno = a.[id] group by dl.Apno;

	-- Previous addresses
	SELECT Distinct adr.Apno, adr.City, adr.State, adr.Zip, adr.DateStart, adr.DateEnd
		FROM   dbo.ApplAddress adr with(nolock) where adr.Apno in(Select [id] from @TblApno) OR adr.SSN in (Select ssn from @TblApno);

	--Aliases
	SELECT apno,alias1_first, alias1_middle, alias1_last,alias2_first, alias2_middle, alias2_last,alias3_first, alias3_middle, alias3_last, alias4_first, alias4_middle, alias4_last FROM appl with(nolock) inner join @TblApno a on appl.Apno = a.[id]
	
END

PRINT 'Add Win_Service_AutoOrdering Succeeded'
