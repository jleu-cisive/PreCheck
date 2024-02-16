CREATE Procedure Integration_Callback_ActivityReport (@IntegrationCLNO int = 7519,@TimeLapseInHours int = 12) AS
Select 'Completed' FileType, A.APNO [Report Number],Apdate [Report Date],First [First Name], Last [Last Name],Case ApStatus When 'W' then 'Available' When 'F' then 'Completed' when 'M' then 'OnHold' else 'InProgress' end [Report Status], OrigCompDate [Original Completion Date],Callback_Final_Date [Callback Final Date],
IsNull(transformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') ProcessLevel,IsNull(transformedRequest.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),'') [Requisition Number]
from Appl A (NoLock) Inner Join integration_orderMGMT_Request R (NoLock) on A.Apno = R.Apno and R.CLNO =@IntegrationCLNO
LEFT JOIN HEVN.dbo.Facility F (nolock) ON IsNull(transformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum and parentemployerid = @IntegrationCLNO and Isnull(IsOneHR,0) =  1
Where isnull(OrigCompDate,'1/1/1900') > DateAdd(hh,-@TimeLapseInHours,current_timestamp)

Select 'Completed_Status_Updates' FileType, A.APNO [Report Number],Apdate [Report Date],First [First Name], Last [Last Name],Case ApStatus When 'W' then 'Available' When 'F' then 'Completed' when 'M' then 'OnHold' else 'InProgress' end [Report Status], OrigCompDate [Original Completion Date],CompDate [Latest ReCompletion Date],Callback_Final_Date [Callback Final Date],
IsNull(transformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') ProcessLevel,IsNull(transformedRequest.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),'') [Requisition Number]
 from Appl A (NoLock) Inner Join integration_orderMGMT_Request R (NoLock) on A.Apno = R.Apno and R.CLNO =@IntegrationCLNO
LEFT JOIN HEVN.dbo.Facility F (nolock) ON IsNull(transformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum and parentemployerid = @IntegrationCLNO and Isnull(IsOneHR,0) =  1
Where isnull(Callback_Final_Date,'1/1/1900')  >= DateAdd(hh,-@TimeLapseInHours,current_timestamp)



