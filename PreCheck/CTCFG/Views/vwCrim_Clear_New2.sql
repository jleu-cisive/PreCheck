 
CREATE VIEW [CTCFG].[vwCrim_Clear_New2] AS 
WITH CTE_CRIM AS
(SELECT  distinct  Clear  As NewValue , LAG(Clear,1) OVER ( PARTITION BY CrimID, APNO ORDER BY T.tran_end_time) OLDValue,
  T.tran_end_time , N.CrimID,N.APNO,N.__$start_lsn,N.__$operation  FROM [PRECHECK].[cdc].[dbo_Crim_CT] N LEFT OUTER  JOIN [Precheck].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
--    WHERE APNO = 5134499   AND CrimID = 34427709
--	AND tran_end_time = '2020-05-04 09:21:22.480'
)
SELECT  distinct CrimID, OLDValue AS Old_Clear, NewValue AS New_Clear, tran_end_time AS CommitDateTime, APNO AS LastModifiedBy
 FROM CTE_CRIM WHERE ISNULL(NewValue,'') <> ISNULL(OLDValue,'')