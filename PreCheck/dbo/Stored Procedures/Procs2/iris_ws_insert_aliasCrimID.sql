


CREATE PROCEDURE [dbo].[iris_ws_insert_aliasCrimID]
   @CrimID int, @investigator varchar(8)
AS
SET NOCOUNT OFF;

Declare @APNO int;
Declare @County  varchar(40);
Declare @Clear varchar(1);
Declare @Ordered varchar(14);
Declare @Name varchar(30);
Declare @DOB datetime;
Declare @SSN varchar(11);
Declare @CaseNo varchar(50);
Declare @Date_Filed datetime;
Declare @Degree varchar(1);
Declare @Offense varchar(50);
Declare @Disposition varchar(50);
Declare @Sentence varchar(50);
Declare @Fine varchar(50);
Declare @Disp_Date datetime;
Declare @Pub_Notes varchar(500);
Declare @Priv_Notes varchar(500);
Declare @txtalias char(2);
Declare @txtalias2 char(2);
Declare @txtalias3 char(2);
Declare @txtalias4 char(2);
Declare @uniqueid float;
Declare @txtlast char(2);
Declare @Crimenteredtime datetime;
Declare @Last_Updated datetime;
Declare @CNTY_NO int;
Declare @IRIS_REC varchar(3);
Declare @CRIM_SpecialInstr varchar(500);
Declare @Report varchar(500);
Declare @batchnumber float;
Declare @crim_time varchar(50);
Declare @vendorid varchar(50);
Declare @deliverymethod varchar(50); 
Declare @countydefault varchar(50);
Declare @status varchar(50);
Declare @b_rule varchar(50);
Declare @tobeworked bit;
Declare @readytosend bit;
Declare @NoteToVendor varchar(50);
Declare @test varchar(50);
Declare @InUse bit; 
Declare @parentCrimID int;
Declare @IrisFlag varchar(10);
Declare @IrisOrdered datetime;
Declare @Temporary bit;
Declare @CreatedDate datetime;
Declare @IsCAMReview bit;
Declare @IsHidden bit;
Declare @IsHistoryRecord bit;
Declare @AliasParentCrimID int;	

Declare @alias char(2);
Declare @alias2 char(2);
Declare @alias3 char(2);
Declare @alias4 char(2);
Declare @last char(2);
Declare @ctr int;
Declare @cntName int;
Declare @cntTotalOrders int;

Declare @Alias1_Last varchar(20);
Declare @Alias1_First varchar(20);
Declare @Alias1_Middle varchar(20);
Declare @Alias1_Generation varchar(3);
Declare @Alias2_Last varchar(20);
Declare @Alias2_First varchar(20);
Declare @Alias2_Middle varchar(20);
Declare @Alias2_Generation varchar(3);
Declare @Alias3_Last varchar(20);
Declare @Alias3_First varchar(20);
Declare @Alias3_Middle varchar(20);
Declare @Alias3_Generation varchar(3);
Declare @Alias4_Last varchar(20);
Declare @Alias4_First varchar(20);
Declare @Alias4_Middle varchar(20);
Declare @Alias4_Generation varchar(3);

Declare @SentAlias1 varchar(70);
Declare @SentAlias2 varchar(70);
Declare @SentAlias3 varchar(70); 
Declare @SentAlias4 varchar(70);

Declare @ConcatPrivNotes1 varchar(max);
Declare @ConcatPrivNotes2 varchar(max);
Declare @ConcatPrivNotes3 varchar(max);
Declare @ConcatPrivNotes4 varchar(max);
DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);

