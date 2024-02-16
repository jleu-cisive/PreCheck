
CREATE Proc dbo.sp_FormAdverseListNewAdverse
@apno int,
@UserId char(10),
@ClientEmail varchar(50),
@name varchar(50),
@Addr1 varchar(50),
@Addr2 varchar(50),
@city varchar(25),
@state char(2),
@zip char(5)
As
Declare @ErrorCode int
Declare @aaid int

Begin Transaction
--insert into AdverseAction table
insert AdverseAction
values(@apno,null,1,@ClientEmail,@name,@Addr1,@Addr2,@city,@state,@zip)
Select @aaid=@@Identity

--insert into AdverseActionHistory table
INSERT INTO AdverseActionHistory (AdverseActionID,StatusID,UserID,[Date])
VALUES(@aaid,1,@UserId,GetDate())
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@@Identity)