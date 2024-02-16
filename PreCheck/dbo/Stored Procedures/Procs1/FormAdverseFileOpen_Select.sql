
CREATE PROCEDURE [dbo].[FormAdverseFileOpen_Select] 
@userId char(10)
AS

-- populate AdverseFileOpenLog
exec FormAdverseFileOpen_PopulateFileOpenLog @userId
--  update AdverseAction and insert AdverseActionHistory: changing status from will dispute to file open 
exec FormAdverseFileOpen_UpdAAStatus @userId

select afo.AdverseFileOpenLogID,afo.AdverseActionID,afo.Type,
       afo.TypeID,afo.TypeName,afo.UserID,afo.Dispute,aa.Apno,aa.Name 
  from adversefileopenlog afo,adverseaction aa
 where afo.adverseactionid=aa.adverseactionid
order by afo.adverseactionid,afo.type,afo.typeid


