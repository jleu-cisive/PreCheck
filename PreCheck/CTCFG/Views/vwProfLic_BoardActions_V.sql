CREATE VIEW [CTCFG].[vwProfLic_BoardActions_V] AS 
						SELECT DISTINCT N.ProfLicID, O.BoardActions_V AS Old_BoardActions_V, N.BoardActions_V AS New_BoardActions_V, T.tran_end_time AS CommitDateTime, N.Investigator AS LastModifiedBy FROM Precheck.[CDC].[dbo_ProfLic_CT] O INNER JOIN Precheck.[CDC].[dbo_ProfLic_CT] N  ON O.ProfLicID = N.ProfLicID AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
						LEFT OUTER  JOIN [Precheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						WHERE ISNULL(O.BoardActions_V,'') <>  ISNULL(N.BoardActions_V,'');