
CREATE procedure [dbo].[PrecheckFramework_GetRulesByProduct]
(@productName varchar(30) = null,
 @ruleName varchar(40))
as
if (@productName = null)
	set @productName = 'Any'
select RuleConfiguration from dbo.ConversionRules where IsNull(Product,'') = @productName and IsNull(RuleName,'') = @ruleName




