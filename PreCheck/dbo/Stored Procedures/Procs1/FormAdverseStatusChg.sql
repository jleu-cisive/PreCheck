

-- =============================================
-- Description:- Sp updates the AdverseAction/FreeReport Table and AdverseHistory Table When there is a status change
-- =============================================
--
-- Edit By:-	Kiran Miryala	
-- Edit Date :- 02/02/2009
-- Description:- Changed the Sp to updated FreeReport Table
--
--
--===================================================


CREATE Proc [dbo].[FormAdverseStatusChg]
(@aaid int,
 @statusid int,
 @paletterreturnid int,
 @aaletterReturnid int,
 @userid char(10),
 @comment text,
@statusgroup varchar(50) = 'AdverseAction'
 )
As
Declare @ErrorCode int
Declare @aahid int
Declare @apno int
Declare @PrvNotes varchar(2000)  
Declare @PubNotes varchar(2000) 
Declare @date datetime
set @date = getdate()

Begin Transaction
Set @ErrorCode=@@Error

--Add new record in AdverseActionHistory
Insert into AdverseActionHistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Comments,[Date])
    Values(@aaid,1,@statusid,@userid,@comment,getdate())
Select @aahid=@@Identity

--Modify AdverseAction for status --modified on 07/17/05 to handle PreAdverseLetterReturn and AdverseLetterReturn
if (@statusgroup = 'AdverseAction')
Begin
update AdverseAction
set StatusID=@statusid,
    PreAdverseLetterReturnID=@paletterreturnid,
    AdverseLetterReturnID=@aaletterreturnid
where AdverseActionID=@aaid
End

else if (@statusgroup = 'FreeReport')
Begin

update FreeReport
set StatusID=@statusid,
    FreeReportLetterReturnID=@paletterreturnid,
   [2ndLetterReturnID]=@aaletterreturnid
where FreeReportID=@aaid 
 if (@statusid =26)
	Begin
	
	select  @PubNotes = a.Pub_Notes, @PrvNotes = a.Priv_Notes, @apno = a.APNO
	from appl a inner join FreeReport b on a.APNO=b.APNO 
	where  b.FreeReportID=@aaid 
	
 --Select @date = convert(varchar,@Date)

Select @PubNotes = @PubNotes + char(13) + char(13) +
	'** Free Report Mailed  **' + char(13) + 'Date:  ' + convert(varchar,@Date) + + char(13)
	
Select @PrvNotes = @PrvNotes + char(13) + char(13) +
	'** Free Report Mailed  **' + char(13) + 'Date:  ' + convert(varchar,@Date) + + char(13)


update Appl 
set Pub_Notes=@PubNotes,
    Priv_Notes=@PrvNotes
   
where APNO=@apno


	END

End
 
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@aahid)

