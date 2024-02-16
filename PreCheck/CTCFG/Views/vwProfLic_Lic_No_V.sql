CREATE VIEW [CTCFG].[vwProfLic_Lic_No_V] AS 
						SELECT DISTINCT N.ProfLicID, O.Lic_No_V AS Old_Lic_No_V, N.Lic_No_V AS New_Lic_No_V, T.tran_end_time AS CommitDateTime, N.Investigator AS LastModifiedBy FROM Precheck.[CDC].[dbo_ProfLic_CT] O INNER JOIN Precheck.[CDC].[dbo_ProfLic_CT] N  ON O.ProfLicID = N.ProfLicID AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
						LEFT OUTER  JOIN [Precheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						WHERE ISNULL(O.Lic_No_V,'') <>  ISNULL(N.Lic_No_V,'');