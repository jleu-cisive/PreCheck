CREATE procedure dbo.Cleanup_ResetRPOrders
as
declare @count int
set @count = 0

set @count = (select count(EmplId) from dbo.Empl where DateOrdered = '1/1/1900' and Investigator = 'REFPRO' and SectStat='9' and Web_status = 0)
if (@count > 0)
Begin
	print 'Resetting Orders'
	update dbo.Empl set dateOrdered = null where EmplId in (
		select EmplId from dbo.Empl where DateOrdered = '1/1/1900' and Investigator = 'REFPRO' and SectStat='9' and Web_status = 0
		)
	print 'Done resetting ' + cast(@count as varchar(30)) + ' order(s)'
End