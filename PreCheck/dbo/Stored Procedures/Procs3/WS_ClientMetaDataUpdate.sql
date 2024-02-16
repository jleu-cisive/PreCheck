





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[WS_ClientMetaDataUpdate] 
	@APNO int,@CLNO int,@CAPNO varchar(100),@META xml
AS
BEGIN
	
SET ARITHABORT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
DECLARE @PackageCode varchar(25),@ClientNote varchar(5000);
SELECT @ClientNote = Priv_notes from appl where apno = @APNO
if(select count(*) from applclientdata where clno = @CLNO and clientapno = @CAPNO) > 0
BEGIN
--record exists so just update it

update applclientdata set xmld = @META,updated = getdate(),apno = @APNO where clno = @CLNO and clientapno = @CAPNO;
SELECT TOP 1 @PackageCode = xmld.value('(/ClientMeta/Package_Code)[1]', 'varchar(6)')
FROM applclientdata where clientapno = @CAPNO
INSERT INTO applclientdatahistory
(apno,clientapno,packagecode,clientnote,createddate)
values
(@APNO,@CAPNO,@PackageCode,@ClientNote,getdate())

END
ELSE
BEGIN
INSERT INTO applclientdata
(apno,clno,clientapno,xmld,updated)
VALUES
(@APNO,@CLNO,@CAPNO,@META,getdate())

SELECT TOP 1 @PackageCode = xmld.value('(/ClientMeta/Package_Code)[1]', 'varchar(6)')
FROM applclientdata where clientapno = @CAPNO
INSERT INTO applclientdatahistory
(apno,clientapno,packagecode,clientnote,createddate)
values
(@APNO,@CAPNO,@PackageCode,@ClientNote,getdate())
END

COMMIT TRANSACTION;



END






