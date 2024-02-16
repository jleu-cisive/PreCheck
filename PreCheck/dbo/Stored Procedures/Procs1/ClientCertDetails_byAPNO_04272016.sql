

--EXEC Precheck.[dbo].[ClientCertDetails_byAPNO] 3057084

-- =============================================
-- Author:		<Prasanna>
-- Create date: <11/05/2015>
-- Description:	Client Certification Details by APNO
-- =============================================
CREATE PROCEDURE [dbo].[ClientCertDetails_byAPNO_04272016]
    @apno int
AS
BEGIN

	select APNO,ClientCertReceived,ClientcertBy,ClientCertUpdated from ClientCertification
	where apno = @apno

END

