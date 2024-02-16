Create Proc dbo.FormNewApplication_Update
 @aaid int,
 @name nvarchar(50),
 @clientemail nvarchar(50),
 @addr1 nvarchar(50),
 @addr2 nvarchar(50),
 @city nvarchar(20),
 @state char(2),
 @zip char(5),
 @userid char(10),
 @comment text
 
as
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

update AdverseAction
	set name=@name,
	    clientemail=@clientemail,
	    address1=@addr1,
	    address2=@addr2,
	    city=@city,
	    state=@state,
	    zip=@zip
	where AdverseActionID=@aaid
--insert into AdverseActionHistory
insert adverseactionhistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Comments,[Date])
select @aaid,2,
       (select statusid 
         from adverseactionhistory 
        where adverseactionhistoryid=(select max(adverseactionhistoryid)
					from adverseactionhistory
				       where adverseactionid=@aaid)),
       @userid,
        /*
       (select adversecontactmethodid 
         from adverseactionhistory 
        where adverseactionhistoryid=(select max(adverseactionhistoryid)
					from adverseactionhistory
				       where adverseactionid=@aaid)),
       */ 
       @comment,
       getdate()                          

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction