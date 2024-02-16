create procedure dbo.sp_ShowRequestAndCallbackStatus
(@apnos varchar(100))
as
declare @sql varchar(max)
--set @apnos = '1850417,1850043'

set @sql = 'SELECT top 10 [RequestID]
      ,omreq.[CLNO]
      ,[RequestDate]
      ,[refUserActionID]
      ,omreq.[APNO]
      --,case [Process_Callback_Acknowledge] when 0 then ''false'' when 1 then ''true'' end as [Process_Callback_Acknowledge]
      --,case [Process_Callback_Final] when 0 then ''false'' when 1 then ''true'' end as [Process_Callback_Final]
      ,[Callback_Acknowledge_Date]
      ,[Callback_Final_Date]      
	  ,[CallbackStatus]
      ,[CallbackDate]
      ,[CallbackPostResult]
      ,[CallbackError]
      ,case [CallbackCompletedStatus] when 0 then ''Failed'' when 1 then ''Passed'' else ''Not Started'' end as [CallbackCompletedStatus]
  FROM [PreCheck].[dbo].[Integration_OrderMgmt_Request] omreq (nolock)
  JOIN [PreCheck].[dbo].[Integration_CallbackLogging] cblog (nolock)
  ON omreq.APNO = cblog.APNO
where omreq.APNO in (' + @apnos + ')
ORDER BY cblog.APNO,[CallbackDate] DESC'

execute(@sql)