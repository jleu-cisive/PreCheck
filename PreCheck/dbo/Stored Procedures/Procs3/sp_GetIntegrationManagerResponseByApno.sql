--declare @repornumber int = 4854722
--sp_GetIntegrationManagerResponseByApno 4854722

CREATE procedure sp_GetIntegrationManagerResponseByApno
(@ReportNumber int
)
as
SELECT 
	data_id 
INTO 
	#tmpDataIds 
FROM 
	iris_ws_log wsl inner join iris_ws_order wso 
ON 
	wsl.entity_id= wso.id
WHERE 
	applicant_id = @ReportNumber
  -- where entity_id in (select id from iris_ws_order where applicant_id = @repornumber)

SELECT 
	ld.*
FROM 
	iris_ws_log_data ld inner join #tmpDataIds td 
ON 
	ld.id = td.data_id
where id > 100
drop table #tmpDataIds