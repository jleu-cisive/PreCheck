-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BG_AppLockReport]
@CLNO int, @SPMode int, @DATEREF datetime
AS
BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  

--select apno,apdate,inuse from appl with (nolock) where inuse is not null
--order by apdate asc

exec applockinuseescalation


END