SELECT
 @APNO = C.APNO,
 @County  = C.County,
 @Clear = C.[Clear],
 @Ordered = C.Ordered,
 @Name = C.[Name],
 @DOB = C.DOB,
 @SSN = C.SSN,
 @CaseNo = C.CaseNo,
 @Date_Filed = C.Date_Filed,
 @Degree =C.Degree ,
 @Offense =C.Offense, 
 @Disposition =C.Disposition,
 @Sentence =C.Sentence,
 @Fine =C.Fine,
 @Disp_Date =C.Disp_Date,
 @Pub_Notes =C.Pub_Notes,
 @Priv_Notes =C.Priv_Notes,
 @alias = ltrim(rtrim(C.txtalias)),
 @alias2 = ltrim(rtrim(C.txtalias2)),
 @alias3 = ltrim(rtrim(C.txtalias3)),
 @alias4 = ltrim(rtrim(C.txtalias4)),
 @uniqueid =C.uniqueid,
 @last = ltrim(rtrim(C.txtlast)),
 @Crimenteredtime =C.Crimenteredtime ,
 @Last_Updated =C.Last_Updated,
 @CNTY_NO =C.CNTY_NO,
 @IRIS_REC =C.IRIS_REC,
 @CRIM_SpecialInstr =C.CRIM_SpecialInstr ,
 @Report =C.Report ,
 @batchnumber =C.batchnumber,
 @crim_time =C.crim_time,
 @vendorid =C.vendorid,
 @deliverymethod =C.deliverymethod,
 @countydefault =C.countydefault,                                                                                                                                                    
 @status =C.[status],
 @b_rule =C.b_rule,
 @tobeworked =C.tobeworked,
 @readytosend =C.readytosend ,
 @NoteToVendor =C.NoteToVendor,
 @test =C.test,
 @InUse =C.InUse,
 @parentCrimID =C.parentCrimID,
 @IrisFlag =C.IrisFlag,
 @IrisOrdered =C.IrisOrdered,
 @Temporary =C.Temporary,
 @CreatedDate =C.CreatedDate ,
 @IsCAMReview =C.IsCAMReview,
 @IsHidden =C.IsHidden,
 @IsHistoryRecord =C.IsHistoryRecord,
 @AliasParentCrimID =C.AliasParentCrimID,
 @Alias1_Last = A.Alias1_Last,
 @Alias1_First = A.Alias1_First,
 @Alias1_Middle = A.Alias1_Middle,
 @Alias1_Generation = A.Alias1_Generation,
 @Alias2_Last = A.Alias2_Last,
 @Alias2_First = A.Alias2_First,
 @Alias2_Middle = A.Alias2_Middle,
 @Alias2_Generation = A.Alias2_Generation,
 @Alias3_Last = A.Alias3_Last,
 @Alias3_First = A.Alias3_First,
 @Alias3_Middle = A.Alias3_Middle,
 @Alias3_Generation = A.Alias3_Generation,
 @Alias4_Last = A.Alias4_Last,
 @Alias4_First = A.Alias4_First,
 @Alias4_Middle = A.Alias4_Middle,
 @Alias4_Generation = A.Alias4_Generation
	  FROM crim C
	  INNER JOIN Appl A on C.APNO = A.APNO
	  WHERE CrimId = @CrimID;

set @cntName = 0;

if (@alias = 1)
begin
  set @cntName = @cntName + 1;
end

if (@alias2 = 1)
begin
  set @cntName = @cntName + 1;
end
 
if (@alias3 = 1)
begin
  set @cntName = @cntName + 1;
end

if (@alias4 = 1)
begin
  set @cntName = @cntName + 1;
end

if (@AliasParentCrimID is null) --checking whether the record is already an alias ornot
Begin

