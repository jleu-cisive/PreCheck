-- =============================================
-- Author:		Suchitra Yellapantula
-- Create date: 5/11/2017
-- Description:	Gets all the reports which were certified within the input date range (for Q-Report requested through HDT# 15102)
-- Execution: exec CertifiedReports_ByDateRange '4/4/2017','4/8/2017'
-- Modified By: Radhika Dereddy on 07/26/2017 Added a new column for affiliate
-- =============================================
CREATE PROCEDURE [dbo].[CertifiedReports_ByDateRange]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select CC.APNO,CC.ClientCertUpdated [CertifiedDate],A.CLNO,C.Name [Client Name], rf.Affiliate, rf.AffiliateID, isnull(CC.ClientCertBy,'') [Certifier]
from ClientCertification CC (nolock)
inner join Appl A (nolock) on A.Apno = CC.APNO
inner join Client C (nolock) on C.CLNO = A.CLNO
inner join refAffiliate Rf on Rf.AffiliateID = C.AffiliateID
where CC.ClientCertReceived='Yes'
and CC.ClientCertUpdated>@StartDate and CC.ClientCertUpdated<dateadd(day,1,@EndDate)
order by CC.ClientCertUpdated asc

END
