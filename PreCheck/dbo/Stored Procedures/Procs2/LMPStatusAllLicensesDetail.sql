
--dbo.LMPStatusAllLicensesDetail 2569
CREATE procedure dbo.LMPStatusAllLicensesDetail
(@clientid int = null)
as
-- 242651
;With LicData as (
       Select 
              -- count(*) 
              --/*
              --top 100
			  l.Employer_ID as [Client Number],
			  c.Name as [Client Name],
			  Replace(Replace(Replace(er.[Last], char(9), ' '), char(10), ''), char(13), '') [Last Name],
              Replace(Replace(Replace(er.[First], char(9), ' '), char(10), ''), char(13), '') [First Name],
              Replace(Replace(Replace(er.[Middle], char(9), ' '), char(10), ''), char(13), '') [Middle Name],
			   Replace(Replace(Replace(er.[EmployeeNumber], char(9), ' '), char(10), ''), char(13), '') [Employee ID],
              l.[LicenseID] [LicenseID],
			  clt.LicenseDescription as [Client License Type],
			  lt.ItemValue as [License Type],  
			  Replace(Replace(Replace(l.[IssuingState], char(9), ' '), char(10), ''), char(13), '') [License State], 
			  Replace(Replace(Replace(l.[Number], char(9), ' '), char(10), ''), char(13), '') [License Number],            
			  cs.[Status] as  [Credentialing Status]
             -- IsNull(cat.[Category], '') [Category],
              --Replace(Replace(Replace(lt.[ItemValue], char(9), ' '), char(10), ''), char(13), '') [LMP Type],
              --Replace(Replace(Replace(l.[Type], char(9), ' '), char(10), ''), char(13), '') [Client Type],          
              --Replace(Replace(Replace(l.[IssuingAuthority], char(9), ' '), char(10), ''), char(13), '') [Issuing Authority],
              --case when IsNull(l.Lifetime , 0 )= 0 then 'N' else 'Y' end [LifeTime],
              --Replace(Replace(Replace(l.[Status], char(9), ' '), char(10), ''), char(13), '') [License Status],
            
              --l.[RecordDate], 
              --l.[ExpiresDate],
              --l.[PreviousExpiresDate],
              --case when l.CredentialingStatus=4 then l.[VerifiedDate] else null end [VerifiedDate],
              --l.[VerifiedBy]
              --*/
       From 
             [HEVN]..[License] l
              join[HEVN]..[EmployeeRecord] er on er.SSN=l.SSN and er.EmployerID=l.Employer_ID -- should we have used employerrecordid instead or add facilityid maybe?
              left outer join[HEVN]..[LicenseType] lt on l.[LicenseTypeID] = lt.[LicenseTypeID] 
              left outer join[HEVN]..[refCredentialStatus] cs on cs.[refCredentialStatusID] = l.[CredentialingStatus]
              left outer join[HEVN]..[LicenseCategory_ByTypeByState] lc on lc.[IsActive]=1 and lc.[LicenseState]=l.[IssuingState] and lc.[LicenseTypeID]=l.[LicenseTypeID]
              left outer join[HEVN]..[refCategory] cat on cat.[CategoryID] = lc.[CategoryID]
              left outer join[HEVN]..[ClientLicenseType] clt on l.[ClientLicenseTypeID] = clt.[ClientLicenseTypeID]
			  inner join dbo.Client c on l.Employer_ID = c.CLNO
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
              and 
              er.[EndDate] is null
              -- The next section might be overkill ?
              and
              (lt.[IsNeverCredentiable] is null or lt.[IsNeverCredentiable]=0)
              and 
              (
                     (clt.[IsCredentiable]=1)
                     or
                     (clt.[IsCredentiable] is null and (lt.[IsCredentiable] is null or lt.[IsCredentiable] = 1))
              )
       )
       select 
              l.*,
              case 
                     when mn.[LastCheckDate] is null and au.[LastCheckDate] is null then null
                     when mn.[LastCheckDate] is null then au.[LastCheckDate]
                     when au.[LastCheckDate] is null then mn.[LastCheckDate]
                     when mn.[LastCheckDate] > au.[LastCheckDate] then mn.[LastCheckDate]
                     else au.[LastCheckDate]
              end [Last Date of Activity],
              case 
                     when mn.[LastCheckDate] is null and au.[LastCheckDate] is null then null
                     when mn.[LastCheckDate] is null then au.[LastCheckMadeBy]
                     when au.[LastCheckDate] is null then mn.[LastCheckMadeBy]
                     when mn.[LastCheckDate] > au.[LastCheckDate] then mn.[LastCheckMadeBy]
                     else au.[LastCheckMadeBy]
              end [Investigator or Queue/Status],
              case 
                     when mn.[LastCheckDate] is null and au.[LastCheckDate] is null then null
                     when mn.[LastCheckDate] is null then au.[LastCheckStatus]
                     when au.[LastCheckDate] is null then mn.[LastCheckStatus]
                     when mn.[LastCheckDate] > au.[LastCheckDate] then mn.[LastCheckStatus]
                     else au.[LastCheckStatus]
              end [Last Checked Status]
       From
              LicData l left outer join
              (
                     Select 
                           [LicenseId],
                           [CreatedDate] [LastCheckDate],
                           'Automation' [LastCheckMadeBy],
                           [AuditFlag] [LastCheckStatus] 
                     from
                          [HEVN]..[CredentCheck_LicStg_log] AuFiltOut
                           join 
                                  (
                                         select 
                                                max([LicStgLogId])  [LicStgLogId]
                                         From
                                               [HEVN]..[CredentCheck_LicStg_log]
                                         where 
                                                [LicenseId] in (select distinct LicenseId From LicData)
                                         group by
                                                [LicenseId]
                                  ) AuFiltIn on AuFiltIn.[LicStgLogId] = AuFiltOut.[LicStglogID]
                     
              ) au on au.[Licenseid] = l.[LicenseId]
              left outer join
              (
                     Select
                           [TableID] [LicenseId],
                           [TimeClose] [LastCheckDate],
                           'Manual' [LastCheckMadeBy],
                           [Status] [LastCheckStatus]
                     From
                          [HEVN]..[LicenseMeasurement] MnFiltOut
                           join
                                  (
                                         Select 
                                                max([LicenseMeasurementId]) [LicenseMeasurementId]
                                         from 
                                               [HEVN]..[LicenseMeasurement] 
                                         where
                                                [TableName] = 'License' 
                                                and
                                                [TableID] in (Select distinct LicenseID from LicData)
                                         group by
                                                [TableId]     
                                  ) MnfiltIn on MnfiltIn.[LicenseMeasurementId] = MnFiltOut.[LicenseMeasurementID]
              ) mn on mn.[LicenseId] = l.[LicenseId]
