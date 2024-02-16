
CREATE Proc dbo.FormAdverseFileOpen_EmailMgr
@fileOpenLogId int

As
declare @ErrorCode int
declare @apno int
declare @appName varchar(50)
declare @type varchar(50)
declare @typeName varchar(50)

Begin Transaction
Set @ErrorCode=@@Error

set @type=(select Type from AdverseFileOpenLog where AdverseFileOpenLogID=@fileOpenLogId)

 select aet.[From]
	,case @type
	   when 'Credit' then 'FrankPierce@PRECHECK.com'--'holliefrye@precheck.com'
	   when 'Crim' then 'FrankPierce@PRECHECK.com'--'ZachDaigle@precheck.com' 
	   when 'ProfLic' then 'FrankPierce@PRECHECK.com'--'AndreaSiskind@precheck.com'
	   else 'FrankPierce@PRECHECK.com'--'BrendaPage@precheck.com'
	end as [To]
        ,aet.subject1+' '+aa.[Name]+'; (APNO: '+Convert(char(6),aa.apno)+') '+aet.subject2+@type as Subject
        ,aa.[Name]+';(APNO: '+Convert(char(6),aa.apno)+')'+aet.body1+@type+' record of '+f.typeName+aet.body2 as Body
from   AdverseFileOpenLog f,AdverseAction aa,AdverseEmailTemplate aet
where  f.AdverseFileOpenLogID=@fileOpenLogId
  and  f.adverseactionid=aa.adverseactionid
  and  aet.AdverseEmailTemplateID=7


If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction