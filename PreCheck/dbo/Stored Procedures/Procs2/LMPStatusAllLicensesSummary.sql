--dbo.LMPStatusAllLicensesSummary 7519
CREATE procedure [dbo].[LMPStatusAllLicensesSummary]
(
	@clientid int = null
)
as
--declare @clientid int = 2569
SELECT 
	ref.Status,
	count(1) as StatusCount 
FROM 
	[HEVN].dbo.license l inner join  [HEVN].dbo.Employeerecord E on l.ssn = e.ssn and l.employer_id = e.employerid and enddate is null
	inner join [HEVN].dbo.vwclients v on e.employerid = v.ItemValue
	inner join [HEVN].dbo.refCredentialStatus ref 	on l.CredentialingStatus = ref.refCredentialStatusID 
	inner join [HEVN].dbo.Licensetype lt on l.licensetypeid = lt.licensetypeid and lt.IsCredentiable = 1 
  Where
              (l.[Employer_ID] = @ClientID or IsNull(@ClientID, 0) = 0)
              and
              l.[DoNotCredential] = 0
              and 
              l.[DuplicateLicense] = 0
              and 
              (
                     l.[CredentialingStatus] is null or
                     (
                           l.[CredentialingStatus] <> 5 --DoNotCredential
                           and
                           l.[CredentialingStatus] <> 9 --NonCredentiable
                           and
                           l.[CredentialingStatus] <> 10 --No Longer In Force
                           and
                           l.[CredentialingStatus] <> 15 --Dormant 
                           and
                l.[CredentialingStatus] <> 16 --termed employee license
                           and 
                           l.[CredentialingStatus] <> 17 --not In Client File
                     )
              )
group by ref.Status

