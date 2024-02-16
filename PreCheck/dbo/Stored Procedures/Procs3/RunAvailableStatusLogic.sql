











-- =============================================
-- Author:		Kiran Miryala	
-- Create date: 7/22/2011
-- Description:	<To update Integration_OrderMgmt_Request table with required status>
--
--
--===================================================
CREATE PROCEDURE [dbo].[RunAvailableStatusLogic]
	@apno int
AS
BEGIN
	SET NOCOUNT OFF;

DECLARE @ApStatus char(1),@CLNO int;


SET @CLNO = (select clno from appl where apno = @apno);







--SET @apno =  @apno
SELECT @ApStatus = Apstatus FROM appl WHERE apno = @apno



IF( @ApStatus = 'W')
BEGIN


--Checks to see if an integration client needs a callback when app is finaled and marks it accordingly for winservice to callback with the link to the report
--KMiryala 11/11/2010
--if ((SELECT  isnull(URL_CallBack_Final,'') FROM ClientConfig_Integration where  CLNO  = @CLNO) <> '')
--	BEGIN
			update DBO.Integration_OrderMgmt_Request
			set   Process_Callback_Final = 1,
				  Callback_Final_Date = null
			
			where apno =  @Apno 
	--END
	
END

END












