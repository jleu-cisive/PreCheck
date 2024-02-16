-- Alter Procedure temp_load_iris_ws_vendor_searches
CREATE PROCEDURE [dbo].[temp_load_iris_ws_vendor_searches]
    @vendor_id BIGINT,
    @county_id BIGINT,
    @search_type_qualifier VARCHAR(35),
    @court_type VARCHAR(35),
    @vendor_type VARCHAR(35),
    @country_code CHAR(2),
    @region VARCHAR(50),
    @county VARCHAR(35)
AS
DECLARE @temp_vendor_name VARCHAR(35);
BEGIN
    SET @temp_vendor_name = CASE
      WHEN @vendor_type = 'omnidata%' THEN 'omnidata%'
      ELSE @vendor_type
    END
    
	SELECT
        R.r_id AS vendor_id,
        C.cnty_no AS county_id,
		@search_type_qualifier,
		@court_type,
		(SELECT id FROM iris_ws_vendor_type WHERE code LIKE @vendor_type) AS vendor_type_id,
		@country_code,
		@region,
		@county
        FROM dbo.TblCounties C
            INNER JOIN iris_researcher_charges RC ON C.cnty_no = RC.cnty_no
            INNER JOIN iris_researchers R ON RC.researcher_id = R.r_id
        WHERE R.r_id = @vendor_id
          AND C.cnty_no = @county_id;
END
