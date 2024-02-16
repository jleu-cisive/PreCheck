-- =============================================
-- Author:		Suchitra Yellapantula
-- Create date: 4/7/2017
-- Description:	Identify Transferred Empl and Educat Records, for HDT 10558 requested by Dana Sangerhausen
-- Execution: exec dbo.[Identify_Transferred_Records] '04/05/2016','04/15/2016'
-- =============================================
CREATE PROCEDURE [dbo].[Identify_Transferred_Records] 
	-- Add the parameters for the stored procedure here
	  @StartDate datetime,
      @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE @tempData TABLE
( 
LogID int IDENTITY(1,1),
ChangeLogID int,
TableName varchar(150),
ID int,
NewValue varchar(8000),
ChangeDate datetime,
UserID varchar(50)
)

select A.APNO,A.CreatedDate,A.SSN as [SSN]
into #tempApplwithEmpl
from Appl A 
where A.CreatedDate >=@StartDate and A.CreatedDate<dateadd(day,1,@EndDate) and  A.Priv_Notes like '%SSN ALREADY EXISTS%'
and (select count(*) from Empl E where E.Apno=A.Apno and E.SectStat in ('5','7'))>0

select E.Employer, E.EmplID, E.Apno, T.SSN , E.SectStat
into #tempApplwithEmpl_1
from #tempApplwithEmpl T inner join Empl E on T.Apno = E.Apno
where E.SectStat in ('5','7')

