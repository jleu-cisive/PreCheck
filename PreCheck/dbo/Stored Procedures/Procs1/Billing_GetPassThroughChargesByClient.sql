--[dbo].[Billing_GetPassThroughChargesByClient] 'employment',0
CREATE procedure [dbo].[Billing_GetPassThroughChargesByClient](@type varchar(100),@clno int)
as
declare @configkey varchar(1000)

if (@type='employment')
	set @configkey='EmplPassthroughChanges'
else if (@type = 'education')
	set @configkey='EducatAdditionalFee'
else
	select null
select Value from dbo.CLientCOnfiguration where clno = @clno and ConfigurationKey=@configkey




