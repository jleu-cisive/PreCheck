create procedure dbo.AIMS_GetAgentParametersByMappingId(@mappingId int null)
as 
select 
	AgentParamName,AgentParamValue from [dbo].[AIMS_AgentParameters]
	where [DataXtract_RequestMappingXMLId] = @mappingid