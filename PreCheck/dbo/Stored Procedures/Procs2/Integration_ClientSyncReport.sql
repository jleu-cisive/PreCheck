-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Integration_ClientSyncReport]
@CLNO int, @SPMode int, @DATEREF datetime
AS
BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  


select a.apno,ac.apno,ac.xmld from appl a left join applclientdata ac on a.apno = ac.apno
where a.apstatus ='F' and a.clno = 6977
and (ac.lastsyncutc is null  or ac.apno is null)



END
