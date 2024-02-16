

--Modified by JC on 12-05-05. To hsndle Hospital_CLNO for SudentCheck
CREATE Proc [dbo].[FormAdverse_Info]
@aaid int,
@statusgroup varchar(50) = 'AdverseAction'
As
Declare @ErrorCode int

declare @clno int

if (@statusgroup = 'AdverseAction')
Begin
set @clno=(select isnull(aa.Hospital_CLNO,a.clno)-- clno 
	     from AdverseAction aa,Appl a
	    where aa.AdverseaCtionID=@AAID
              and aa.Apno=a.Apno)
	

Begin Transaction

select distinct aa.AdverseActionID As aaid
	,aa.apno
	--,appl.clno
	,@clno clno
        ,cl.[name] As client
	,aa.clientemail
       	,appl.ssn As ApplicantSSN
	,aa.[name] As ApplicantName
	,aa.StatusID As StatusID
	,refas.Status As Status
	,cl.adverse	--hz added on 7/14/06 
from   AdverseAction aa,Appl appl,Client cl,refAdverseStatus refas
where  aa.AdverseActionID=@AAID
  and  aa.APNO=appl.APNO 
  --and  appl.clno=cl.clno
  and  cl.clno=@clno 
  and  aa.StatusID=refas.refAdverseStatusID
End

else if (@statusgroup = 'FreeReport')
Begin

set @clno=(select isnull(aa.CLNO,a.clno)-- clno 
	     from FreeReport aa,Appl a
	    where aa.FreeReportID=@AAID
              and aa.Apno=a.Apno)
	

Begin Transaction

select distinct aa.FreeReportID As aaid
	,aa.apno
	--,appl.clno
	,@clno clno
        ,cl.[name] As client
	,'' as clientemail
       	,appl.ssn As ApplicantSSN
	,aa.[name] As ApplicantName
	,aa.StatusID As StatusID
	,refas.Status As Status
	,ISNULL(cl.adverse,0) as Adverse	--hz added on 7/14/06 
from   FreeReport aa,Appl appl,Client cl,refAdverseStatus refas
where  aa.FreeReportID=@AAID
  and  aa.APNO=appl.APNO 
  and  cl.clno=@clno 
  and  aa.StatusID=refas.refAdverseStatusID


END


                    
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)

