------------------------------------------------------------
-- Modified by Radhika Dereddy on 03/19/2021 after Andy's fine tuning 
-- and added two separate update statements
-------------------------------------------------------------

CREATE PROCEDURE [dbo].[iris_ws_update_screening]
    @screening_id BIGINT,
    @order_status  VARCHAR(35),
    @result_status VARCHAR(35)
AS
DECLARE @original_order_status CHAR(1);
DECLARE @clear CHAR(1);
DECLARE @TempAliasParentCrimID int;
DECLARE @TempCrimID int;
DECLARE @CountClear int;
DECLARE @CountAliases int; 
DECLARE @current_order_status CHAR(1); 
DECLARE @Code varchar(10);
BEGIN
/*
NOTE: "iris_ws_update_screening" is intended to update all records
pertaining to a single screening, i.e. the originally ordered screening
and all additional records (quasi screenings) added due to multiple
criminal cases belonging to a screening.

CURRENT "clear" DEFINITIONS:
"Record Found": "F"
"Clear": "T"
"Possible": "P"
"Ordered": "O"
"Pending": "R"
"Needs Review": ""
// "W" stands for "waiting" and was added by integrations
//statuses go from '' -> R -> M -> O | W -> F | T | P
*/
    SELECT 
      @original_order_status = [clear]
      FROM crim
      WHERE crimid = @screening_id;
      
    SET @clear = CASE
	    WHEN (@order_status = 'New') THEN @original_order_status
	    WHEN (@order_status = 'InProgress')
	      OR (@order_status = 'Delayed')
	      OR (@order_status = 'Suspended')
	      OR (@order_status = 'Hold') THEN 'W'
	    WHEN (@order_status = 'Cancelled')
	      OR (@order_status = 'Completed')
	      OR (@order_status = 'Fulfilled') THEN
	      CASE
            WHEN @result_status = 'Pass' THEN 'T'
            /*
            -- SETTING TO ANYTHING OTHER THAN 'W', WILL HIDE THEM FROM IRIS
            WHEN @result_status = 'Fail' THEN 'P'
            WHEN @result_status = 'Review' THEN 'P'
            WHEN @result_status = 'Hit' THEN 'F'
            */
            WHEN @result_status = 'Clear' THEN 'T'
            /*
            -- SETTING TO ANYTHING OTHER THAN 'W', WILL HIDE THEM FROM IRIS
            WHEN @result_status = 'UnableToContact' THEN 'P'
            WHEN @result_status = 'UnableToVerify' THEN 'P'
            ELSE 'P'
            */
            ELSE 'V'
	      END
	    ELSE @original_order_status
	  END;
      
  -- Commented by Radhika Dereddy on 03/19/2021 after Andy's fine tuning and added two separate update statements
	--UPDATE crim SET
	--  [clear] = @clear
	--  WHERE (crimid = @screening_id)
	--     OR (parentcrimid = @screening_id);

  -- this sets both screenings & criminal-cases to same clear value
	    UPDATE crim SET
         [clear] = @clear
         WHERE (crimid = @screening_id)

       UPDATE crim SET
         [clear] = @clear
         WHERE (parentcrimid = @screening_id)


--Added by Schapyala - 08/09/2013 - to log the crim status as updated by the web service
INSERT INTO [dbo].[IRIS_ResultLog]
           ([ResultLogCategoryID]
           ,[CrimID]
           ,[APNO]
           ,[Investigator]
           ,[LogDate]
           ,[Clear])
     VALUES
           (7,@screening_id,0,'ws',current_timestamp,@clear)


	  
	-- this finalizes screenings that have criminal-cases so that Iris will view only the criminal-cases
	UPDATE crim SET
	  [clear] = 'F'
	  WHERE crimid  = (SELECT DISTINCT parentcrimid FROM crim WHERE (parentcrimid = @screening_id));

	--NOTE: The ParentCrimRecord/PrimaryName record is marked RecordFound if atleast 1 alias is a hit (N --> F)
	--		The ParentCrimRecord/PrimaryName record is marked a Clear Only if all aliases are clears (N --> T)

	--This updates the parent record when the primary Name is not searched on (i.e. txtlast = 0) 
	-- and a search on an alias is a hit
	SET @TempAliasParentCrimID = (SELECT AliasParentCrimID From Crim Where Crimid = (SELECT DISTINCT parentcrimid FROM crim WHERE parentcrimid = @screening_id))
	IF( @TempAliasParentCrimID IS NOT NULL)
	BEGIN
		UPDATE CRIM SET 
		[CLEAR] = 'F' 
		WHERE Crimid = @TempAliasParentCrimID and [Clear] = 'N'
	END
	
	SELECT @TempCrimID = ALiasParentCrimID FROM Crim WHERE CrimID = @Screening_ID
	SELECT @CountClear =Count(Clear) FROM CRIM WHERE ALiasParentCRIMID = @TempCrimID and CLear = 'T'
	SELECT @CountAliases = Count(1)  FROM CRIM WHERE ALiasParentCRIMID = @TempCrimID
	IF( @CountClear = @CountAliases) 
	BEGIN
		UPDATE CRIM SET 
		[CLEAR] = 'T' 
		Where CrimId = @TempCrimID AND CLear = 'N'
	END

	--This adds the note that the record was updated through the web service along with a timestamp
	IF @clear = 'T'
	BEGIN
	EXECUTE iris_ws_update_crim_priv_notes
        @crim_id = @screening_id,
		@Is_Criminal_Case_Record = 0;	
	END

	     
    UPDATE iris_ws_screening SET
       result_status = @result_status,
       order_status = @order_status
       WHERE crim_id = @screening_id;

	
   -- Updating delivered flag when results are obtained so that same orders wouldn't be
   -- sent in waiting orders queue    
   SELECT 
      @current_order_status = [clear]
      FROM crim
      WHERE crimid = @screening_id;

   IF ((@current_order_status = 'F') or (@current_order_status = 'T'))
   Begin
   UPDATE iris_ws_ready_for_delivery SET
       delivered = 1
       WHERE screening_id = @screening_id;
   END   

      SELECT distinct
		@Code = VT.code
		FROM Crim C 
		INNER JOIN iris_ws_vendor_searches VS
			 INNER JOIN iris_ws_vendor_type VT		            
			 ON VS.vendor_type_id = VT.id
		ON C.vendorid = VS.vendor_id
		WHERE crimid = @screening_id;  

    	IF ((@Code = 'innovative') and ((@current_order_status = 'F') or (@current_order_status = 'T')))
        Begin
            UPDATE
             iris_ws_screening
             SET is_confirmed = 'T'
             where crim_id = @screening_id;
        end   
END