if (@cntName > = 1 ) --checking whether to create duplicate records or not
Begin
 IF(@alias = 1) -- create a duplicate record for first alias
	BEGIN
       set @txtalias = 1;
       set @txtalias2 = NULL;
       set @txtalias3 = null;
       set @txtalias4 = null;
       set @AliasParentCrimID = @CrimID;
       set @txtlast = null;
       set @ctr = null;
	   set @SentAlias1 = CONCAT(@Alias1_First, ' ', @Alias1_Middle, ' ', @Alias1_Last, ' ', @Alias1_Generation, ', ');
	   set @ConcatPrivNotes1 =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @SentAlias1 + @NewLineChar + @NewLineChar + @Priv_Notes;

       select @ctr = count(1) from crim where AliasParentCrimID = @CrimID 
       and RTRIM(LTRIM(txtalias)) = '1';


 
      if (@ctr = 0)
      Begin      
        INSERT INTO dbo.Crim(APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, 
        Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias,
        txtalias2, txtalias3, txtalias4, uniqueid, 
        txtlast, Crimenteredtime,Last_Updated, CNTY_NO, IRIS_REC, 
        CRIM_SpecialInstr, Report, batchnumber, crim_time, 
        vendorid, deliverymethod, countydefault, status, 
        b_rule, tobeworked, readytosend, NoteToVendor, test, 
        InUse , parentCrimID, IrisFlag, IrisOrdered, Temporary, CreatedDate,
        IsCAMReview,IsHidden,IsHistoryRecord,AliasParentCrimID
        ) 
        VALUES (@APNO, @County, @Clear, @Ordered, @Name, @DOB, @SSN, @CaseNo, @Date_Filed, 
        @Degree,@Offense,@Disposition,@Sentence,@Fine,@Disp_Date,@Pub_Notes,@ConcatPrivNotes1,@txtalias, 
        @txtalias2, @txtalias3, @txtalias4, @uniqueid, 
        @txtlast, @Crimenteredtime, @Last_Updated, @CNTY_NO, @IRIS_REC, 
        @CRIM_SpecialInstr, @Report, @batchnumber, @crim_time, 
        @vendorid,@deliverymethod, @countydefault, @status, 
        @b_rule, @tobeworked, @readytosend, @NoteToVendor, @test, 
        @InUse, @parentCrimID, @IrisFlag, @IrisOrdered, @Temporary, @CreatedDate,
        @IsCAMReview , @IsHidden , @IsHistoryRecord ,@AliasParentCrimID); 
      End
   END
    
	IF(@alias2 = 1)-- create a duplicate record for second alias
	BEGIN
       set @txtalias2 = 1;
       set @txtalias = null;
       set @txtalias3 = null;
       set @txtalias4 = null;
       set @AliasParentCrimID = @CrimID;
       set @txtlast = null;
       set @ctr = 0;
	   set @SentAlias2 = CONCAT(@Alias2_First, ' ', @Alias2_Middle, ' ', @Alias2_Last, ' ', @Alias2_Generation, ', ');
	   set @ConcatPrivNotes2 =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @SentAlias2 + @NewLineChar + @NewLineChar + @Priv_Notes;

       select @ctr = count(1) from crim where AliasParentCrimID = @CrimID 
       and txtalias2 = '1';
 
       if(@ctr = 0)
       Begin
         INSERT INTO dbo.Crim(APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, 
         Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias,
         txtalias2, txtalias3, txtalias4, uniqueid, 
         txtlast, Crimenteredtime,Last_Updated, CNTY_NO, IRIS_REC, 
         CRIM_SpecialInstr, Report, batchnumber, crim_time, 
         vendorid, deliverymethod, countydefault, status, 
         b_rule, tobeworked, readytosend, NoteToVendor, test, 
         InUse , parentCrimID, IrisFlag, IrisOrdered, Temporary, CreatedDate,
         IsCAMReview,IsHidden,IsHistoryRecord,AliasParentCrimID
        ) 
        VALUES (@APNO, @County, @Clear, @Ordered, @Name, @DOB, @SSN, @CaseNo, @Date_Filed, 
        @Degree,@Offense,@Disposition,@Sentence,@Fine,@Disp_Date,@Pub_Notes,@ConcatPrivNotes2,@txtalias, 
        @txtalias2, @txtalias3, @txtalias4, @uniqueid, 
        @txtlast, @Crimenteredtime, @Last_Updated, @CNTY_NO, @IRIS_REC, 
        @CRIM_SpecialInstr, @Report, @batchnumber, @crim_time, 
        @vendorid,@deliverymethod, @countydefault, @status, 
        @b_rule, @tobeworked, @readytosend, @NoteToVendor, @test, 
        @InUse, @parentCrimID, @IrisFlag, @IrisOrdered, @Temporary, @CreatedDate,
        @IsCAMReview , @IsHidden , @IsHistoryRecord ,@AliasParentCrimID); 
      End
   END
    
   IF(@alias3 = 1) -- create a duplicate record for third alias
	BEGIN
       set @txtalias3 = 1;
       set @txtalias2 = null;
       set @txtalias = null;
       set @txtalias4 = null;
       set @AliasParentCrimID = @CrimID;
       set @txtlast = null;
       set @ctr = 0;
	   set @SentAlias3 = CONCAT(@Alias3_First, ' ', @Alias3_Middle, ' ', @Alias3_Last, ' ', @Alias3_Generation, ', ');
	   set @ConcatPrivNotes3 =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @SentAlias3 + @NewLineChar + @NewLineChar + @Priv_Notes;

       select @ctr = count(1) from crim where AliasParentCrimID = @CrimID 
       and txtalias3 = '1';
 
      if(@ctr = 0)
      Begin
        INSERT INTO dbo.Crim(APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, 
        Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias,
        txtalias2, txtalias3, txtalias4, uniqueid, 
        txtlast, Crimenteredtime,Last_Updated, CNTY_NO, IRIS_REC, 
        CRIM_SpecialInstr, Report, batchnumber, crim_time, 
        vendorid, deliverymethod, countydefault, status, 
        b_rule, tobeworked, readytosend, NoteToVendor, test, 
        InUse , parentCrimID, IrisFlag, IrisOrdered, Temporary, CreatedDate,
        IsCAMReview,IsHidden,IsHistoryRecord,AliasParentCrimID
        ) 
        VALUES (@APNO, @County, @Clear, @Ordered, @Name, @DOB, @SSN, @CaseNo, @Date_Filed, 
        @Degree,@Offense,@Disposition,@Sentence,@Fine,@Disp_Date,@Pub_Notes,@ConcatPrivNotes3,@txtalias, 
        @txtalias2, @txtalias3, @txtalias4, @uniqueid, 
        @txtlast, @Crimenteredtime, @Last_Updated, @CNTY_NO, @IRIS_REC, 
        @CRIM_SpecialInstr, @Report, @batchnumber, @crim_time, 
        @vendorid,@deliverymethod, @countydefault, @status, 
        @b_rule, @tobeworked, @readytosend, @NoteToVendor, @test, 
        @InUse, @parentCrimID, @IrisFlag, @IrisOrdered, @Temporary, @CreatedDate,
        @IsCAMReview , @IsHidden , @IsHistoryRecord ,@AliasParentCrimID); 
      End
   END

   IF(@alias4 = 1) -- create a duplicate record for fourth alias
	BEGIN
       set @txtalias4 = 1;
       set @txtalias3 = null;
       set @txtalias2 = null;
       set @txtalias = null;
       set @AliasParentCrimID = @CrimID;
       set @txtlast = null;
       set @ctr = 0;
       set @SentAlias4 = CONCAT(@Alias4_First, ' ', @Alias4_Middle, ' ', @Alias4_Last, ' ', @Alias4_Generation, ', ');
	   set @ConcatPrivNotes4 =  @investigator + ', ' + convert(varchar,CURRENT_TIMESTAMP) + ', Names sent: ' + @SentAlias4 + @NewLineChar + @NewLineChar + @Priv_Notes;

       select @ctr = count(1) from crim where AliasParentCrimID = @CrimID 
       and txtalias4 = '1';

      if(@ctr = 0)
      Begin
        INSERT INTO dbo.Crim(APNO, County, Clear, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, 
        Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes, Priv_Notes, txtalias,
        txtalias2, txtalias3, txtalias4, uniqueid, 
        txtlast, Crimenteredtime,Last_Updated, CNTY_NO, IRIS_REC, 
        CRIM_SpecialInstr, Report, batchnumber, crim_time, 
        vendorid, deliverymethod, countydefault, status, 
        b_rule, tobeworked, readytosend, NoteToVendor, test, 
        InUse , parentCrimID, IrisFlag, IrisOrdered, Temporary, CreatedDate,
        IsCAMReview,IsHidden,IsHistoryRecord,AliasParentCrimID
        ) 
        VALUES (@APNO, @County, @Clear, @Ordered, @Name, @DOB, @SSN, @CaseNo, @Date_Filed, 
        @Degree,@Offense,@Disposition,@Sentence,@Fine,@Disp_Date,@Pub_Notes,@ConcatPrivNotes4,@txtalias, 
        @txtalias2, @txtalias3, @txtalias4, @uniqueid, 
        @txtlast, @Crimenteredtime, @Last_Updated, @CNTY_NO, @IRIS_REC, 
        @CRIM_SpecialInstr, @Report, @batchnumber, @crim_time, 
        @vendorid,@deliverymethod, @countydefault, @status, 
        @b_rule, @tobeworked, @readytosend, @NoteToVendor, @test, 
        @InUse, @parentCrimID, @IrisFlag, @IrisOrdered, @Temporary, @CreatedDate,
        @IsCAMReview , @IsHidden , @IsHistoryRecord ,@AliasParentCrimID); 
      END
   END



select @cntTotalOrders = count(1) from crim where crimid = @crimid or 
 AliasParentCrimID = @crimid;

-- changing the clear status from R to temporary 'N'
-- and making it an unused record
IF ( (@cntTotalOrders > @cntName)  and @last = 0)
BEGIN 
   UPDATE crim SET [Clear] = 'N', IsHidden = 1
     WHERE crimid = @crimid;
END

End


End




