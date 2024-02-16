create procedure dbo.usp_WS_GetXlateClno(@clno int)
as
declare @clnoOut int
SELECT @clnoOut = CLNOOut FROM XlateCLNO WHERE CLNOIn=@clno and CLNOOut IN (2135)
if (@clnoOut is null)
	set @clnoOut = 2135
select @clnoOut as CLNOOut