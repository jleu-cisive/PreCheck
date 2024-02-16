

--EXEC Precheck.[dbo].[ClientCertDetails_byAPNO] 3057084
-- EXEC Precheck.[dbo].[ClientCertDetails_byAPNO_NEW] 3220814

-- =============================================
-- Author:		<Prasanna>
-- Create date: <11/05/2015>
-- Description:	Client Certification Details by APNO
-- =============================================
CREATE PROCEDURE [dbo].[ClientCertDetails_byAPNO_NEW]
    @apno int
AS
BEGIN

	select 
		a.APNO,
		a.First,
		a.Last,
		case when IsNull(ClientCertReceived,'') = '' then 'No' else ClientCertReceived end as Received,
		case when IsNull(ClientcertBy,'') = '' then 'N/A' else ClientCertBy end as CertifiedBy,
		case when IsNull(ClientCertUpdated,'') = '' then null else ClientCertUpdated end as UpdatedOn 
	from dbo.Appl a
	left join dbo.ClientCertification c on a.Apno = c.apno
	where a.apno = @apno

END

