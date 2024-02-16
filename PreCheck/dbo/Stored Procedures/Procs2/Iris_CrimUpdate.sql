
CREATE PROCEDURE [dbo].[Iris_CrimUpdate]

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

--@InUse varchar(8), 

--@parentCrimID int, 

--@IrisFlag varchar(10), 

--@IrisOrdered datetime, 

--@Temporary bit, 

--@CreatedDate datetime,

@Original_CrimID int,

@Original_APNO int, 

@Original_County  varchar(40),

@Original_Clear varchar(1), 

@Original_Ordered varchar(14),

@Original_Name varchar(100),
--@Original_Name varchar(100),

@Original_DOB datetime,

@Original_SSN varchar(11), 

 

@Original_CaseNo varchar(50), 

@Original_Date_Filed datetime, 

@Original_Degree varchar(1), 

@Original_Offense varchar(1000), 

@Original_Disposition varchar(500), 

@Original_Sentence varchar(1000), 

@Original_Fine varchar(100), 

@Original_Disp_Date datetime, 

@Original_Pub_Notes text,

@Original_Priv_Notes text, 

@Original_txtalias char(2), 

@Original_txtalias2 char(2), 

@Original_txtalias3 char(2), 

@Original_txtalias4 char(2), 

--@Original_uniqueid float, 

@Original_txtlast char(2),

--@Original_Crimenteredtime datetime, 

@Original_Last_Updated datetime, 

@Original_CNTY_NO int, 

@Original_IRIS_REC varchar(3), 

@Original_CRIM_SpecialInstr text, 

--@Original_Report text, 

--@Original_batchnumber float, 

--@Original_crim_time varchar(50), 

@Original_vendorid varchar(50), 

--@Original_deliverymethod varchar(50), 

--@Original_countydefault varchar(50), 

--@Original_status varchar(50), 

@Original_b_rule varchar(50), 

--@Original_tobeworked bit, 

--@Original_readytosend bit, 

--@Original_NoteToVendor varchar(50), 

--@Original_test varchar(50), 

--@Original_InUse varchar(8), 

--@Original_parentCrimID int, 

--@Original_IrisFlag varchar(10), 

--@Original_IrisOrdered datetime, 

--@Original_Temporary bit, 

--@Original_CreatedDate datetime,

@CrimID int

)

AS

SET NOCOUNT OFF;



INSERT INTO [PreCheck].[dbo].[CriminalVendor_Log] ([APNO]
, [County]
, [Clear]
, [Ordered]
, [Name]
, [DOB]
, [SSN]
, [CaseNo]
, [Date_Filed]
, [Degree]
, [Offense]
, [Disposition]
, [Sentence]
, [Fine]
, [Disp_Date]
, [Pub_Notes]
, [Priv_Notes]
, [txtalias]
, [txtalias2]
, [txtalias3]
, [txtalias4]
, [txtlast]
, [Last_Updated]
, [CNTY_NO]
, [IRIS_REC]
, [CRIM_SpecialInstr]
, [vendorid]
, [deliverymethod]
, [b_rule])
	VALUES (@APNO, @County, @Clear, @Ordered, @Name, @DOB, @SSN, @CaseNo, @Date_Filed, @Degree, @Offense, @Disposition, @Sentence, @Fine, @Disp_Date, @Pub_Notes, @Priv_Notes, @txtalias, @txtalias2, @txtalias3, @txtalias4, @txtlast, @Last_Updated, @CNTY_NO, @IRIS_REC, @CRIM_SpecialInstr, @vendorid, 'Criminal Vendor Website', @b_rule)





UPDATE dbo.Crim

SET	APNO = @APNO,
	County = @County,
	Clear = @Clear,
	Ordered = @Ordered,
	Name = @Name,
	DOB = @DOB,
	SSN = @SSN,

	CaseNo = @CaseNo,

	Date_Filed = @Date_Filed,
	Degree = @Degree,
	Offense = @Offense,
	Disposition = @Disposition,
	Sentence = @Sentence,
	Fine = @Fine,

	Disp_Date = @Disp_Date,
	Pub_Notes = @Pub_Notes,
	Priv_Notes = @Priv_Notes,
	txtalias = @txtalias,
	txtalias2 = @txtalias2,
	txtalias3 = @txtalias3,

	txtalias4 = @txtalias4,

	--uniqueid = @uniqueid, 

	txtlast = @txtlast,

	--Crimenteredtime = @Crimenteredtime, 

	Last_Updated = @Last_Updated,

	CNTY_NO = @CNTY_NO,

	IRIS_REC = @IRIS_REC,

	CRIM_SpecialInstr = @CRIM_SpecialInstr,

	--Report = @Report, batchnumber = @batchnumber, 

	--crim_time = @crim_time, 

	vendorid = @vendorid,

	--deliverymethod = @deliverymethod, countydefault = @countydefault, status = @status, 

	b_rule = @b_rule--, --tobeworked = @tobeworked, readytosend = @readytosend, NoteToVendor = @NoteToVendor, test = @test, 

-- InUse = @InUse--, 

--parentCrimID = @parentCrimID, IrisFlag = @IrisFlag, IrisOrdered = @IrisOrdered, [Temporary] = @Temporary, CreatedDate = @CreatedDate

WHERE (CrimID = @Original_CrimID)
AND (APNO = @Original_APNO)
AND (CNTY_NO = @Original_CNTY_NO
OR @Original_CNTY_NO IS NULL
AND CNTY_NO IS NULL)
AND (CaseNo = @Original_CaseNo
OR @Original_CaseNo IS NULL
AND CaseNo IS NULL)
AND (Clear = @Original_Clear
OR @Original_Clear IS NULL
AND Clear IS NULL)
AND (County = @Original_County)

