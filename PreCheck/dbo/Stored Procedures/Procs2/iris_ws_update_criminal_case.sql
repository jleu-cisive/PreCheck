CREATE PROCEDURE [dbo].[iris_ws_update_criminal_case]
    @vendor_type VARCHAR(10),
    @order_key UNIQUEIDENTIFIER,
    @applicant_id BIGINT,
    @screening_id BIGINT,
    @case_number VARCHAR(50),
    @vendor_search_id BIGINT,
    @order_status VARCHAR(35),
    @result_status VARCHAR(35),
    @degree VARCHAR(500),
    @disposition VARCHAR(500),
    --@disposed_on DATETIME,
    @disposed_on VARCHAR(20),
    @filed_on DATETIME,
    @offense VARCHAR(1000),
    @sentence VARCHAR(1000),
    @Name varchar(30),
    @DOB varchar(20),
    @SSN varchar(11),
    @Fine varchar(50),
    @Notes text
AS
DECLARE @batch_number FLOAT;
-- @ordered_on IS VARCHAR to match CRIM.ordered
DECLARE @ordered_on VARCHAR(14);
DECLARE @temp_case_number VARCHAR(14);
DECLARE @temp_filed_on DATETIME;
DECLARE @temp_degree_1 CHAR(1);
DECLARE @temp_degree_2 CHAR(1);
DECLARE @temp_offense VARCHAR(50);
DECLARE @temp_disposition VARCHAR(500);
DECLARE @temp_sentence VARCHAR(50);
DECLARE @temp_disposed_on DATETIME;
DECLARE @case_record_id BIGINT;
DECLARE @county_id BIGINT;
DECLARE @county VARCHAR(40);
DECLARE @iris_ordered DATETIME;
DECLARE @criminal_case_log_id BIGINT;
DECLARE @vendor_id INT;
DECLARE @order_id BIGINT;
DECLARE @screening_log_id BIGINT;
DECLARE @data_id BIGINT;
DECLARE @ts DATETIME;
DECLARE @iris_rec VARCHAR(3);
DECLARE @delivery_method VARCHAR(50);
DECLARE @status VARCHAR(50);
DECLARE @b_rule VARCHAR(50);
DECLARE @ready_to_send BIT;

