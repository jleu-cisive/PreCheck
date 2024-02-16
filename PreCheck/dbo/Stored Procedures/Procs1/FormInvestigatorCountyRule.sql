


CREATE PROCEDURE [dbo].[FormInvestigatorCountyRule]
(@CrimID int)
AS



DECLARE @CNTY_NO int, @apno int,@county varchar(40),@Clear varchar(1),@CRIM_SpecialInstr  varchar(8000),@ClientAdjudicationStatus int

SELECT @CNTY_NO = CNTY_NO, @apno = apno,@county = county,@Clear = clear,@CRIM_SpecialInstr = CRIM_SpecialInstr,@ClientAdjudicationStatus = ClientAdjudicationStatus
 from Crim where CrimId = @CrimID
IF @Clear is null or @Clear not in ('F','I') --added 7/9/07
EXEC testFaxing @apno,@county,@CNTY_NO,@CrimID,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus


--
--
--SET NOCOUNT ON
--
--DECLARE  @CNTY_NO int, @vendor1 int, @vendor2 int, @vendor3 int
--	, @vendor4 int, @vendor5 int, @vendor6 int, @vendor int
--
--SELECT TOP 1 @CNTY_NO = CNTY_NO FROM dbo.Crim WHERE CrimID = @CrimID
----SELECT @CNTY_NO -- = 789
--
--SELECT TOP 1
--	@vendor1 = vendor1
--	, @vendor2 = vendor2
--	, @vendor3 = vendor3
--	, @vendor4 = vendor4
--	, @vendor5 = vendor5
--	, @vendor6 = vendor6
--FROM dbo.Iris_County_Rules
--WHERE CountyState = @CNTY_NO
--	AND Active = 1
--
----SELECT @vendor1, @vendor2, @vendor3, @vendor4, @vendor5, @vendor6
--
--DECLARE @i int, @newRecordCount int
--SET @i = 0
--SET @newRecordCount = 0
--WHILE @i < 6
--BEGIN
--  SET @i = @i + 1
--
--  IF @i = 1
--    SET @vendor = @vendor1
--  ELSE IF @i = 2
--    SET @vendor = @vendor2
--  ELSE IF @i = 3
--    SET @vendor = @vendor3
--  ELSE IF @i = 4
--    SET @vendor = @vendor4
--  ELSE IF @i = 5
--    SET @vendor = @vendor5
--  ELSE IF @i = 6
--    SET @vendor = @vendor6
--
--  IF ISNULL(@vendor, 0) > 0
--  BEGIN
--    SET @newRecordCount = @newRecordCount + 1
--    INSERT INTO dbo.Crim (APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, Degree, Offense, Disposition
--	  , Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias, txtalias2, txtalias3, txtalias4, uniqueid, txtlast
--	  , Crimenteredtime, Last_Updated, CNTY_NO, IRIS_REC, CRIM_SpecialInstr, Report, batchnumber, crim_time, vendorid
--	  , deliverymethod, countydefault, status, b_rule, tobeworked, readytosend, NoteToVendor, test, InUse, parentCrimID
--  	  , IrisFlag, IrisOrdered, Temporary, CreatedDate, IsCAMReview, IsHidden, IsHistoryRecord)
--    SELECT TOP 1 APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, Degree, Offense, Disposition
--	  , Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias, txtalias2, txtalias3, txtalias4, uniqueid, txtlast
--	  , Crimenteredtime, Last_Updated, CNTY_NO, IRIS_REC, Crim_SpecialInstr, Report, batchnumber, crim_time, NULL
--	  , deliverymethod, countydefault, status, b_rule, tobeworked, readytosend, NoteToVendor, test, InUse, @CrimID
--	  , IrisFlag, IrisOrdered, Temporary, CreatedDate, IsCAMReview, IsHidden, IsHistoryRecord
--	FROM dbo.Crim WHERE CrimID = @CrimID
--
--    --for some reason, if I use @vendor in the INSERT statement, some of the bit fields changes
--    UPDATE dbo.Crim SET VendorID = @vendor WHERE CrimID = @@IDENTITY	
--  END
--END
--
--IF @newRecordCount > 0
--  DELETE FROM dbo.Crim WHERE CrimID = @CrimID
--
--SET NOCOUNT OFF





