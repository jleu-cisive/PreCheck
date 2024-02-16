
CREATE PROCEDURE [dbo].[FormAdverseFileOpen_Upd] 
@fileOpenLogId int,
@userId char(10),
@status bit,
@updType nvarchar(15)

AS
if @updType='dispute'
  begin
     update AdverseFileOpenLog
        set UserID=@userid, Dispute=@status, Date=getdate()
      where AdverseFileOpenLogID=@fileOpenLogId
  end

else if @updType='complete'
 begin
     update AdverseFileOpenLog
        set UserID=@userid, Complete=@status, Date=getdate()
      where AdverseFileOpenLogID=@fileOpenLogId
  end

