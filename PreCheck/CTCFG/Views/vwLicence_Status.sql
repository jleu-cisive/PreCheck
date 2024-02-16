 CREATE VIEW [CTCFG].[vwLicence_Status]
 AS
 SELECT DISTINCT N.LicenseID, O.Status AS Old_Status, N.Status AS New_Status, T.tran_end_time AS CommitDateTime, N.ReviewedBy AS LastModifiedBy
 FROM HEVN.[cdc].[dbo_License_CT] O INNER JOIN HEVN.[cdc].[dbo_License_CT] N
 ON O.LicenseID = N.LicenseID AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
LEFT OUTER  JOIN HEVN.cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
WHERE O.Status <> N.Status
