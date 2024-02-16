CREATE VIEW [CTCFG].[vwAppl_OrigCompDate] AS 
						SELECT DISTINCT N.APNO, O.OrigCompDate AS Old_OrigCompDate, N.OrigCompDate AS New_OrigCompDate, T.tran_end_time AS CommitDateTime, N.LastModifiedBy AS LastModifiedBy FROM Precheck.[CDC].[dbo_Appl_CT] O INNER JOIN Precheck.[CDC].[dbo_Appl_CT] N  ON O.APNO = N.APNO AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
						LEFT OUTER  JOIN [Precheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						WHERE ISNULL(O.OrigCompDate,'') <>  ISNULL(N.OrigCompDate,'');