create procedure dbo.AIMS_ChangeAutomationByVendorId
(@VendorId int,
@Automate bit)
as 
update dbo.DataXtract_RequestMapping
set IsAutomationEnabled=IsNull(@Automate,0) where DataXtract_RequestMappingXMLID in
(SELECT map.[DataXtract_RequestMappingXMLID] from DataXtract_RequestMapping map inner join 
[dbo].[DataXtract_AIMS_Schedule] sched on sched.DataXtract_RequestMappingXMLID = map.DataXtract_RequestMappingXMLID
where sched.VendorAccountId=@VendorId)