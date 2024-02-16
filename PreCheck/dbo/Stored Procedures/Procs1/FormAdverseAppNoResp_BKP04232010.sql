



CREATE Proc [dbo].[FormAdverseAppNoResp_BKP04232010]
As
--Declare @ErrorCode int
Declare @cnt int

set XACT_ABORT ON;
--Set @ErrorCode=@@Error

set @cnt=(select count(AdverseActionID)
	    from AdverseActionHistory
	   where statusID=5  
	     and datediff (dd,date,getdate())>5  
	     and AdverseActionHistoryID in 
                 (select max(h.AdverseActionHistoryID) as aahid
                    from AdverseAction a, AdverseActionHistory h 
		   where h.AdverseActionID = a.AdverseActionID
 		     and AdverseChangeTypeID=1 
 		     and a.ClientEmail is not null
					and a.statusid = 5
  		group by h.AdverseActionID
	 	  )
	  )

if @cnt>0
begin


-- select for auto email
select distinct aet.[From],aa.ClientEmail as [To],
       aet.subject1+appl.[last]+', '+appl.[first]+'; (APNO: '+Cast(aa.apno as varchar)+') '+aet.subject2 as Subject,
       aet.body1+appl.[last]+', '+appl.[first]+'; (APNO: '+Cast(aa.apno as varchar)+') '+aet.body2 as Body
  from AdverseAction aa,AdverseEmailTemplate aet,Appl appl,adverseactionhistory aah, client c
 where aa.statusid=5
   and aa.adverseactionid=aah.adverseactionid
   and aa.statusid=aah.statusid
and c.clno=appl.clno	--hz added on 7/7/06
and c.adverse<>3	--hz added on 7/7/06
   and aa.clientemail is not null
   and datediff (dd,aah.[date],getdate())>5
   and aa.apno=appl.apno
   and aet.refAdverseStatusID=6 
   and aah.AdverseActionHistoryID in 
                 (select max(h.AdverseActionHistoryID) as aahid
                    from AdverseAction a, AdverseActionHistory h 
		   where h.AdverseActionID = a.AdverseActionID
 		     and AdverseChangeTypeID=1 
			and a.statusid = 5
  		group by h.AdverseActionID
	 	  ) 


Begin Transaction

 --update adverseaction table
  update adverseaction
     set statusid=6
   where adverseactionid in (select AdverseActionID as aaid
	    		       from AdverseActionHistory
	  		      where statusID=5  
	     		        and datediff (dd,date,getdate())>5  
	     		        and AdverseActionHistoryID in 
                 		    (select max(h.AdverseActionHistoryID) as aahid
                    		      from AdverseAction aa, AdverseActionHistory h, appl a, client c 
			   where h.AdverseActionID = aa.AdverseActionID
				and a.clno=c.clno	--hz added on 7/7/06
				and aa.apno=a.apno	--hz added on 7/7/06
				and c.adverse<>3	--hz added on 7/7/06
 			     and h.AdverseChangeTypeID=1 
			     and aa.ClientEmail is not null
					and aa.statusid = 5
  			group by h.AdverseActionID
	 		  ) 
		   )
 
--insert into adverseactionhistory
insert into adverseactionhistory (adverseactionid,adversechangetypeid,statusid,userid,[date])
select AdverseActionID,1,6,'AutoEmail',getdate()
	    from AdverseActionHistory
	   where statusID=5  
	     and datediff (dd,date,getdate())>5  
	     and AdverseActionHistoryID in 
                 (select max(h.AdverseActionHistoryID) as aahid
                    from AdverseAction aa, AdverseActionHistory h, appl a, client c 
		   where h.AdverseActionID = aa.AdverseActionID
			and a.clno=c.clno	--hz added on 7/7/06
			and aa.apno=a.apno	--hz added on 7/7/06
			and c.adverse<>3	--hz added on 7/7/06
 		     and h.AdverseChangeTypeID=1 
		     and aa.ClientEmail is not null
				and aa.statusid = 5
  		group by h.AdverseActionID
	 	  ) 


  Commit Transaction

end

        
--If (@ErrorCode<>0)
--  Begin
--  RollBack Transaction
--  Return (-@ErrorCode)
--  End
--Else




