

--[ClientCriminalSearchof5] '01/01/2014', '06/12/2014'


CREATE PROCEDURE [dbo].[ClientCriminalSearchof5] 

@StartDate DateTime = '01/01/2014', 
@EndDate DateTime = '07/15/2014'

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select distinct c.CLNO, C.Name as ClientName, C.CAM, rt.SpecialReg as SpecialRegistries, rt.Civil, rt.Federal, rt.Statewide, C.MVR, rc.CreditNotes , Count(a.apno) as TotalReportNumbers,
 rf.NumOfRecord as CriminalSearchCount,
 (Select Count(1) from ReleaseForm where clno = c.clno and [date] BETWEEN @StartDate AND DATEADD(d,1,@EndDate) ) as TotalOnlineReleases
 From  dbo.Client C 
left join dbo.Appl a on c.CLNO = a.CLNO 
left join dbo.refRequirementText rt on c.CLNO = rt.CLNO
 left join dbo.refRequirement rf on a.CLNO = rf.CLNO
 left join dbo.refCreditNotes rc on c.CreditNotesID = rc.CreditNotesID
 Where (a.Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)) AND  rf.RecordType ='Crim' 
group by c.CLNO, c.Name, c.CAM,rt.SpecialReg, rt.Civil, rt.Federal, rt.Statewide, rf.NumOfRecord, c.MVR, rc.CreditNotes
order by c.CLNO

--schapyala commented and redid the query on 07/15/2014
--Select distinct rt.CLNO, C.Name as ClientName, C.CAM, rt.SpecialReg as SpecialRegistries, rt.Civil, rt.Federal, rt.Statewide, C.MVR, rc.CreditNotes , Count(a.apno) as TotalReportNumbers,
-- rf.NumOfRecord as CriminalSearchCount,
-- (Select Count(*) from ReleaseForm where clno = rt.clno) as TotalOnlineReleases
-- From refRequirementText rt
-- inner join Client C on c.CLNO = rt.CLNO
-- inner join Appl a on c.CLNO = a.CLNO
-- inner join refRequirement rf on rf.CLNO = rt.CLNO
-- inner join refCreditNotes rc on c.CreditNotesID = rc.CreditNotesID
-- Where (a.Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)) AND  rf.RecordType ='Crim' 
--group by rt.CLNO, c.Name, c.CAM,rt.SpecialReg, rt.Civil, rt.Federal, rt.Statewide, rf.NumOfRecord, c.MVR, rc.CreditNotes
--order by rt.CLNO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF


--Select PM.PackageDesc, PM.PackageID, PS.ServiceType, PS.IncludedCount from
--PackageService PS 
--inner join PackageMain PM on PS.PackageID = PM.PackageID
--inner join ClientPackages cp on cp.PackageID = PS.PackageID
--where PS.ServiceType = 0 and Ps.IncludedCount < 5
--and cp.CLNO in (Select tc.CLNO from #TempClient tc)


--create table #TempCLNO
--( 
--   CLNO int
--) 

--INSERT INTO #TempCLNO (CLNO)
--Select distinct cp.CLNO
-- from
--PackageService PS 
--inner join PackageMain PM on PS.PackageID = PM.PackageID
--inner join ClientPackages cp on cp.PackageID = PS.PackageID
--where PS.ServiceType = 0 and Ps.IncludedCount >=5
--and cp.CLNO in (Select tc.CLNO from #TempClient tc)
--and  cp.CLNO not in
--(
--Select  cp.CLNO from
--PackageService PS 
--inner join PackageMain PM on PS.PackageID = PM.PackageID
--inner join ClientPackages cp on cp.PackageID = PS.PackageID
--where PS.ServiceType = 0 and Ps.IncludedCount < 5
--and cp.CLNO in (Select tc.CLNO from #TempClient tc))
















