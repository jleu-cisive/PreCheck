
CREATE procedure [dbo].[DataXtract_Mapping_UpsertBySectionKeyId]
(@insertFlag bit,
 @SectionKeyId varchar(50),
 @Section varchar(50),
 @RequestMappingXml varchar(max))
as 
begin

if (@insertFlag = 1)
	begin
		insert into 
			DataXtract_RequestMapping (SectionKeyID,Section,RequestMappingXML) 
		values 
			(@SectionKeyId,@Section,@RequestMappingXml)
	end
else
	begin
		Update 
			DataXtract_RequestMapping 
		Set 
			RequestMappingXML = @RequestMappingXml,
			Section = @Section
		Where
			SectionKeyId = @SectionKeyId
	end
end
