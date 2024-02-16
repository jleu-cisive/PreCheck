
--[dbo].[SP_GetReleaseItemsByPartnerRef] 9379,'17689528'
CREATE procedure [dbo].[SP_GetReleaseItemsByPartnerRef]
(@clno int,@partnerref varchar(100))
as

select rfa.releaseformid,rfa.CLNO,ClientApno,cfi.CallBackMethod,cfi.OperationName, cast(NewTable.RequestXML.query('data(URL_Release_Callback)')  as varchar(300)) as CallBack_URL
 from dbo.ReleaseFormAcknowledgement rfa 
 inner join [dbo].[ClientConfig_Integration] cfi 
on cfi.CLNO = rfa.CLNO 
CROSS APPLY [ConfigSettings].nodes('//ClientConfigSettings') AS NewTable(RequestXML)
where AcknowledgeDate is null  and (lower(ClientApno) not like '%test%' and IsNull(clientapno,'0') <> '0' and rfa.clno not in (11726))
and rfa.CLNO = @clno and rfa.ClientApno = @partnerref








































