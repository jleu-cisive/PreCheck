
Create Proc dbo.FormAdverseContactInfo_InsAdverseActionHistory
@apno int,
@userid char(10),
@adversechangetypeid int,
@adversecontactmethodid int,
@comment text

As
Declare @ErrorCode int
Declare @adverseactionid int

Begin Transaction
set @adverseactionid=(select adverseactionid from adverseaction where apno=@apno) 

--insert into AdverseActionHistory table
insert into AdverseActionHistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,AdverseContactMethodID,Comments,Date)
 select @adverseactionid,@adversechangetypeid
	,(select statusid 
	  from adverseactionhistory aah 
	 where aah.adverseactionhistoryid=(select max(aah.adverseactionhistoryid) 
					   from adverseactionhistory aah inner join adverseaction aa on aah.adverseactionid=aa.adverseactionid
					   where aa.apno=@apno)
	 )								
	,@userid
	,@adversecontactmethodid
	,@comment
	,getdate()
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  


