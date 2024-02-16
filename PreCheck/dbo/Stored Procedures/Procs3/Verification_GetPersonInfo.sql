
CREATE procedure dbo.Verification_GetPersonInfo(
@apno int
)
as
declare @ssn varchar(11)
declare @dob varchar(11)
declare @first varchar(50)
declare @last varchar(100)

--set @apno = 2188058

select @ssn = isnull(replace(ssn,'-',''),''),@first = isnull(first,''),@last = isnull(last,''),@dob = convert(varchar,dob,126) 
 from dbo.Appl where apno = @apno

 select @ssn as ssn,@first as first,@last as last,@dob as dob