
CREATE PROCEDURE [dbo].[iris_outgoing_records]
    @crim_id int
AS
BEGIN 
	SELECT C.Priv_Notes,
	/*
		 (CASE clear
			WHEN 'E' THEN (SELECT TOP 1 D.data
                FROM iris_ws_log L 
                INNER JOIN iris_ws_log_data D ON D.id = L.data_id
                INNER JOIN iris_ws_screening SCR ON (SCR.id = L.entity_id)
                WHERE (UPPER(L.entity_name) = 'SCREENING')
                  AND (L.log_item_type LIKE '%ERROR%')
                  AND (SCR.crim_id = @crim_id)
                ORDER BY L.created_on DESC)
			ELSE NULL
		END) AS ws_message,
		*/
		 (CASE clear
			WHEN 'E' THEN (SELECT TOP 1 LTRIM(RTRIM(CAST(D.data as varchar(100))))
							FROM iris_ws_log L 
							INNER JOIN iris_ws_log_data D ON D.id = L.data_id
							INNER JOIN iris_ws_screening SCR ON (SCR.id = L.entity_id)
							WHERE (UPPER(L.entity_name) = 'SCREENING')
							  AND (L.log_item_type LIKE '%ERROR%')
							  AND (SCR.crim_id = @crim_id)
							ORDER BY L.created_on DESC)/*'This represents an error message from a vendor.'*/
			ELSE NULL
		END) AS ws_message,
		 crim_specialinstr,
		 (CASE clear
			WHEN 'F' THEN 'Record Found'
			WHEN 'T' THEN 'Clear'
			WHEN 'P' THEN 'Possible Record Found'
			WHEN 'O' THEN 'Ordered'
			WHEN 'R' THEN 'Pending to be Ordered'
			WHEN 'W' THEN 'Waiting for Results'
			WHEN 'X' THEN 'Error Getting Results'
			WHEN 'E' THEN 'Error Sending Order'
			WHEN 'M' THEN 'Ordering'
			WHEN 'V' THEN 'Vendor Reviewed'
			WHEN 'N' THEN 'Alias Name Ordered'
			WHEN 'I' THEN 'Needs Research'
			WHEN '' THEN 'Needs Review'
			ELSE ''
		END) AS clear
	FROM crim C
	WHERE C.crimid = @crim_id;
END

