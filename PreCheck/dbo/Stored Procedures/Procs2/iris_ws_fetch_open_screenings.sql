
CREATE PROCEDURE [dbo].[iris_ws_fetch_open_screenings]
    @screenings_type VARCHAR(10),
	@time_stamp VARCHAR(50)= NULL
AS
BEGIN
    SET NOCOUNT ON;

DROP TABLE IF EXISTS #tmpUnconfirmed
DROP TABLE IF EXISTS #tmpWaitingOrders

SELECT    vendor_type, order_key, order_status, applicant_id, screening_id, is_criminal_case_record, parent_screening_id, vendor_search_id, search_type, 
					search_qualifier, court_type, country_code, region, county, last_name, first_name, middle_name, sex, dob, ssn, last_name_1, first_name_1, 
					middle_name_1, last_name_2, first_name_2, middle_name_2, last_name_3, first_name_3, middle_name_3, last_name_4, first_name_4, 
					middle_name_4, special_instructions, txtlast, txtalias, txtalias2, txtalias3, txtalias4 into #tmpUnconfirmed
FROM         dbo.iris_ws_unconfirmed_orders 
			
SELECT   vendor_type, order_key, order_status, applicant_id, screening_id, is_criminal_case_record, parent_screening_id, vendor_search_id, search_type, 
					search_qualifier, court_type, country_code, region, county, last_name, first_name, middle_name, sex, dob, ssn, last_name_1, first_name_1, 
					middle_name_1, last_name_2, first_name_2, middle_name_2, last_name_3, first_name_3, middle_name_3, last_name_4, first_name_4, 
					middle_name_4, special_instructions, txtlast, txtalias, txtalias2, txtalias3, txtalias4 into #tmpWaitingOrders
FROM         dbo.iris_ws_waiting_orders



    IF(UPPER(@screenings_type) = 'NEW')
    BEGIN	
	
		SELECT * FROM dbo.iris_ws_new_orders (NOLOCK);

		IF @time_stamp IS NOT NULL 
		BEGIN
			UPDATE C SET InUseByIntegration = @time_stamp
			FROM Crim C INNER JOIN 	dbo.iris_ws_vendor_searches AS VS  (NOLOCK)
			ON C.CNTY_NO = VS.county_id AND C.vendorid = VS.vendor_id 
			AND  C.Clear IN ('M') AND C.InUseByIntegration IS NULL
			AND C.IsHidden = 0 -- 01/16/2019 -- [Deepak] -- Get only reportable Crim Records
		END;

		
    END 
	ELSE
    IF(UPPER(@screenings_type) = 'WAITING')
    BEGIN
        SELECT * FROM dbo.iris_ws_waiting_orders (NOLOCK);
    END ELSE
    IF(UPPER(@screenings_type) = 'UNCONFIRMED')
    BEGIN
        SELECT * FROM dbo.iris_ws_unconfirmed_orders(NOLOCK);
    END ELSE
    IF(UPPER(@screenings_type) = 'ALL')
    BEGIN
       -- SELECT * FROM dbo.iris_ws_all_orders (NOLOCK);
		SELECT * FROM #tmpUnconfirmed
		UNION ALL
		SELECT * FROM #tmpWaitingOrders
    END 
END
