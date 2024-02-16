CREATE VIEW [CTCFG].[vwAppl_Name]
 AS
SELECT DISTINCT N.APNO, O.[First] AS Old_Fname, N.[First] AS New_FName,
O.[Last] AS Old_Lname, N.[Last] AS New_LName, 
O.[Middle] AS Old_Middle ,N.[Middle] AS New_MName, 
T.tran_end_time AS CommitDateTime, N.LastModifiedBy
 FROM [cdc].[dbo_Appl_CT] O INNER JOIN [cdc].[dbo_Appl_CT] N
 ON O.APNO = N.APNO AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
LEFT OUTER  JOIN cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
WHERE (O.[Last] <> N.[Last] OR O.[First] <> N.[First] OR ISNULL(O.Middle,'') <> ISNULL(N.Middle,''))

