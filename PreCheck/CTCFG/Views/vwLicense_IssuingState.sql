CREATE VIEW [CTCFG].[vwLicense_IssuingState] AS 
						SELECT DISTINCT N.LicenseID, O.IssuingState AS Old_IssuingState, N.IssuingState AS New_IssuingState, T.tran_end_time AS CommitDateTime, N.VerifiedBy AS LastModifiedBy FROM HEVN.[CDC].[dbo_License_CT] O INNER JOIN HEVN.[CDC].[dbo_License_CT] N  ON O.LicenseID = N.LicenseID AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
						LEFT OUTER  JOIN [HEVN].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						WHERE ISNULL(O.IssuingState,'') <>  ISNULL(N.IssuingState,'');