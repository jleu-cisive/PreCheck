
CREATE PROCEDURE [dbo].[FormAdverseFileOpenByDept_Select] 
@userId char(10)
AS

if @userId in ('jchen','hollie','frank','skrenek')
 begin
	select afo.AdverseFileOpenLogID,afo.AdverseActionID,afo.Type,
	       afo.TypeID,afo.TypeName,afo.UserID,afo.Amended,afo.Confirmed,afo.Date,aa.Apno,aa.Name 
	  from adversefileopenlog afo,adverseaction aa
	 where afo.adverseactionid=aa.adverseactionid
	   and afo.Dispute=1
	   and afo.Complete=0
	order by afo.adverseactionid,afo.type,afo.typeid
 end

if @userId='zdaigle'
 begin
	select afo.AdverseFileOpenLogID,afo.AdverseActionID,afo.Type,
	       afo.TypeID,afo.TypeName,afo.UserID,afo.Amended,afo.Confirmed,afo.Date,aa.Apno,aa.Name 
	  from adversefileopenlog afo,adverseaction aa
	 where afo.adverseactionid=aa.adverseactionid
	   and afo.Dispute=1
	   and afo.Complete=0
	   and afo.Type='crim'
	order by afo.adverseactionid,afo.type,afo.typeid
 end

if @userId='brenda'
 begin
	select afo.AdverseFileOpenLogID,afo.AdverseActionID,afo.Type,
	       afo.TypeID,afo.TypeName,afo.UserID,afo.Amended,afo.Confirmed,afo.Date,aa.Apno,aa.Name 
	  from adversefileopenlog afo,adverseaction aa
	 where afo.adverseactionid=aa.adverseactionid
	   and afo.Dispute=1
	   and afo.Complete=0
	   and afo.Type in ('educat','empl','persref')
	order by afo.adverseactionid,afo.type,afo.typeid
 end

if @userId='asiskind'
 begin
	select afo.AdverseFileOpenLogID,afo.AdverseActionID,afo.Type,
	       afo.TypeID,afo.TypeName,afo.UserID,afo.Amended,afo.Confirmed,afo.Date,aa.Apno,aa.Name 
	  from adversefileopenlog afo,adverseaction aa
	 where afo.adverseactionid=aa.adverseactionid
	   and afo.Dispute=1
	   and afo.Complete=0
	   and afo.Type='proflic'
	order by afo.adverseactionid,afo.type,afo.typeid
 end


