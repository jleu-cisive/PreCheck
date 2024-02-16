CREATE procedure dbo.AIMS_GetMappingBySectionKeyId(@sectionkeyid varchar(30) null)
as
select top 1 
	IsNull(RequestMappingXml,'') as RequestMappingXml,
	DataXtract_RequestMappingXMLID as MappingId
  from 
	DataXtract_RequestMapping where SectionKeyID = @sectionkeyid 
order by DataXtract_RequestMappingXMLID desc