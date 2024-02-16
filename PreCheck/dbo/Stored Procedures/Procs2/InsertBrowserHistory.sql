
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[InsertBrowserHistory]
  @AppName Varchar(50),
  @Browser varchar(200)
  --,@AppBrowserID int OUTPUT
as
  set nocount on
DECLARE @Date as DateTime  

set @Date = GETDATE();
  insert into BrowserHistory (AppName, Browser,startDate)
  values (@AppName, @Browser,@Date)
  --select @AppBrowserID = @@Identity
--return (0)
Select AppBrowserID from BrowserHistory
where AppName=@AppName and Browser = Browser and startDate = @Date
