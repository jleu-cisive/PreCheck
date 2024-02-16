--[dbo].[AIMS_ShowMozendaProgressByStatus] 'Done',null
CREATE procedure [dbo].[AIMS_ShowMozendaProgressByStatus]
(@status varchar(100) = '',@aimsjobid int = 0)
as 

select AIMS_StatusUpdateId,map.SectionKeyID,Mozenda_JobKey,Mozenda_JobStatus,IsProcessed,ProcessedDate,SearchOrderId,AimsJobItemId,DataXtract_LoggingId, AIMSSTatusUpdateDate,BatchID,AIMS_StatusUpdateCreatedDate,CleanUpDate from dbo.AIMS_StatusUpdate asu inner join dbo.DataXtract_RequestMapping map on asu.AIMS_MappingId = map.DataXtract_RequestMappingXMLID
where map.IsAutomationEnabled = 1 and 
(COALESCE(@status,Mozenda_JobStatus) = Mozenda_JobStatus or @Status = '') and (AimsJobItemId=@aimsjobid or @aimsjobid = 0)
--and COALESCE(@aimsjobid,AIMSJobItemId) = AimsJobItemId 
order by AIMS_StatusUpdateCreatedDate desc

