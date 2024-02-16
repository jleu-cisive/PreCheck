-- Alter Procedure rptAIMS_ShowMappingsByAutomationFlag
--dbo.rptAIMS_ShowMappingsByAutomationFlag 1


CREATE procedure dbo.rptAIMS_ShowMappingsByAutomationFlag
@isautomated bit = 1,
@section varchar(50) = 'License'
AS
select mapping.Section,mapping.SectionKeyID,c.County,mapping.RequestMappingXML 
from dbo.DataXtract_RequestMapping mapping left join dbo.TblCounties c on mapping.SectionKeyID = cast(c.CNTY_NO as varchar(10))
where IsAutomationEnabled = @isautomated and mapping.Section = @section  order by 1 desc
