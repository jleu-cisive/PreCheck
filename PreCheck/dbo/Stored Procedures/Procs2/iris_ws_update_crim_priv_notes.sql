

CREATE PROCEDURE [dbo].[iris_ws_update_crim_priv_notes]
   @crim_id BIGINT,
   @Is_Criminal_Case_Record bit
AS

DECLARE @CRLF CHAR(2);
DECLARE @last_updated DATETIME;
DECLARE @Code varchar(10);
DECLARE @Apno int;
DECLARE @AliasParentCrimId int;
DECLARE @ParentCrimId int;
DECLARE @txtlast char(2);
DECLARE @txtalias char(2);
DECLARE @txtalias2 char(2);
DECLARE @txtalias3 char(2);
DECLARE @txtalias4 char(2);
DECLARE @first varchar(20);
DECLARE @middle varchar(20);
DECLARE @last varchar(20);
DECLARE @FullName varchar (100);
Declare @temp_priv_notes varchar(max);
SET @First = ''
SET @Last = ''
SET @Middle = ''

BEGIN
SET @CRLF = char(13) + char(10);

	IF @Is_Criminal_Case_Record IS NULL OR @Is_Criminal_Case_Record = 1
	BEGIN	 
		SELECT 
		@last_updated = C.last_updated,
		@Code = VT.code,
		@Apno = C.APNO,
		@ParentCrimID = C.ParentCrimID
		FROM Crim C 
		INNER JOIN iris_ws_vendor_searches VS
			 INNER JOIN iris_ws_vendor_type VT		            
			 ON VS.vendor_type_id = VT.id
		ON C.vendorid = VS.vendor_id
		INNER JOIN Appl A
		ON C.APNO = A.APNO
		WHERE crimid = @crim_id;    

		SELECT 
		@txtlast = C.txtlast,
		@txtalias = C.txtalias,
		@txtalias2 = C.txtalias2,
		@txtalias3 = C.txtalias3,
		@txtalias4 = C.txtalias4,
		@ALiasParentCrimID = C.AliasParentCrimID
		FROM Crim C 
		INNER JOIN Appl A ON C.APNO = A.APNO
		WHERE CrimID = @ParentCrimID; 		
	END
	ELSE IF @Is_Criminal_Case_Record = 0
	/* For Clears - Update 
	*/
	BEGIN
		SELECT 
		@last_updated = C.last_updated,
		@Code = VT.code,
		@Apno = C.APNO,
		@txtlast = C.txtlast,
		@txtalias = C.txtalias,
		@txtalias2 = C.txtalias2,
		@txtalias3 = C.txtalias3,
		@txtalias4 = C.txtalias4,
		@ALiasParentCrimID = C.AliasParentCrimID		
		FROM Crim C 
		INNER JOIN iris_ws_vendor_searches VS ON C.vendorid = VS.vendor_id
		INNER JOIN iris_ws_vendor_type VT ON VS.vendor_type_id = VT.id		
		INNER JOIN Appl A ON C.APNO = A.APNO
		WHERE crimid = @crim_id; 		 
	END
	/* TODO: Required to match Aliases with background search results  */
	IF @Code = 'Omnidata'
		BEGIN
			IF LTRIM(RTRIM(@txtAlias)) = '1' AND @ALiasParentCrimId IS NOT NULL
			BEGIN
				SELECT  @first = Ap.Alias1_First,
						@Middle = Ap.Alias1_Middle,
						@Last = Ap.Alias1_Last
				FROM Appl as Ap
				WHERE AP.APNO = @Apno 
			END	
			IF LTRIM(RTRIM(@txtAlias2)) = '1' AND @ALiasParentCrimId IS NOT NULL
			BEGIN
				SELECT  @first = Ap.Alias2_First,
						@Middle = Ap.Alias2_Middle,
						@Last = Ap.Alias2_Last
				FROM Appl as Ap
				WHERE AP.APNO = @Apno 
			END	
			IF LTRIM(RTRIM(@txtAlias3)) = '1' AND @ALiasParentCrimId IS NOT NULL
			BEGIN
				SELECT  @first = Ap.Alias3_First,
						@Middle = Ap.Alias3_Middle,
						@Last = Ap.Alias3_Last
				FROM Appl as Ap
				WHERE AP.APNO = @Apno 
			END	
			IF LTRIM(RTRIM(@txtAlias4)) = '1' AND @ALiasParentCrimId IS NOT NULL
			BEGIN
				SELECT  @first = Ap.Alias4_First,
						@Middle = Ap.Alias4_Middle,
						@Last = Ap.Alias4_Last
				FROM Appl as Ap
				WHERE AP.APNO = @Apno 
			END	
		END

     select @temp_priv_notes = priv_notes from dbo.crim where crimid = @crim_id;

     if (@temp_priv_notes <>'') 
      begin 
        IF @First <> '' AND @Last <> '' 
			BEGIN
				SET @FullName = 'Searched on Alias: ' + @Last+', ' + @First + ' ' + @Middle
				UPDATE Crim
				SET priv_notes = 'Updated through Web Integration on ' + CAST(@last_updated as VARCHAR(20)) + 
					+ ' from ' + @Code + @CRLF + @CRLF+ @FullName + @CRLF + @CRLF + @temp_priv_notes
				WHERE CrimID = @crim_id;
			END
		ELSE
			BEGIN
			  UPDATE Crim
			  SET priv_notes = 'Updated through Web Integration on ' + CAST(@last_updated as VARCHAR(20)) + ' from ' + @Code 
                  + @CRLF + @CRLF + @temp_priv_notes
			  WHERE CrimID = @crim_id;
			END
        end
    else
      begin
         IF @First <> '' AND @Last <> '' 
			BEGIN
				SET @FullName = 'Searched on Alias: ' + @Last+', ' + @First + ' ' + @Middle
				UPDATE Crim
				SET priv_notes = 'Updated through Web Integration on ' + CAST(@last_updated as VARCHAR(20)) + 
					+ ' from ' + @Code + @CRLF + @CRLF+ @FullName 
				WHERE CrimID = @crim_id;
			END
		ELSE
			BEGIN
			  UPDATE Crim
			  SET priv_notes = 'Updated through Web Integration on ' + CAST(@last_updated as VARCHAR(20)) + ' from ' + @Code 
			  WHERE CrimID = @crim_id;
			END
      end
 
END






