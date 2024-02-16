CREATE View [CTCFG].vwCrim_CrimID
AS
SELECT DISTINCT O.APNO, O.County, O.CrimID AS OldCrimID, N.CrimID AS NewCrimID, T.tran_end_time AS CommitDateTime 
FROM Precheck.[CDC].[dbo_Crim_CT] O INNER JOIN Precheck.[CDC].[dbo_Crim_CT] N  ON O.County  = N.County AND N.__$start_lsn >= O.__$start_lsn AND O.__$operation = 1  AND N.__$operation= 2
		AND O.APNO = N.APNO  AND O.CrimID <> N.CrimID
	LEFT OUTER  JOIN [Precheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
