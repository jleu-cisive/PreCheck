






CREATE Proc [dbo].[FormAdverseAppNoResp]
As
--Declare @ErrorCode int
Declare @cnt int

set XACT_ABORT ON;
--Set @ErrorCode=@@Error

set @cnt=(select count(AdverseActionID)
	    from AdverseActionHistory
	   where --statusID=5  	     and --datediff (dd,date,getdate())>6  
		   (  (DATEDIFF(dd, date, getdate())+1 )
  -(DATEDIFF(wk, date, getdate()) * 2)
  -(CASE WHEN DATENAME(dw, date) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1 ELSE 0 END))>6 
	     and AdverseActionHistoryID in 
                 (select max(h.AdverseActionHistoryID) as aahid
                    from AdverseAction a, AdverseActionHistory h , dbo.refAdverseStatus s 
		   where h.AdverseActionID = a.AdverseActionID
		    AND h.StatusID=s.refAdverseStatusID
 		     and AdverseChangeTypeID=1 
 		     and a.ClientEmail is not null
					and a.statusid in ( 5, 30)
					--and h.Source = 'AdverseAction'
					AND s.statusGroup='AdverseAction'
  		group by h.AdverseActionID
	 	  )
	  )
	--  select @cnt
	 -- select *
	 --   from AdverseActionHistory
	 --  where --statusID=5  	     and --datediff (dd,date,getdate())>6  
		--   (  (DATEDIFF(dd, date, getdate())+1 )
  ---(DATEDIFF(wk, date, getdate()) * 2)
  ---(CASE WHEN DATENAME(dw, date) = 'Sunday' THEN 1 ELSE 0 END)
  ---(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1 ELSE 0 END))>6 
	 --    and AdverseActionHistoryID in 
  --               (select max(h.AdverseActionHistoryID) as aahid
  --                  from AdverseAction a, AdverseActionHistory h 
		--   where h.AdverseActionID = a.AdverseActionID
 	--	     and AdverseChangeTypeID=1 
 	--	     and a.ClientEmail is not null
		--			and a.statusid in ( 5, 30)
  --		group by h.AdverseActionID
	 --	  )

if @cnt>0
begin


-- select for auto email
select AdverseActionHistoryID,aa.AdverseActionID,aa.statusid, aet.[From],aa.ClientEmail as  [To],
       aet.subject1+appl.[last]+', '+appl.[first]+'; (APNO: '+Cast(aa.apno as varchar)+') '+aet.subject2 as Subject,
       aet.body1+appl.[last]+', '+appl.[first]+'; (APNO: '+Cast(aa.apno as varchar)+') '+aet.body2 as Body
 into #temp1
  from AdverseAction aa ,Appl appl,adverseactionhistory aah, client c ,AdverseEmailTemplate aet
 where aa.statusid = 5
   and aa.AdverseActionID=aah.AdverseActionID
  -- and aa.statusid=aah.statusid
and c.clno=appl.clno	--hz added on 7/7/06
and ISNULL(c.adverse,'')<>3	--hz added on 7/7/06
   and aa.clientemail is not null
  -- and datediff (dd,aah.[date],getdate())>5
-- This change is made to give enough time for the applicant to recive the mailed Preadverse notification and distpute any issues before client gets the email to kick in Adverse action. cahged on 7/25/2012 by kiran
 and-- datediff (dd,aah.[date],getdate()) > 6 
 	 (  (DATEDIFF(dd, date, getdate())+1 )
  -(DATEDIFF(wk, date, getdate()) * 2)
  -(CASE WHEN DATENAME(dw, date) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1 ELSE 0 END))>6
   and aa.apno=appl.apno
   and aet.refAdverseStatusID=6 
   and aah.AdverseActionHistoryID in 
                 (select max(h.AdverseActionHistoryID) as aahid
                    from AdverseAction a, AdverseActionHistory h 
		   where h.AdverseActionID = a.AdverseActionID
 		     and AdverseChangeTypeID=1 
			and a.statusid =5
  		group by h.AdverseActionID
	 	  ) 
Union all
select AdverseActionHistoryID,aa.AdverseActionID,aa.statusid, aet.[From],aa.ClientEmail as  [To],
       aet.subject1+appl.[last]+', '+appl.[first]+'; (APNO: '+Cast(aa.apno as varchar)+') '+aet.subject2 as Subject,
       aet.body1+appl.[last]+', '+appl.[first]+'; (APNO: '+Cast(aa.apno as varchar)+') '+aet.body2 as Body

  from AdverseAction aa ,Appl appl,adverseactionhistory aah, client c ,AdverseEmailTemplate aet
 where aa.statusid = 30
   and aa.AdverseActionID=aah.AdverseActionID
 
and c.clno=appl.clno	--hz added on 7/7/06
and ISNULL(c.adverse,'')<>3	--hz added on 7/7/06
   and aa.clientemail is not null
   and-- datediff (dd,aah.[date],getdate()) > 6 
 	 (  (DATEDIFF(dd, date, getdate())+1 )
  -(DATEDIFF(wk, date, getdate()) * 2)
  -(CASE WHEN DATENAME(dw, date) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1 ELSE 0 END))>6
   and aa.apno=appl.apno
   and aet.refAdverseStatusID=30 
   and aah.AdverseActionHistoryID in 
                 (select max(h.AdverseActionHistoryID) as aahid
                    from AdverseAction a, AdverseActionHistory h, dbo.refAdverseStatus s 
		   where h.AdverseActionID = a.AdverseActionID
		   AND h.StatusID=s.refAdverseStatusID
 		     and AdverseChangeTypeID=1 
			and a.statusid =30
			--and h.Source = 'AdverseAction'
					AND s.statusGroup='AdverseAction'
  		group by h.AdverseActionID
	 	  ) 
		  --Select * from #temp1
		  select distinct [From], [To], Subject, Body
	   from #temp1

Begin Transaction

    --select AdverseActionID as aaid into #tmpAdvesre
    --from AdverseActionHistory
    --where statusID=5      and datediff (dd,date,getdate())>6  
	   -- and AdverseActionHistoryID in (select max(h.AdverseActionHistoryID) as aahid 
		  --    from AdverseAction aa, AdverseActionHistory h, appl a, client c 
			 --  where h.AdverseActionID = aa.AdverseActionID
				--and a.clno=c.clno	--hz added on 7/7/06
				--and aa.apno=a.apno	--hz added on 7/7/06
				--and c.adverse<>3	--hz added on 7/7/06
				-- and h.AdverseChangeTypeID=1 
				-- and aa.ClientEmail is not null
				--	and aa.statusid = 5
				--group by h.AdverseActionID)

select AdverseActionID as aaid into #tmpAdvesre from #temp1

 --update adverseaction table
  update adverseaction
     set statusid=6
   where adverseactionid in (Select aaid From #tmpAdvesre) 
 
--insert into adverseactionhistory
insert into adverseactionhistory (adverseactionid,adversechangetypeid,statusid,userid,[date],Source)
select aaid,1,6,'AutoEmail',getdate(),'AdverseAction'
	    from #tmpAdvesre

--Select * From #tmpAdvesre
  Drop table #tmpAdvesre

  Commit Transaction

end
  Drop table #temp1
        
--If (@ErrorCode<>0)
--  Begin
--  RollBack Transaction
--  Return (-@ErrorCode)
--  End
--Else







