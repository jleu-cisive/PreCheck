











CREATE PROCEDURE [dbo].[Iris_CrimInsert]
(
@APNO int, 
@County  varchar(40),
@Clear varchar(1), 
@Ordered varchar(14),

--@Name varchar(30),
@Name varchar(100),
@DOB datetime,
@SSN varchar(11),

@CaseNo varchar(50), 
@Date_Filed datetime, 
@Degree varchar(1), 
@Offense varchar(1000), 
@Disposition varchar(500), 
@Sentence varchar(1000), 
@Fine varchar(100), 
@Disp_Date datetime, 
@Pub_Notes text,
@Priv_Notes text, 
@txtalias char(2), 
@txtalias2 char(2), 
@txtalias3 char(2), 
@txtalias4 char(2), 
--@uniqueid float, 
@txtlast char(2),
--@Crimenteredtime datetime, 
@Last_Updated datetime, 
@CNTY_NO int, 
@IRIS_REC varchar(3), 
@CRIM_SpecialInstr text, 
--@Report text, 
--@batchnumber float, 
--@crim_time varchar(50), 
@vendorid varchar(50), 
--@deliverymethod varchar(50), 
--@countydefault varchar(50), 
--@status varchar(50), 
@b_rule varchar(50), 
--@tobeworked bit, 
--@readytosend bit, 
--@NoteToVendor varchar(50), 
--@test varchar(50), 
@InUse bit--, 
--@parentCrimID int, 
--@IrisFlag varchar(10), 
--@IrisOrdered datetime, 
--@Temporary bit, 
--@CreatedDate datetime
	
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.Crim(APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, 
Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias,
 txtalias2, txtalias3, txtalias4, --uniqueid, 
txtlast, --Crimenteredtime, 
Last_Updated, 
CNTY_NO, IRIS_REC, 
CRIM_SpecialInstr, --Report, batchnumber, crim_time, 
vendorid, 
--deliverymethod, countydefault, status, 
b_rule, --tobeworked, readytosend, NoteToVendor, 
--test, 
InUse --, --parentCrimID, IrisFlag, IrisOrdered, [Temporary], CreatedDate
) 
VALUES (@APNO, @County, @Clear, @Ordered, @Name, @DOB, @SSN, @CaseNo, @Date_Filed, 
@Degree, @Offense, @Disposition, @Sentence, @Fine, @Disp_Date, @Pub_Notes, 
@Priv_Notes, @txtalias, @txtalias2, @txtalias3, @txtalias4, --@uniqueid, 
@txtlast,
 --@Crimenteredtime, 
@Last_Updated, @CNTY_NO, @IRIS_REC, 
@CRIM_SpecialInstr, 
--@Report, @batchnumber, @crim_time, 
@vendorid, --@deliverymethod, @countydefault, 
--@status, 
@b_rule, --@tobeworked, @readytosend, @NoteToVendor, @test, 
@InUse--, 
--@parentCrimID, @IrisFlag, @IrisOrdered, @Temporary, @CreatedDate
); 
SELECT CrimID, APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, 
Date_Filed, Degree, Offense, Disposition, Sentence, Fine, Disp_Date, 
Pub_Notes, Priv_Notes, txtalias, txtalias2, txtalias3, txtalias4, 
--uniqueid, 
txtlast, --Crimenteredtime, 
Last_Updated, CNTY_NO, IRIS_REC, 
CRIM_SpecialInstr, --Report, batchnumber, crim_time, 
vendorid, --deliverymethod, 
--countydefault, status, 
b_rule, --tobeworked, readytosend, NoteToVendor, test, 
InUse--, --parentCrimID, IrisFlag, IrisOrdered, Temporary, CreatedDate 
FROM dbo.Crim WHERE (CrimID = SCOPE_IDENTITY())










