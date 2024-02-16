
--	[AIMS_LMP_Total_clear_exceptions] 9,2016
CREATE PROCEDURE [dbo].[AIMS_LMP_Total_clear_exceptions] 

@Month Int,
@year Int 

AS


SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT      
  CAST(DateLogResponse AS DATE) DateLogResponse,Section
                      
						, sum(Total_Records) totalrecords,sum(Total_Clears) Total_Clears,sum(Total_Exceptions) Total_Exceptions
FROM            DataXtract_Logging with (NOLOCK)

where Section <> 'Crim' 
and  month(DateLogResponse) = @month
and year(DateLogResponse) = @year
and Total_Records > 0
group by CAST(DateLogResponse AS DATE),Section
order by CAST(DateLogResponse AS DATE),Section


--drop table #tempDataXtract_Logging
--drop table #tempDataXtract_Logging_Nodata
--drop table #tempDataXtract_Logging_ZeroRecords
--drop table #tempDataXtract_Logging_Errors
--drop table #tempDataXtract_Logging_NoErrors
-- --Drop table #tempDataXtract_Logging_Nursys
--  Drop table #tempDataXtract_Logging_NursysGroup


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT Off;



