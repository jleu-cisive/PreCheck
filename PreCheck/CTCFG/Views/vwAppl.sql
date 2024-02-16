CREATE VIEW [CTCFG].[vwAppl]
 AS
 SELECT sys.fn_cdc_map_lsn_to_time(__$start_lsn) AS CommitDateTime ,
  CASE  __$operation WHEN 1 THEN 'D'
  WHEN 3 THEN 'BU'
  WHEN 4 THEN 'AU'
  ELSE 'N/A' END AS Operation
  , C.*
 FROM [cdc].[dbo_Appl_CT] C 
 WHERE __$operation IN (1,2,3,4) 
