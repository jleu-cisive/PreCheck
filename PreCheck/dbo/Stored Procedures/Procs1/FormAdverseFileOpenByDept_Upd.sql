
CREATE PROCEDURE [dbo].[FormAdverseFileOpenByDept_Upd] 
@fileOpenLogId int,
@userId char(10),
@amended bit,
@confirmed bit

AS
  update AdverseFileOpenLog
     set UserID=@userid, Amended=@amended, Confirmed=@confirmed,Date=getdate()
   where AdverseFileOpenLogID=@fileOpenLogId

