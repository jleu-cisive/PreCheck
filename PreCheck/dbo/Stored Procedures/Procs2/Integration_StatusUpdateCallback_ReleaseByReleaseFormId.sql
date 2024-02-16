
CREATE procedure [dbo].[Integration_StatusUpdateCallback_ReleaseByReleaseFormId]
(@releaseformid int)
as

select rfa.releaseformid,rfa.clno,ClientApno,cfi.CallBackMethod,cfi.OperationName, cast(NewTable.RequestXML.query('data(URL_Release_Callback)')  as varchar(300)) as URL_Release_Callback
into #ReleaseCallbackTemp
 from dbo.ReleaseFormAcknowledgement rfa 
 inner join [dbo].[ClientConfig_Integration] cfi 
on cfi.CLNO = rfa.CLNO 
CROSS APPLY [ConfigSettings].nodes('//ClientConfigSettings') AS NewTable(RequestXML)
where (lower(ClientApno) not like '%test%' and IsNull(clientapno,'0') <> '0' and rfa.clno not in (11726))
and rfa.ReleaseFormId = @releaseformid

--update dbo.ReleaseFormAcknowledgement set AcknowledgeDate = '1/1/1900' where ReleaseFormId in (select ReleaseFormId from #ReleaseCallbackTemp)
select ReleaseFormId,CLNO,ClientAPNO as Partner_Reference,CallBackMethod,OperationName,URL_Release_Callback from #ReleaseCallbackTemp


drop table #ReleaseCallbackTemp




































