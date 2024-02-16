CREATE PROCEDURE [dbo].[Web_AdverseSelectApno] 
@Apno int,
@SSN Varchar(20)

AS
declare @cnt  int
declare @cnt1 int

set @cnt=(select count(aa.apno) from adverseaction aa left join appl a on aa.apno=a.apno 
	   where aa.apno=@apno
  	     and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
	  )

set @cnt1=(select count(apno) from appl 
	   where apno=@apno
  	     and substring(ssn,len(rtrim(ssn))-3,4)=@ssn
	  )

if @cnt!=0
begin
	SELECT aa.name 
	FROM Adverseaction aa left join Appl a on aa.apno=a.apno    
	WHERE a.apno=@Apno 
  	and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@SSN
end
else
 begin
   if @cnt1!=0
        select 'NoRecords' as name
   else
	select '' as name
end