--[dbo].[GetClientAccountLevelAverageTAT] 12771
CREATE PROCEDURE [dbo].[GetClientAccountLevelAverageTAT] --12771
@clno int
AS

DECLARE @TAT varchar(10)

select @TAT = convert(varchar(10), TAT) from ApplSectionsTAT where KeyID=@clno

IF @TAT = '0' OR @TAT = '' OR @TAT IS null

BEGIN
--SELECT Value,  FROM ClientConfiguration WHERE ConfigurationKey = 'ClientAccess_No_Recent_History_Blurb' AND CLNO = 0
SELECT [ClientAccess_No_Recent_History_Blurb], [ClientAccess_TAT_Blurb],
(SELECT Value FROM ClientConfiguration WHERE (ConfigurationKey = 'Client_Avg_TAT_Display_In_Client_Access' AND CLNO = @clno)) AS HasTAT
FROM (
SELECT ConfigurationKey, Value
FROM ClientConfiguration WHERE (ConfigurationKey = 'ClientAccess_No_Recent_History_Blurb' OR ConfigurationKey = 'ClientAccess_TAT_Blurb') AND CLNO = 0) AS SourceTable
PIVOT (Max(Value) FOR  ConfigurationKey IN ([ClientAccess_No_Recent_History_Blurb],[ClientAccess_TAT_Blurb])
) AS PIVOTTable


END

ELSE 

SELECT @TAT + ' business days' AS [ClientAccess_No_Recent_History_Blurb], Value AS [ClientAccess_TAT_Blurb],
(SELECT Value FROM ClientConfiguration WHERE (ConfigurationKey = 'Client_Avg_TAT_Display_In_Client_Access' AND CLNO = @clno)) AS HasTAT
FROM ClientConfiguration WHERE ConfigurationKey = 'ClientAccess_TAT_Blurb' AND CLNO = 0
