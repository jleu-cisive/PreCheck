

-- =============================================
-- Description:- Sp updates the AdverseAction/FreeReport Table and AdverseHistory Table When letter is printed
-- =============================================
--Modified: 02-07-06 by JC - to insert ReportID in history table after added ReportID column in History table
-- =============================================
-- Edit By:-	Kiran Miryala	
-- Edit Date :- 02/02/2009
-- Description:- Changed the Sp to updated FreeReport Table
--
--
--===================================================


CREATE Proc [dbo].[sp_FormAdverseLetterPrinted]
@Aaid int,
@StatusId int,
@UserId char(10),
@ReportID int = 0, -- Added on 02-07-06 by JC 
@statusgroup varchar(50) = 'AdverseAction' -- Added on 02-03-09 by Kiran 
As
Declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

if (@statusgroup = 'AdverseAction')
Begin
--Modify AdverseAction table for status changed
update AdverseAction
set StatusID=@StatusId
where AdverseActionID=@Aaid

End
-- added by kiran on 02-03-2009
else if (@statusgroup = 'FreeReport')
Begin
update FreeReport
set StatusID=25  --25 = Free Report Printed in refAdverseStatus Table
where FreeReportID=@Aaid

set @StatusId = 25
END



--Add new record in AdverseActionHistory table 
--for AA Letter Printed,PAA Letter Printed,Confirm Letter Printed, and Amend Letter Printed
Insert into AdverseActionHistory (AdverseActionID,StatusID,UserID,[Date],ReportID)
	values (@Aaid,@StatusId,@UserId,getdate(),@ReportID)

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (@ErrorCode)