select A.Apno, A.SSN , E.Employer, E.EmplID, E.SectStat
into #tempApplwithEmpl_2
from Appl A inner join Empl E on A.Apno = E.Apno 
where SSN in (select ssn from #tempApplwithEmpl)
and A.Apno not in (select Apno from #tempApplwithEmpl)
and E.SectStat in ('5','7')

select T1.* 
into #tempApplwithEmpl_Final
from #tempApplwithEmpl_1 T1
inner join #tempApplwithEmpl_2 T2 on T1.SSN = T2.SSN and T1.Employer = T2.Employer and T1.SectStat = T2.SectStat



select * 
into #temp1
from ChangeLog(nolock) CL 
where CL.ChangeDate>@StartDate and CL.ChangeDate<dateadd(d,1,@EndDate)
and CL.TableName like '%Empl.%' and ID<0
order by ChangeDate


select * 
into #temp_ChangeLog
from #temp1 where TableName='Empl.APNO' or TableName='Empl.Employer' or TableName='Empl.SectStat'
order by ChangeDate

select * 
into #temp_Empl
from Empl E 
where E.CreatedDate>@StartDate and E.CreatedDate<dateadd(d,1,@EndDate)

insert into @tempData(ChangeLogID, TableName, ID, NewValue, ChangeDate, UserID)
select TCL.HEVNMgmtChangeLogID, TCL.TableName, TCL.ID, TCL.NewValue, TCL.ChangeDate, TCL.UserID
from #temp_ChangeLog TCL

select TD.ChangeLogID, TD.NewValue [APNO],
(CASE WHEN ((select TableName from @tempData where LogID = (TD.LogID+1))='Empl.Employer'
            and (SELECT UserID from @tempData where LogID = (TD.LogID+1))=TD.UserID
			and (SELECT TableName from @tempData where LogID = (TD.LogID+2))='Empl.SectStat'
			and (SELECT NewValue from @tempData where LogID = (TD.LogID+2)) in ('5','7'))
      THEN (select NewValue from @tempData where LogID = (TD.LogID+1))  
	  ELSE '' END) [Employer],
TD.ChangeDate, TD.UserID
into #tempCLEmpls
from @tempData TD
where TD.TableName='Empl.APNO' --and TD.NewValue in (select Apno from #tempApplwithEmpl)

delete from #tempCLEmpls where isnull(Employer,'')=''

--select * from #tempCLEmpls
--select * from #tempApplwithEmpl


select * into #tempAppl2
from #tempApplwithEmpl TE where TE.APNO not in (select APNO from #tempCLEmpls)

select * into #tempServiceLog
from PrecheckServiceLog where Apno in (select Apno from #tempAppl2)

;WITH XMLNAMESPACES (
						N'http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper' as A
					)
select isnull(cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Employments/A:Employment/Employer)[1]','varchar(100)'),'') as [Employer], apno--cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Employments/A:Employment/SectStat)[1]','varchar(100)') as 'SectStat',APNO,ServiceDate
into #tempServiceLogData
--from #tempServiceLog PL 
from #tempServiceLog L(nolock) --3167561 and
where (cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Employments/A:Employment/SectStat)[1]','varchar(100)') in ('5','7'))



select * 
into #tempApplNotTransferred
from #tempApplwithEmpl_Final 
where (Apno not in (select Apno from #tempServiceLogData))
and (Apno not in (select Apno from #tempCLEmpls))



select * into #tempResult_Empl from 
((select T.Apno, A.CreatedDate as 'Report Date',A.SSN, C.Name as 'Client Name',A.CLNO, T.Employer as 'Employer or Education Name', S.Description as 'Status',A.Investigator as 'AI Name', 'Y' as 'Transferred (Y/N)'
from #tempServiceLogData T
inner join Appl A on A.Apno = T.Apno
inner join Client C on C.CLNO=A.CLNO
inner join EMpl E on E.Apno = A.Apno and E.Employer = T.Employer
inner join SectStat S on S.Code = E.SectStat
where E.SectStat in ('5','7'))
union
(select T.APNO, A.CreatedDate as 'Report Date',A.SSN, C.Name as 'Client Name',A.CLNO, T.Employer as 'Employer or Education Name', S.Description as 'Status',A.Investigator as 'AI Name', 'Y' as 'Transferred (Y/N)'
from #tempCLEmpls T
inner join Appl A on A.Apno = T.Apno
inner join Client C on C.CLNO=A.CLNO
inner join EMpl E on E.Apno = A.Apno and E.Employer = T.Employer
inner join SectStat S on S.Code = E.SectStat
where E.SectStat in ('5','7'))
union 
(select T.APNO, A.CreatedDate as 'Report Date',A.SSN, C.Name as 'Client Name',A.CLNO, T.Employer as 'Employer or Education Name', S.Description as 'Status',A.Investigator as 'AI Name', 'N' as 'Transferred (Y/N)' 
from #tempApplNotTransferred T
inner join Appl A on A.Apno = T.Apno
inner join Client C on C.CLNO=A.CLNO
inner join EMpl E on E.Apno = A.Apno and E.Employer = T.Employer
inner join SectStat S on S.Code = E.SectStat
where E.SectStat in ('5','7'))) as [EmplResults]



drop table #temp_ChangeLog
drop table #temp_Empl
drop table #temp1
drop table #tempCLEmpls
drop table #tempApplwithEmpl
drop table #tempAppl2
drop table #tempApplwithEmpl_1
drop table #tempApplNotTransferred
drop table #tempApplwithEmpl_2
drop table #tempApplwithEmpl_Final
drop table #tempServiceLog
drop table #tempServiceLogData
delete from @tempData


select A.APNO,A.CreatedDate,A.SSN as [SSN]
into #tempApplwithEducat
from Appl A 
where A.CreatedDate >=@StartDate and A.CreatedDate<dateadd(day,1,@EndDate) and  A.Priv_Notes like '%SSN ALREADY EXISTS%'
and (select count(*) from Educat E where E.Apno=A.Apno and E.SectStat in ('5','7'))>0

select E.School, E.EducatID, E.Apno, T.SSN , E.SectStat
into #tempApplwithEducat_1
from #tempApplwithEducat T inner join Educat E on T.Apno = E.Apno
where E.SectStat in ('5','7')


select A.Apno, A.SSN , E.School, E.EducatID, E.SectStat
into #tempApplwithEducat_2
from Appl A inner join Educat E on A.Apno = E.Apno 
where SSN in (select ssn from #tempApplwithEducat)
and A.Apno not in (select Apno from #tempApplwithEducat)
and E.SectStat in ('5','7')

select T1.* 
into #tempApplwithEducat_Final
from #tempApplwithEducat_1 T1
inner join #tempApplwithEducat_2 T2 on T1.SSN = T2.SSN and T1.School = T2.School and T1.SectStat = T2.SectStat



select * 
into #temp1_E
from ChangeLog(nolock) CL 
where CL.ChangeDate>@StartDate and CL.ChangeDate<dateadd(d,1,@EndDate)
and CL.TableName like '%Educat.%' and ID<0
order by ChangeDate


select * 
into #temp_ChangeLog_E
from #temp1_E where TableName='Educat.APNO' or TableName='Educat.Employer' or TableName='Educat.SectStat'
order by ChangeDate

select * 
into #temp_Educat
from Educat E 
where E.CreatedDate>@StartDate and E.CreatedDate<dateadd(d,1,@EndDate)

insert into @tempData(ChangeLogID, TableName, ID, NewValue, ChangeDate, UserID)
select TCL.HEVNMgmtChangeLogID, TCL.TableName, TCL.ID, TCL.NewValue, TCL.ChangeDate, TCL.UserID
from #temp_ChangeLog_E TCL

select TD.ChangeLogID, TD.NewValue [APNO],
(CASE WHEN ((select TableName from @tempData where LogID = (TD.LogID+1))='Educat.School'
            and (SELECT UserID from @tempData where LogID = (TD.LogID+1))=TD.UserID
			and (SELECT TableName from @tempData where LogID = (TD.LogID+2))='Educat.SectStat'
			and (SELECT NewValue from @tempData where LogID = (TD.LogID+2)) in ('5','7'))
      THEN (select NewValue from @tempData where LogID = (TD.LogID+1))  
	  ELSE '' END) [School],
TD.ChangeDate, TD.UserID
into #tempCLEducats
from @tempData TD
where TD.TableName='Educat.APNO' --and TD.NewValue in (select Apno from #tempApplwithEmpl)

delete from #tempCLEducats where isnull(School,'')=''

--select * from #tempCLEducats
--select * from #tempApplwithEmpl


select * into #tempAppl2_E
from #tempApplwithEducat TE where TE.APNO not in (select APNO from #tempCLEducats)

select * into #tempServiceLog_E
from PrecheckServiceLog where Apno in (select Apno from #tempAppl2_E)

;WITH XMLNAMESPACES (
						N'http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper' as A
					)
select isnull(cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Educations/A:Education/School_Name)[1]','varchar(100)'),'') as [School], apno--cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Employments/A:Employment/SectStat)[1]','varchar(100)') as 'SectStat',APNO,ServiceDate
into #tempServiceLogData_E
--from #tempServiceLog PL 
from #tempServiceLog_E L(nolock) --3167561 and
where (cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Educations/A:Education/SectStat)[1]','varchar(100)') in ('5','7'))



select * 
into #tempApplNotTransferred_E
from #tempApplwithEducat_Final 
where (Apno not in (select Apno from #tempServiceLogData_E))
and (Apno not in (select Apno from #tempCLEducats))



select * into #tempResult_Educat from 
((select T.Apno, A.CreatedDate as 'Report Date',A.SSN, C.Name as 'Client Name',A.CLNO, T.School as 'Employer or Education Name', S.Description as 'Status',A.Investigator as 'AI Name', 'Y' as 'Transferred (Y/N)'
from #tempServiceLogData_E T
inner join Appl A on A.Apno = T.Apno
inner join Client C on C.CLNO=A.CLNO
inner join Educat E on E.Apno = A.Apno and E.School = T.School
inner join SectStat S on S.Code = E.SectStat
where E.SectStat in ('5','7'))
union
(select T.APNO, A.CreatedDate as 'Report Date',A.SSN, C.Name as 'Client Name',A.CLNO, T.School as 'Employer or Education Name', S.Description as 'Status',A.Investigator as 'AI Name', 'Y' as 'Transferred (Y/N)'
from #tempCLEducats T
inner join Appl A on A.Apno = T.Apno
inner join Client C on C.CLNO=A.CLNO
inner join Educat E on E.Apno = A.Apno and E.School = T.School
inner join SectStat S on S.Code = E.SectStat
where E.SectStat in ('5','7'))
union 
(select T.APNO, A.CreatedDate as 'Report Date',A.SSN, C.Name as 'Client Name',A.CLNO, T.School as 'Employer or Education Name', S.Description as 'Status',A.Investigator as 'AI Name', 'N' as 'Transferred (Y/N)' 
from #tempApplNotTransferred_E T
inner join Appl A on A.Apno = T.Apno
inner join Client C on C.CLNO=A.CLNO
inner join Educat E on E.Apno = A.Apno and E.School = T.School
inner join SectStat S on S.Code = E.SectStat
where E.SectStat in ('5','7'))) as EducatResults

select * from #tempResult_Empl
union
select * from #tempResult_Educat



drop table #temp_ChangeLog_E
drop table #temp_Educat
drop table #temp1_E
drop table #tempCLEducats
drop table #tempApplwithEducat
drop table #tempAppl2_E
drop table #tempApplwithEducat_1
drop table #tempApplNotTransferred_E
drop table #tempApplwithEducat_2
drop table #tempApplwithEducat_Final
drop table #tempServiceLog_E
drop table #tempServiceLogData_E
drop table #tempResult_Educat
drop table #tempResult_Empl
delete from @tempData



END
