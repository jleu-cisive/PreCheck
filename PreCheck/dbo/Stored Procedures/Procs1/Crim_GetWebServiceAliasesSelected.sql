-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 10/24/2018
-- Description:	Get Aliases selected by PRI to send them to Vendor
-- EXECUTION: EXEC Crim_GetWebServiceAliasesSelected 28650251
-- =============================================
CREATE PROCEDURE [dbo].[Crim_GetWebServiceAliasesSelected]
	-- Add the parameters for the stored procedure here
	@CrimID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @apno int, @delivery varchar(50)-- @crimid int = 28650251--28650251
	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
	--SELECT c.CrimID, c.APNO,c.txtalias, c.txtalias2, c.txtalias3, c.txtalias4, c.txtlast, * from crim c(nolock) where c.deliverymethod = 'WEB SERVICE' AND c.CrimID	 = @crimid
	SELECT @delivery = deliverymethod from crim c(nolock) where c.deliverymethod = 'WEB SERVICE' AND crimid = @crimid

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
				SELECT @primName = CONCAT(first, ' ', middle, ' ', last, ' ', generation, ', ')	FROM APPL(nolock)	WHERE APNO = @apno
			END

		IF(@txtalias = 1)
				BEGIN
					SELECT @alias1 = CONCAT(Alias1_First, ' ', Alias1_Middle, ' ', Alias1_Last, ' ', Alias1_Generation, ', ')	FROM APPL(nolock)	WHERE APNO = @apno	
				END
	
		IF(@txtalias2 = 1)
				BEGIN
					SELECT @alias2 = CONCAT(Alias2_First, ' ', Alias2_Middle, ' ', Alias2_Last, ' ', Alias2_Generation, ', ')	FROM APPL(nolock)	WHERE APNO = @apno	
				END
	
		IF(@txtalias3 = 1)
				BEGIN
					SELECT @alias3 = CONCAT(Alias3_First, ' ', Alias3_Middle, ' ', Alias3_Last, ' ', Alias3_Generation, ', ')	FROM APPL(nolock)	WHERE APNO = @apno	
				END
	
		IF(@txtalias4 = 1)
				BEGIN
					SELECT @alias4 = CONCAT(Alias4_First, ' ', Alias4_Middle, ' ', Alias4_Last, ' ', Alias4_Generation, ', ')	FROM APPL(nolock)	WHERE APNO = @apno	
				END

		SET @sentNames = CONCAT(@primName, ' ', @alias1, ' ', @alias2, ' ', @alias3, ' ', @alias4)
		
		--PRINT @sentNames
		SELECT @sentNames AS AliasesSelected,(DATALENGTH(@sentNames)-DATALENGTH(REPLACE(@sentNames,',','')))/DATALENGTH(',') AS NoOfAliasesSelected, @CrimID AS CrimID, @apno AS Apno
	END
END
