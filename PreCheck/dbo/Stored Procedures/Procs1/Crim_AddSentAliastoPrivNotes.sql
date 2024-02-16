
/*
Created By	:	Larry Ouch
Created Date:	02/09/2017
Description	:	Grabs all the sent aliases from the ApplAlias table and adds them to the private notes using the crimid
Execution	:	EXEC [dbo].[Crim_AddSentAliastoPrivNotes]  23398668, 'test'
*/

CREATE PROCEDURE [dbo].[Crim_AddSentAliastoPrivNotes] 
    @CrimID int, @investigator varchar(8)
AS   

	DECLARE @apno int, @delivery varchar(50)
	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
	SELECT @delivery = deliverymethod from crim where crimid = @crimid 

	IF (@delivery = 'WEB SERVICE')
	BEGIN
		DECLARE @txtlast bit, @txtalias bit, @txtalias2 bit, @txtalias3 bit, @txtalias4 bit
		DECLARE @primName varchar(70), @alias1 varchar(70), @alias2 varchar(70), @alias3 varchar(70), @alias4 varchar(70)
		DECLARE @sentNames varchar(350)

		SELECT @apno = apno, @txtlast = txtlast, @txtalias = txtalias, @txtalias2 = txtalias2, @txtalias3 = txtalias3, @txtalias4 = txtalias4 
		FROM crim (NOLOCK) 
		WHERE crimid = @crimid 

		IF(@txtlast = 1)
			BEGIN		
				SELECT @primName = CONCAT(first, ' ', middle, ' ', last, ' ', generation, ', ')	FROM APPL	WHERE APNO = @apno
			END

		IF(@txtalias = 1)
				BEGIN
					SELECT @alias1 = CONCAT(Alias1_First, ' ', Alias1_Middle, ' ', Alias1_Last, ' ', Alias1_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END
	
		IF(@txtalias2 = 1)
				BEGIN
					SELECT @alias2 = CONCAT(Alias2_First, ' ', Alias2_Middle, ' ', Alias2_Last, ' ', Alias2_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END
	
		IF(@txtalias3 = 1)
				BEGIN
					SELECT @alias3 = CONCAT(Alias3_First, ' ', Alias3_Middle, ' ', Alias3_Last, ' ', Alias3_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END
	
		IF(@txtalias4 = 1)
				BEGIN
					SELECT @alias4 = CONCAT(Alias4_First, ' ', Alias4_Middle, ' ', Alias4_Last, ' ', Alias4_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
				END

		SET @sentNames = CONCAT(@primName, ' ', @alias1, ' ', @alias2, ' ', @alias3, ' ', @alias4)
		
		--PRINT @sentNames
		UPDATE CRIM SET Priv_Notes =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @sentNames + @NewLineChar + @NewLineChar + ISNULL(Priv_Notes,'') WHERE CrimID = @crimid	

	END
	ELSE
	BEGIN
		CREATE TABLE #tmpNamesNotToBeSent(ApplAliasID int, APNO int, first varchar(50),middle varchar(50),last varchar(50), IsMaiden bit, generation varchar(50), IsPublicRecordQualified bit, IsPrimaryname bit, ApplAlias_IsActive bit, AddedBy varchar(20))
					Insert into #tmpNamesNotToBeSent EXEC [dbo].Crim_GetAliasesToSend @crimid 

					--If record exsits, grab all aliases, concatenate and save to private notes
					IF EXISTS (SELECT * FROM #tmpNamesNotToBeSent)
					BEGIN
						DECLARE @fullName varchar(max), @first varchar(50), @middle varchar(50), @last varchar(50), @generation varchar(50);	
						SET @fullName = '';
						DECLARE Batch_Cursor2 CURSOR FOR
						SELECT First, Middle, Last, generation
						FROM #tmpNamesNotToBeSent(nolock)
						OPEN Batch_Cursor2;
						FETCH NEXT FROM Batch_Cursor2 into @first, @middle, @last, @generation;
						WHILE @@FETCH_STATUS = 0
							BEGIN			
								set @fullName += ISNULL(@first, '') + ' ' + ISNULL(@middle,'') + ' ' + ISNULL(@last,'') + ' ' + ISNULL(@generation,'') + ', '								
		   						FETCH NEXT FROM Batch_Cursor2 INTO @first, @middle, @last, @generation;		
							End
				
						If (@fullName <> '')
						BEGIN			
							UPDATE CRIM SET Priv_Notes =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @fullName + @NewLineChar + @NewLineChar + ISNULL(Priv_Notes,'') WHERE CrimID = @crimid	
							--print  'Delivery: ' + @delivery + ' Priv_Notes =' + @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @fullName + @NewLineChar + @NewLineChar;
						END

						CLOSE Batch_Cursor2;
						DEALLOCATE Batch_Cursor2;	
					END

					DROP TABLE #tmpNamesNotToBeSent
	END



-- 10/26/2017 - VD & LO - Commented the below code: The below code was checking primary name only. There is no need to check for CreateAlias field.
/*
DECLARE @apno int, @delivery varchar(50)
DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
SELECT @delivery = deliverymethod from crim where crimid = @crimid 

IF (@delivery = 'WEB SERVICE')
BEGIN

DECLARE @txtlast bit, @txtalias bit, @txtalias2 bit, @txtalias3 bit, @txtalias4 bit
DECLARE @primName varchar(70), @alias1 varchar(70), @alias2 varchar(70), @alias3 varchar(70), @alias4 varchar(70)
DECLARE @sentNames varchar(350)
DECLARE @createAlias bit

Set @createAlias =(SELECT VT.CreateAlias FROM  dbo.Crim AS C (NOLOCK)
                 INNER JOIN dbo.iris_ws_vendor_searches AS VS (NOLOCK)
                 Inner Join dbo.iris_ws_vendor_type AS VT (NOLOCK) on VS.vendor_type_id = VT.id ON C.CNTY_NO = VS.county_id AND C.vendorid = VS.vendor_id 
                 WHERE C.crimid = @CrimID)

	SELECT @apno = apno, @txtlast = txtlast, @txtalias = txtalias, @txtalias2 = txtalias2, @txtalias3 = txtalias3, @txtalias4 = txtalias4 
	FROM crim (NOLOCK) 
	WHERE crimid = @crimid 

	IF(@txtlast = 1)
		BEGIN		
			SELECT @primName = CONCAT(first, ' ', middle, ' ', last, ' ', generation, ', ')	FROM APPL	WHERE APNO = @apno
		END

	IF(@txtalias = 1)
			BEGIN
				SELECT @alias1 = CONCAT(Alias1_First, ' ', Alias1_Middle, ' ', Alias1_Last, ' ', Alias1_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END
	
	IF(@txtalias2 = 1)
			BEGIN
				SELECT @alias2 = CONCAT(Alias2_First, ' ', Alias2_Middle, ' ', Alias2_Last, ' ', Alias2_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END
	
	IF(@txtalias3 = 1)
			BEGIN
				SELECT @alias3 = CONCAT(Alias3_First, ' ', Alias3_Middle, ' ', Alias3_Last, ' ', Alias3_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END
	
	IF(@txtalias4 = 1)
			BEGIN
				SELECT @alias4 = CONCAT(Alias4_First, ' ', Alias4_Middle, ' ', Alias4_Last, ' ', Alias4_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END

	SET @sentNames = CONCAT(@primName, ' ', @alias1, ' ', @alias2, ' ', @alias3, ' ', @alias4)

	IF(@createAlias <> 1)
	BEGIN
		IF(@txtalias = 1)
			BEGIN
				SELECT @alias1 = CONCAT(Alias1_First, ' ', Alias1_Middle, ' ', Alias1_Last, ' ', Alias1_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END
		IF(@txtalias2 = 1)
			BEGIN
				SELECT @alias2 = CONCAT(Alias2_First, ' ', Alias2_Middle, ' ', Alias2_Last, ' ', Alias2_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END
		IF(@txtalias3 = 1)
			BEGIN
				SELECT @alias3 = CONCAT(Alias3_First, ' ', Alias3_Middle, ' ', Alias3_Last, ' ', Alias3_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END
		IF(@txtalias4 = 1)
			BEGIN
				SELECT @alias4 = CONCAT(Alias4_First, ' ', Alias4_Middle, ' ', Alias4_Last, ' ', Alias4_Generation, ', ')	FROM APPL	WHERE APNO = @apno	
			END

		SET @sentNames = CONCAT(@primName, ' ', @alias1, ' ', @alias2, ' ', @alias3, ' ', @alias4)
		END
	ELSE
	BEGIN
		SET @sentNames = ISNULL(@primName,'')
	END
	
	--PRINT @sentNames
	UPDATE CRIM SET Priv_Notes =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @sentNames + @NewLineChar + @NewLineChar + ISNULL(Priv_Notes,'') WHERE CrimID = @crimid	


END

ELSE
BEGIN
	CREATE TABLE #tmpNamesNotToBeSent(ApplAliasID int, APNO int, first varchar(50),middle varchar(50),last varchar(50), IsMaiden bit, generation varchar(50), IsPublicRecordQualified bit, IsPrimaryname bit, ApplAlias_IsActive bit, AddedBy varchar(20))
				Insert into #tmpNamesNotToBeSent EXEC [dbo].Crim_GetAliasesToSend @crimid 

				--If record exsits, grab all aliases, concatenate and save to private notes
				IF EXISTS (SELECT * FROM #tmpNamesNotToBeSent)
				BEGIN
					DECLARE @fullName varchar(max), @first varchar(50), @middle varchar(50), @last varchar(50), @generation varchar(50);	
					SET @fullName = '';
					DECLARE Batch_Cursor2 CURSOR FOR
					SELECT First, Middle, Last, generation
					FROM #tmpNamesNotToBeSent(nolock)
					OPEN Batch_Cursor2;
					FETCH NEXT FROM Batch_Cursor2 into @first, @middle, @last, @generation;
					WHILE @@FETCH_STATUS = 0
						BEGIN			
							set @fullName += ISNULL(@first, '') + ' ' + ISNULL(@middle,'') + ' ' + ISNULL(@last,'') + ' ' + ISNULL(@generation,'') + ', '								
		   					FETCH NEXT FROM Batch_Cursor2 INTO @first, @middle, @last, @generation;		
						End
				
					If (@fullName <> '')
					BEGIN			
						UPDATE CRIM SET Priv_Notes =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @fullName + @NewLineChar + @NewLineChar + ISNULL(Priv_Notes,'') WHERE CrimID = @crimid	
						--print  'Delivery: ' + @delivery + ' Priv_Notes =' + @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @fullName + @NewLineChar + @NewLineChar;
					END

					CLOSE Batch_Cursor2;
					DEALLOCATE Batch_Cursor2;	
				END

				DROP TABLE #tmpNamesNotToBeSent
END
*/