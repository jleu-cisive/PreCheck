CREATE PROCEDURE [dbo].[iris_ws_add_criminal_case]
   @vendor_id bigint,
    @batch_id bigint,
    @applicant_id bigint,
    @screening_id bigint,
    @order_status varchar(35),
    @result_status varchar(35),
    @case_no bigint,
    @degree varchar(35),
    @disposition varchar(500),
    @disposed_on datetime,
    @filed_on datetime,
    @fine varchar(35),
    @offense varchar(1000),
    @sentence varchar(1000)
AS
SET NOCOUNT OFF;
BEGIN
	INSERT INTO Crim(
	  APNO,
	  County,
	  IsCAMReview,
	  IsHidden,
	  IsHistoryRecord
	)VALUES(
	  @applicant_id,
	  -- duplicates value in Counties table
	  '<intentionally empty>',
	  'False',
	  'False',
	  'False'
	);
	/*
	Is it necessary to fill in all the Appl duplicative columns in Crim,
	like SSN, DOB, etc.?
	*/
	EXECUTE iris_ws_update_criminal_case
        @vendor_id = @vendor_id,
        @batch_id = @batch_id,
        @applicant_id = @applicant_id,
        @screening_id = @@IDENTITY,
        @order_status = @order_status,
        @result_status = @result_status,
        @case_no = @case_no,
        @degree = @degree,
        @disposition = @disposition,
        @disposed_on = @disposed_on,
        @filed_on = @filed_on,
        @fine = @fine,
        @offense = @offense,
        @sentence = @sentence;
END
PRINT 'creating procedure iris_ws_add_criminal_case';

