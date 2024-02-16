
Create Proc dbo.sp_FormAdverseCheckDays
@Apno int
As
Declare @ErrorCode int
Declare @Cnt int

Begin Transaction
Set @ErrorCode=@@Error

Set @Cnt = (select DateDiff(dd,a.[Date],getDate())
	    from   AdverseActionHistory a,AdverseAction b
	    where  a.AdverseActionID=b.AdverseActionID
	      and  b.APNO=@Apno
  	      and  a.StatusID=5
  	    )            
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@Cnt)


