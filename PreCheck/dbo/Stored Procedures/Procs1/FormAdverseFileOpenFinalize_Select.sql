
CREATE PROCEDURE [dbo].[FormAdverseFileOpenFinalize_Select] 
AS

select afo.AdverseFileOpenLogID,afo.AdverseActionID,afo.Type,
       afo.TypeID,afo.TypeName,afo.UserID,afo.Amended,afo.Confirmed,afo.Complete,aa.Apno,aa.Name 
  from adversefileopenlog afo,adverseaction aa
 where afo.adverseactionid=aa.adverseactionid
   and afo.Dispute=1
   and afo.Complete=0
order by afo.adverseactionid,afo.type,afo.typeid
 