BEGIN
    -- ensure that blanks are not substituted for NULLs
	SET @result_status = NULLIF(@result_status, '');
	SET @order_status = NULLIF(@order_status, '');
	SET @degree = NULLIF(@degree, '');
	SET @offense = NULLIF(@offense, '');
	SET @disposition = NULLIF(@disposition, '');
	SET @sentence = NULLIF(@sentence, '');
	SET @ts = GETDATE();
    SET @Name =NULLIF(@Name, '');
    SET @SSN =NULLIF(@SSN, '');
    SET @disposed_on = NULLIF(@disposed_on, '');
    SET @Fine = NULLIF(@Fine,'');
    
	SELECT
	  @case_record_id = crimid
	  FROM crim
	  WHERE parentCrimId = @screening_id
	    AND caseno = @case_number;
	    
	IF(@case_record_id IS NULL)
	BEGIN
	    SELECT
	      @county_id = cnty_no,
          @county = county,
	      @iris_ordered = irisordered,
	      @batch_number = batchnumber,
	      @vendor_id = vendorid,
          @iris_rec = iris_rec,
          @delivery_method = deliverymethod,
          @status = status,
          @b_rule = b_rule,
          @ready_to_send = readytosend
	      FROM crim
	      WHERE crimid = @screening_id;

 INSERT INTO dbo.Crim(
	      apno,
	      cnty_no,
	      vendorid,
	      batchnumber,
	      parentcrimid,
	      irisordered,
	      createddate,
	      county, -- not used by ws integration, but required
	      iscamreview, -- not used by ws integration, but required
	      ishidden, -- not used by ws integration, but required
	      ishistoryrecord, -- not used by ws integration, but required
          iris_rec,
          deliverymethod,
          status,
          b_rule,
          readytosend,
          Name,
          DOB,
          SSN, 
          Fine,   
          --Pub_Notes
		  Priv_Notes
          )VALUES(
	      @applicant_id,
	      @county_id,
	      @vendor_id,
	      @batch_number,
	      @screening_id,
	      @iris_ordered,
	      @ts,
	      @county,
	      'False',
	      'False',
	      'False',
          @iris_rec,
          @delivery_method,
          @status,
          @b_rule,
          @ready_to_send,
          LOWER(@Name),
          @DOB,
          @SSN,
          @Fine,  
          @Notes
	    );
	    
	    SET @case_record_id = @@IDENTITY;
	    
	    -- hide parent crim record
	    UPDATE crim SET
	       [clear] = 'F',
		   isHidden = 1  -- To mark the parent crim record as hidden 	
	       WHERE crimid = @screening_id;
	END 

    -- re-use exiting values, except blanks
    SELECT
		@ordered_on = C.ordered, 
		@temp_case_number = NULLIF(C.caseno, ''),
		@temp_filed_on = C.date_filed,
		@temp_degree_2 = NULLIF(C.degree, ''),
		@temp_offense = NULLIF(C.offense, ''),
		@temp_disposition = NULLIF(C.disposition, ''),
		@temp_sentence = NULLIF(C.sentence, ''),
		@temp_disposed_on = C.disp_date
    FROM crim C
    WHERE
        crimid = @case_record_id;

	SET @temp_degree_1 = CASE
        WHEN @degree = 'felony' THEN 'F'
        WHEN @degree = 'forfeiture' THEN NULL
        WHEN @degree = 'infraction' THEN NULL
        WHEN @degree = 'misdemeanor' THEN 'M'
        WHEN @degree = 'pettyOffence' THEN NULL
        WHEN @degree = 'summary' THEN NULL
        WHEN @degree = 'traffic' THEN NULL
        WHEN @degree = 'violation' THEN NULL
        WHEN @degree = 'capias' THEN NULL
        WHEN @degree = 'showCause' THEN NULL
        WHEN @degree = 'ordinanceViolation' THEN NULL
        WHEN @degree = 'sealed' THEN NULL
        WHEN @degree = 'felonyReducedToMisdemeanor' THEN 'M'
        WHEN @degree = 'misdemeanorReducedToViolation' THEN NULL
        WHEN @degree = 'unknown' THEN NULL
	    ELSE NULL
	END;

	UPDATE Crim SET
	    [clear] = 'V',
		caseno = LOWER(COALESCE(@case_number, @temp_case_number)),
		date_filed = COALESCE(@filed_on, @temp_filed_on),
		degree = COALESCE(@temp_degree_1, @temp_degree_2),
		offense = LOWER(COALESCE(@offense, @temp_offense)),
		disposition = LOWER(COALESCE(@disposition, @temp_disposition)),
		sentence = LOWER(COALESCE(@sentence, @temp_sentence)),
		disp_date = COALESCE(@disposed_on, @temp_disposed_on),
		ordered = COALESCE(@ordered_on, CONVERT(char(8), @ts, 1) + ' ' + CONVERT(char(5), @ts, 8)),
		last_updated = @ts
	  WHERE
		crimid = @case_record_id;
		
	EXECUTE dbo.[iris_ws_update_crim_private_notes]
        @crim_id = @case_record_id,
        @order_status = @order_status,
        @result_status = @result_status,
        @case_number = @case_number,
        @degree = @degree,
        @disposition = @disposition,
        @disposed_on = @disposed_on,
        @filed_on = @filed_on,
        @offense = @offense,
        @sentence = @sentence;

EXECUTE iris_ws_update_crim_priv_notes
        @crim_id = @case_record_id,
		@Is_Criminal_Case_Record = 1;
       
END

