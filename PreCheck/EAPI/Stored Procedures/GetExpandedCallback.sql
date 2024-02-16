  
 --EXEC [EAPI].[GetExpandedCallback]     
 
/**
Changes by Santosh Chapyala
Date: 09-21-2023
Description: Optimized query
-- modified by Lalit on 2 dec 2024 for #116939
 **/   
CREATE procedure [EAPI].[GetExpandedCallback]      
as      
BEGIN      
      
    
declare @defaultDate datetime      
--Leap Year Fix      
--if (year(CURRENT_TIMESTAMP)%4 = 0)      
-- set @defaultDate = DATEADD(DAY,-1,CURRENT_TIMESTAMP)      
--else      
 set @defaultDate = CURRENT_TIMESTAMP        
 set @defaultDate = replace(@defaultdate,year(@defaultdate),'1900')      
-----------------------    
UPDATE eacb
SET eacb.CallbackFailures=0,
eacb.ModifiedDate=getdate(),
CallbackDate=NULL
-- SELECT eacb.* 
FROM EAPI.ExpandedApiCallback eacb INNER join (SELECT eacb.OrderNumber,MAX(eacb.ExpandedApiCallbackId)ExpandedApiCallbackId 
FROM EAPI.ExpandedApiCallback eacb 
GROUP BY eacb.OrderNumber) eacbg ON eacb.ExpandedApiCallbackId=eacbg.ExpandedApiCallbackId
inner join appl a on eacb.ordernumber=a.apno and a.clno not in (2135,3468)
WHERE (eacb.IsCallbackReady=1 AND eacb.CallbackFailures>=11)
AND eacb.ModifiedDate<(GETDATE()-1) AND eacb.CreatedDate>=(GETDATE()-30)
--and DATEDIFF(DAY,ModifiedDate,getdate())>1 AND  DATEDIFF(MONTH,eacb.CreatedDate,getdate())<=1
 --------------------- 
--Lock callback acknowledgement dates to default date      
-- so other updatecallback services do not interfere with the date      
update EAPI.ExpandedApiCallback    
 set CallbackDate = @defaultDate ,modifieddate=current_timestamp     
 --where ExpandedApiCallbackId in (select ExpandedApiCallbackId from #APICallbackTemp) 
 where IsCallbackReady=1 and CallbackDate is null and  callbackfailures < 11

 --This will prevent from duplicate updates being sent due to changes trigerred in different areas for the same order
 --Callbackfailures of 21 is the indicator that there was another update being sent at the same time service was picked up
 --SHould have been avoided at the time of entry. Look if the job can be tweaked and this relaxed
 update EAPI.ExpandedApiCallback    
 set callbackfailures=21, IsCallbackReady = 0
 Where ExpandedApiCallbackID not in (
 select max(ExpandedApiCallbackID) from eapi.ExpandedApiCallback
where   iscallbackready =1 and year(callbackdate)=1900 and  callbackfailures < 11 group by ordernumber)
and iscallbackready =1 and year(callbackdate)=1900 and  callbackfailures < 11


    
select  cb.ExpandedApiCallbackId,cb.OrderNumber,cb.IsCallbackReady,cb.CallbackFailures,cb.CallbackDate,cb.CreatedDate,cb.CreatedBy,cb.ModifiedDate      
 from EAPI.ExpandedApiCallback cb
 Where CallbackDate = @defaultDate 
 and callbackfailures < 11
      
END      
      
--EAPI.GetExpandedCallback  