

--EXEC Precheck.[dbo].[ClientCertDetails_byAPNO] 4085908
-- EXEC Precheck.[dbo].[ClientCertDetails_byAPNO_NEW] 3057084

-- =============================================
-- Author:		<Prasanna>
-- Create date: <11/05/2015>
-- Description:	Client Certification Details by APNO

-- Modified Author:		<Doug>
-- Updated date: <04/27/2016>
-- Description:	Added a left join to show applicants that are not in the client certification table, but have already created a report

-- Modified By - Radhika Dereddy on 04/19/2018
-- Jennifer wants the ClientCertUpdated datetime to display  in mm/dd/yyyy hh:mm:ss.fff tt (milliseconds as well)

-- =============================================
CREATE PROCEDURE [dbo].[ClientCertDetails_byAPNO]
    @apno int
AS
BEGIN

	select 
		a.APNO,
		a.First,
		a.Last,
		case when IsNull(ClientCertReceived,'') = '' then 'No' else ClientCertReceived end as Received,
		case when IsNull(ClientcertBy,'') = '' then 'N/A' else ClientCertBy end as CertifiedBy,
		case when IsNull(ClientCertUpdated,'') = '' then null else FORMAT(ClientCertUpdated , 'MM/dd/yyyy HH:mm:ss.fff tt') end as ClientCertUpdatedOn 
	from dbo.Appl a
	left join dbo.ClientCertification c on a.Apno = c.apno
	where a.apno = @apno

END

