--Modify: To insert into AdverseAction and AdverseActionHistory tables

CREATE PROCEDURE [dbo].[PreAdverseSelByApno] 
@Apno int

AS
declare @AdverseActionID int
declare @cnt int

set @cnt=(select count(1) from AdverseAction where apno=@apno)

if (@cnt=0) --if the apno is not existing in AdverseAction
   begin
	--insert into AdverseAction table
	insert into AdverseAction (APNO,StatusID,ClientEmail,Name,Address1,City,State,Zip)
	SELECT APNO
		,1 -- for StatusID
		--,substring(a.ssn,len(rtrim(a.ssn))-3,4) SSN
		,cc.Email Email
		,a.[First] + ' ' + isnull(a.Middle,'')+ ' ' + isnull(a.[Last],'') Name
		,isnull(a.Addr_Num,'') + ' ' + isnull(a.Addr_Apt,'') + ' ' + isnull(a.Addr_Dir,'') + ' ' + a.Addr_Street  + ' ' +  isnull(Addr_StType,'') Address1
		--,'' Address2
		,a.City
		,a.State
		,a.Zip
FROM Appl a LEFT OUTER JOIN ClientContacts cc ON a.clno = cc.clno
WHERE a.apno=@Apno and cc.PrimaryContact=1 AND not exists (select * from AdverseAction where APNO=@Apno)

	set @AdverseActionID=IDENT_CURRENT('AdverseAction')
	  
	--insert into AdverseActionHistory table 
	insert into AdverseActionHistory(AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
	Values (@AdverseActionID,1,1,'Client',getdate())
   end