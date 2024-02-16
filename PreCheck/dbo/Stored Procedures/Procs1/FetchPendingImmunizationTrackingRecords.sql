CREATE  Procedure [dbo].[FetchPendingImmunizationTrackingRecords] 
@StartDate DateTime,
@EndDate DateTime


AS
BEGIN

Select distinct  a.CLNO,C.Name ClientName,CPM.Name Program,ClientPackageDesc Package,[Last],[First],DOB,a.Email,APNO,ApDate
from dbo.appl a (nolock) inner join dbo.client c (nolock) on a.clno = c.clno
						 inner join dbo.Clientconfiguration CC (nolock) on a.clno = CC.clno and ConfigurationKey = 'Notification_ImmunizationTracking_Initiate' and value = 'True'
						 left join ClientPackages CP (nolock) on a.PackageID = CP.PackageID
						 left join ClientProgram CPM (nolock) on a.ClientProgramID = CPM.ClientProgramID
Where --a.apstatus='P' and 
a.CLNO <>3668
--a.CLNO = 11118
and (a.apdate between @StartDate and @EndDate)
order by APNO


END


--[FetchPendingImmunizationTrackingRecords] '10/21/2014','10/27/2014'