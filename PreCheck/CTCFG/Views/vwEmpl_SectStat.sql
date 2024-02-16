CREATE VIEW [CTCFG].[vwEmpl_SectStat] AS 
						SELECT DISTINCT N.EmplID, O.SectStat AS Old_SectStat, N.SectStat AS New_SectStat, T.tran_end_time AS CommitDateTime, N.Investigator AS LastModifiedBy FROM PreCheck.[CDC].[dbo_Empl_CT] O INNER JOIN PreCheck.[CDC].[dbo_Empl_CT] N  ON O.EmplID = N.EmplID AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
						LEFT OUTER  JOIN [PreCheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						WHERE ISNULL(O.SectStat,'') <>  ISNULL(N.SectStat,'');