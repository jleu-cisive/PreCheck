/****** Script for SelectTopNRows command from SSMS  ******/



CREATE procedure [dbo].[HCA_CallbackService_CheckLog]  (@clno int = 7519,@spmode int = 1,@dateref datetime = null) AS

SELECT 
      [Apno]

      ,[CallbackStatus]

      ,[CallbackDate]

FROM [PreCheck].[dbo].[Integration_CallbackLogging] (nolock) where clno =7519  and

 (callbackdate between dateadd(hour,-1,current_timestamp) and current_timestamp) and CallbackCompletedStatus=1 and [CallbackStatus] in ('Inprocess','Complete')

   order by 1 desc




