
Create Proc dbo.FormAdverseCreateNew_Insert
@apno int,
@userid char(10),
@clientemail varchar(50),
@name varchar(50),
@addr1 varchar(50),
@addr2 varchar(50),
@city varchar(25),
@state char(2),
@zip char(5)
As
Declare @ErrorCode int
Declare @aaid int

Begin Transaction
--insert into AdverseAction table
insert AdverseAction (apno,statusid,clientemail,name,address1,address2,city,state,zip)
values(@apno,1,@clientemail,@name,@addr1,@addr2,@city,@state,@zip)
Select @aaid=@@Identity

--insert into AdverseActionHistory table
insert into AdverseActionHistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,[Date])
values(@aaid,1,1,@userid,getdate())
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (@@Identity)