--AND (CreatedDate = @Original_CreatedDate OR @Original_CreatedDate IS NULL AND CreatedDate IS NULL) AND (Crimenteredtime = @Original_Crimenteredtime OR

--@Original_Crimenteredtime IS NULL AND Crimenteredtime IS NULL) 

AND (Date_Filed = @Original_Date_Filed
OR @Original_Date_Filed IS NULL
AND Date_Filed IS NULL)
AND (Degree = @Original_Degree
OR @Original_Degree IS NULL
AND Degree IS NULL)
AND (Disp_Date = @Original_Disp_Date
OR @Original_Disp_Date IS NULL
AND Disp_Date IS NULL)
AND (Disposition = @Original_Disposition
OR @Original_Disposition IS NULL
AND Disposition IS NULL)
AND (Fine = @Original_Fine
OR @Original_Fine IS NULL
AND Fine IS NULL)
AND (IRIS_REC = @Original_IRIS_REC
OR @Original_IRIS_REC IS NULL
AND IRIS_REC IS NULL) --AND 

--(InUse = @Original_InUse OR

-- @Original_InUse IS NULL AND InUse IS NULL) --AND (IrisFlag = @Original_IrisFlag OR

--@Original_IrisFlag IS NULL AND IrisFlag IS NULL) AND (IrisOrdered = @Original_IrisOrdered OR

--@Original_IrisOrdered IS NULL AND IrisOrdered IS NULL) 

AND (Last_Updated = @Original_Last_Updated
OR @Original_Last_Updated IS NULL
AND Last_Updated IS NULL) --AND(NoteToVendor = @Original_NoteToVendor OR

--@Original_NoteToVendor IS NULL AND NoteToVendor IS NULL) 

AND (Offense = @Original_Offense
OR @Original_Offense IS NULL
AND Offense IS NULL)
AND (Ordered = @Original_Ordered
OR @Original_Ordered IS NULL
AND Ordered IS NULL)

AND (Name = @Original_Name
OR @Original_Name IS NULL
AND Name IS NULL)



AND (DOB = @Original_DOB
OR @Original_DOB IS NULL
AND DOB IS NULL)



AND (SSN = @Original_SSN
OR @Original_SSN IS NULL
AND SSN IS NULL)



AND (Sentence = @Original_Sentence
OR @Original_Sentence IS NULL
AND Sentence IS NULL)

--AND ([Temporary] = @Original_Temporary OR

--@Original_Temporary IS NULL AND [Temporary] IS NULL) 

AND (b_rule = @Original_b_rule
OR @Original_b_rule IS NULL
AND b_rule IS NULL) --AND (batchnumber = @Original_batchnumber OR

--@Original_batchnumber IS NULL AND batchnumber IS NULL) AND (countydefault = @Original_countydefault OR

--@Original_countydefault IS NULL AND countydefault IS NULL) AND (crim_time = @Original_crim_time OR

--@Original_crim_time IS NULL AND crim_time IS NULL) AND (deliverymethod = @Original_deliverymethod OR

--@Original_deliverymethod IS NULL AND deliverymethod IS NULL) AND (parentCrimID = @Original_parentCrimID OR

--@Original_parentCrimID IS NULL AND parentCrimID IS NULL) AND (readytosend = @Original_readytosend OR

--@Original_readytosend IS NULL AND readytosend IS NULL) AND (status = @Original_status OR

--@Original_status IS NULL AND status IS NULL) AND (test = @Original_test OR

--@Original_test IS NULL AND test IS NULL) AND (tobeworked = @Original_tobeworked OR

--@Original_tobeworked IS NULL AND tobeworked IS NULL) 

AND (txtalias = @Original_txtalias
OR @Original_txtalias IS NULL
AND txtalias IS NULL)
AND (txtalias2 = @Original_txtalias2
OR @Original_txtalias2 IS NULL
AND txtalias2 IS NULL)
AND (txtalias3 = @Original_txtalias3
OR @Original_txtalias3 IS NULL
AND txtalias3 IS NULL)
AND (txtalias4 = @Original_txtalias4
OR @Original_txtalias4 IS NULL
AND txtalias4 IS NULL)
AND (txtlast = @Original_txtlast
OR @Original_txtlast IS NULL
AND txtlast IS NULL) --AND (uniqueid = @Original_uniqueid OR

--@Original_uniqueid IS NULL AND uniqueid IS NULL) 

AND (vendorid = @Original_vendorid
OR @Original_vendorid IS NULL
AND vendorid IS NULL);

--AND (@APNO in (select apno from  appl where appl.apno=@APNO and (appl.inuse='' or appl.inuse = 'CrimVnd' or appl.inuse is null)));

SELECT
	CrimID,
	APNO,
	County,
	Clear,
	Ordered,
	Name,
	DOB,
	SSN,
	CaseNo,
	Date_Filed,
	Degree,
	Offense,
	Disposition,
	Sentence,
	Fine,
	Disp_Date,

	Pub_Notes,
	Priv_Notes,
	txtalias,
	txtalias2,
	txtalias3,
	txtalias4, --uniqueid, 

	txtlast, --Crimenteredtime, 

	Last_Updated,
	CNTY_NO,
	IRIS_REC,

	CRIM_SpecialInstr, --Report, batchnumber, crim_time, 

	vendorid, --deliverymethod, countydefault, status, 

	b_rule--, --tobeworked, readytosend, 

--NoteToVendor, test, 

--InUse--, --parentCrimID, IrisFlag, IrisOrdered, [Temporary], CreatedDate

FROM dbo.Crim

WHERE (CrimID = @CrimID)