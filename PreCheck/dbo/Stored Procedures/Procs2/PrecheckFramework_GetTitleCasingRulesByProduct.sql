
CREATE procedure [dbo].[PrecheckFramework_GetTitleCasingRulesByProduct]
(@productName varchar(30) = null)
as
if (@productName = null)
	set @productName = 'Any'
select RuleConfiguration from dbo.ConversionRules where IsNull(Product,'') = @productName




