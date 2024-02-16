--- batchnumber , Batchsize couluns are nullable
--[dbo].[AIMS_ReScheduleByTypeAndState]  '09/01/2017 05:00','sbm','us-ccm',' ',' '
-- Modified by Radhika Dereddy on 08/02/2021 to add the linked server to access the tables from Qreports.
CREATE procedure [dbo].[AIMS_ReScheduleByTypeAndState]
(
	@scheduletime datetime,
	@section varchar(10),
	 @licensetypeandstate  varchar(50),
	 @BatchSize varchar(300)=null,
	 @BatchNumber varchar(300)=null
)
as

declare @mappingid int
declare @scheduleid int

select top 1  @mappingid = DataXtract_RequestMappingXMLID from dbo.DataXtract_RequestMapping where sectionkeyid= @licensetypeandstate order by DataXtract_RequestMappingXMLID desc
select @scheduleid = DataXtract_AIMS_ScheduleID from dbo.DataXtract_AIMS_Schedule where Dataxtract_RequestMappingxmlid = @mappingid and refAIMS_SectionTypeCode=@section
update [ALA-SQL-05].Precheck.dbo.DataXtract_AIMS_Schedule set NextRunTime = @scheduletime,IsActive=1 where DataXtract_AIMS_ScheduleId = @scheduleid
if(NOT @BatchSize IS NULL AND @BatchSize<>'')
begin
	if not exists( select top 1 1 from dbo.AIMS_AgentParameters where AgentParamName='BatchSize' and DataXtract_RequestMappingXMLId=@mappingid)
	begin
		INSERT INTO [ALA-SQL-05].Precheck.dbo.AIMS_AgentParameters(AgentParamName,AgentParamValue,DataXtract_RequestMappingXMLId) VALUES('BatchSize',@BatchSize,@mappingid);
	end
	else
	begin
		update [ALA-SQL-05].Precheck.dbo.AIMS_AgentParameters set AgentParamValue=@BatchSize where AgentParamName='BatchSize' and DataXtract_RequestMappingXMLId=@mappingid;
	end
end


	
IF(NOT @BatchNumber IS NULL AND @BatchNumber <> '')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM AIMS_AgentParameters WHERE AgentParamName='BatchNumber' and DataXtract_RequestMappingXMLId=@mappingid)
			BEGIN
				INSERT INTO [ALA-SQL-05].Precheck.dbo.AIMS_AgentParameters(AgentParamName,AgentParamValue,DataXtract_RequestMappingXMLId) VALUES('BatchNumber',@BatchNumber,@mappingid);
			END
		ELSE 
			BEGIN
				UPDATE [ALA-SQL-05].Precheck.dbo.AIMS_AgentParameters SET AgentParamValue=@BatchNumber WHERE AgentParamName='BatchNumber' and DataXtract_RequestMappingXMLId=@mappingid; 
			END
	END
ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM AIMS_AgentParameters WHERE AgentParamName='BatchNumber' and DataXtract_RequestMappingXMLId=@mappingid)
			BEGIN
				
				DELETE FROM [ALA-SQL-05].Precheck.dbo.AIMS_AgentParameters where AgentParamName='BatchNumber' and DataXtract_RequestMappingXMLId=@mappingid;
			END
	END


select * from DataXtract_AIMS_Schedule where DataXtract_AIMS_ScheduleId = @scheduleid 
print @mappingid