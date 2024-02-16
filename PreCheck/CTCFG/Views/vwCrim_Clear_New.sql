
CREATE VIEW [CTCFG].[vwCrim_Clear_New] AS 
WITH CTE_CRIM AS
(SELECT  Clear  As NewValue , LAG(Clear,1) OVER ( PARTITION BY CrimID, APNO ORDER BY sys.fn_cdc_map_lsn_to_time(N.__$start_lsn)) OLDValue,
 sys.fn_cdc_map_lsn_to_time(N.__$start_lsn) AS tran_end_time , N.*  FROM [PRECHECK].[cdc].[dbo_Crim_CT] N --LEFT OUTER  JOIN [Precheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						  --WHERE APNO = 5134020   AND CrimID = 34424353
)
SELECT CrimID, OLDValue AS Old_Clear, NewValue AS New_Clear, tran_end_time AS CommitDateTime, APNO AS LastModifiedBy
 FROM CTE_CRIM WHERE ISNULL(NewValue,'') <> ISNULL(OLDValue,'')
