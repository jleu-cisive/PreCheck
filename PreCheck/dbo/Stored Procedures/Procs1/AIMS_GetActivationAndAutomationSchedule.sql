CREATE procedure dbo.AIMS_GetActivationAndAutomationSchedule

(@sectionkeyid varchar(30) = null,
@isscheduled bit = null,
@isautomated bit = null,
@section varchar(30) = null)
as
select SectionKeyID as LicenseTypeAndState,case when va.VendorAccountId = 4 then 'All' else refAIMS_SectionTypeCode end as Section,sch.NextRunTime,case when IsNull(sch.IsActive,0) = 1 then 'Yes' else 'No' end as IsScheduled,case when isNull(map.IsAutomationEnabled,0) = 1 then 'Yes' else 'No' end as IsAutomated,va.VendorAccountName  from dbo.DataXtract_AIMS_Schedule sch 
inner join dbo.DataXtract_RequestMapping map on sch.DataXtract_RequestMappingXMLId = map.DataXtract_RequestMappingXMLID
inner join dbo.VendorAccounts va on va.VendorAccountid = sch.VendorAccountId
where map.SectionKeyID = COALESCE(@sectionkeyid,map.SectionKeyID) and 
map.IsAutomationEnabled = COALESCE(@isautomated,map.IsAutomationEnabled) and
sch.IsActive = COALESCE(@isscheduled,sch.IsActive) and
sch.refAIMS_SectionTypeCode = COALESCE(@section,sch.refAIMS_SectionTypeCode) 
order by LicenseTypeAndState 