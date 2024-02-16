

/*
When status change to PreAdverse Mailed, 
append "PreAdverse sent" + date to front of Appl.SpecialInstructions
Created: 02-15-06 by JC
*/

CREATE procedure dbo.AppendSpecialInstruction_PreAdverseSent
@apno int

as

--if (select count(1) from Appl where apno=@apno and InUse is null) > 0
if (select count(1) from Appl a 
		        inner join AdverseAction aa on a.apno=aa.apno
		        inner join AdverseACtionHistory h on aa.AdverseACtionID=h.AdverseACtionID
		   where a.apno=@apno 
  		      and a.InUse is null
  		      and h.AdverseActionHistoryID in (select AdverseActionHistoryID from AdverseActionHistory h 
					   		inner join AdverseAction a on h.AdverseActionID=a.AdverseActionID
					   		where a.apno=@apno 
					     		  and h.StatusID=5 
					     		  and AppendedToAppl=0
				                      )) > 0
  begin
	update appl
   	      set InUse='WService'
	           ,special_instructions = '*** Pre-Adverse Notification Sent ' + convert(varchar(15),getdate(), 101) + ' *** ' + char(13) + char(10) + char(13) + char(10) + (select isnull(cast(special_instructions as varchar(8000)),'') from appl where apno=@apno)
 	           ,Priv_Notes = '*** Pre-Adverse Notification Sent ' + convert(varchar(15),getdate(), 101) + ' *** ' + char(13) + char(10) + char(13) + char(10) + (select isnull(cast(Priv_Notes as varchar(8000)),'') from appl where apno=@apno)
	  where apno=@apno
   	    and InUse is null

	update AdverseActionHistory
                    set AppendedToAppl=1
               where AdverseActionHistoryID in (select AdverseActionHistoryID from AdverseActionHistory h 
					    inner join AdverseAction a on h.AdverseActionID=a.AdverseActionID
					  where a.APNO=@apno 
					     and h.StatusID=5 
					     and AppendedToAppl=0
					  ) 
	
  --set InUse to null after appended to appl table 
    	update appl
   	      set InUse=null
              where apno=@apno and InUse='WService'			    
  end