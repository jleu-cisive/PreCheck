 
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 -- =============================================
-- Edited by :		kiran miryala
-- Edited date: 5/16/2012
-- Description:	 1. Added Insert into ApplAddress and ApplicantCrim table
--				 2. Auto close Drugscreening only Apps
--Modified By: Radhika Dereddy
--Modified Date: 07/21/2016
--Description: 1. Auto Close Immunization only apps (refPackageTypeID = 5)
-- Modified By & Date : Radhika Dereddy 08/03/2016
-- Description: 2. Auto Close Drug Screening & immunization only apps (refPackageTypeID = 6)
-- =============================================


CREATE PROCEDURE [dbo].[InsertApplStudentCheck]

(

      @ApStatus char(1)

      , @UserID varchar(8)

      , @Billed bit

      --, @Investigator varchar(8)

      -- , @EnteredBy varchar(8)

      , @EnteredVia varchar(8)

      , @ApDate datetime

      --, @CompDate datetime

      , @Clno smallint

      , @ClientProgramID int

      , @PackageID int = null

      --, @Attn varchar(25)

      , @Last varchar(20)

      , @First varchar(20)

      , @Middle varchar(20)

      , @Alias1_Last varchar(20) = NULL

      , @Alias1_First varchar(20) = NULL

      , @Alias1_Middle varchar(20) = NULL

      , @Alias2_Last varchar(20) = NULL

      , @Alias2_First varchar(20) = NULL

      , @Alias2_Middle varchar(20) = NULL

      , @Alias3_Last varchar(20) = NULL

      , @Alias3_First varchar(20) = NULL

      , @Alias3_Middle varchar(20) = NULL

      , @Alias4_Last varchar(20) = NULL

      , @Alias4_First varchar(20) = NULL

      , @Alias4_Middle varchar(20) = NULL

      --, @Alias varchar(30)

      --, @Alias2 varchar(30)

      --, @Alias3 varchar(30)

      --, @Alias4 varchar(30)

      , @SSN varchar(11)

      , @i94 varchar(50)

      , @DOB datetime

      --, @Sex varchar(1)

      --, @Addr_Num varchar(6)

      --, @Addr_Dir varchar(2)

      , @Addr_Street varchar(100)

      --, @Addr_StType varchar(2)

      --, @Addr_Apt varchar(5)

      , @City varchar(16)

      , @State varchar(2)

      , @Zip varchar(5)

      , @DLnumber varchar(20)

      , @DLState Varchar(2)

 

,@res_add_1 varchar(200) = NULL

,@res_city_1 varchar(50) = NULL

,@res_state_1 varchar(20) = NULL

,@res_zip_1 varchar(10) = NULL

,@res_Country_1 varchar(50) = NULL

 

,@res_add_2 varchar(200) = NULL

,@res_city_2 varchar(50) = NULL

,@res_state_2 varchar(20) = NULL

,@res_zip_2 varchar(10) = NULL

,@res_Country_2 varchar(50) = NULL

 

,@res_add_3 varchar(200) = NULL

,@res_city_3 varchar(50) = NULL

,@res_state_3 varchar(20) = NULL

,@res_zip_3 varchar(10) = NULL

,@res_Country_3 varchar(50) = NULL

 

,@res_add_4 varchar(200) = NULL

,@res_city_4 varchar(50) = NULL

,@res_state_4 varchar(20) = NULL

,@res_zip_4 varchar(10) = NULL

,@res_Country_4 varchar(50) = NULL

 

,@res_add_5 varchar(200) = NULL

,@res_city_5 varchar(50) = NULL

,@res_state_5 varchar(20) = NULL

,@res_zip_5 varchar(10) = NULL

,@res_Country_5 varchar(50) = NULL

 

,@res_add_6 varchar(200) = NULL

,@res_city_6 varchar(50) = NULL

,@res_state_6 varchar(20) = NULL

,@res_zip_6 varchar(10) = NULL

,@res_Country_6 varchar(50) = NULL

 

,@res_add_7 varchar(200) = NULL

,@res_city_7 varchar(50) = NULL

,@res_state_7 varchar(20) = NULL

,@res_zip_7 varchar(10) = NULL

,@res_Country_7 varchar(50) = NULL

 

,@crimQuestion varchar(10) = NULL

,@Crim_County_1 varchar(50) = NULL

,@crim_state_1 varchar(50) = NULL

,@crim_country_1 varchar(50) = NULL

,@crim_date_1 varchar(50) = NULL

,@crim_offense_1 varchar(50) = NULL

 

,@Crim_County_2 varchar(50) = NULL

,@crim_state_2 varchar(50) = NULL

,@crim_country_2 varchar(50) = NULL

,@crim_date_2 varchar(50) = NULL

,@crim_offense_2 varchar(50) = NULL

 

,@Crim_County_3 varchar(50) = NULL

,@crim_state_3 varchar(50) = NULL

,@crim_country_3 varchar(50) = NULL

,@crim_date_3 varchar(50) = NULL

,@crim_offense_3 varchar(50) = NULL

 

,@Crim_County_4 varchar(50) = NULL

,@crim_state_4 varchar(50) = NULL

,@crim_country_4 varchar(50) = NULL

,@crim_date_4 varchar(50) = NULL

,@crim_offense_4 varchar(50) = NULL

 

,@Crim_County_5 varchar(50) = NULL

,@crim_state_5 varchar(50) = NULL

,@crim_country_5 varchar(50) = NULL

,@crim_date_5 varchar(50) = NULL

,@crim_offense_5 varchar(50) = NULL

 

 


 

      --, @Pos_Sought varchar(25)

      , @Update_Billing bit

      , @Priv_Notes text

      , @Pub_Notes text

      , @PrecheckChallenge bit

      , @NeedsReview varchar(2)

      ,@Email varchar(100) = NULL

      , @Phone varchar(50)

      , @Rush bit

      , @IsAutoPrinted bit

      , @IsAutoSent bit

      , @CreatedDate datetime

      , @AppExist int

      , @OrigAPNO int output

      , @OrigApdate datetime output

      , @APNO int output

)

AS

SET NOCOUNT ON

 

DECLARE @checkStatus varchar(1)

 

-- CAM is set for each app -- kiran 6/24/2004

SELECT  @UserID =C.CAM FROM CLIENT C  WHERE C.CLNO= @Clno

--- get refPackageTypeID  for drugscreening only package
DECLARE @refPackageTypeID varchar(1),@PackageID2 int,@investigator varchar(8),@CompDate datetime, @OrigCompDate datetime
--

set @investigator = NULL
set @CompDate = NULL
set @OrigCompDate = NULL



SELECT  @PackageID2 = pm.PackageID, @refPackageTypeID=isnull(pm.refPackageTypeID,0)
FROM         dbo.Client c inner join  dbo.ClientPackages cp on C.CLNO = CP.CLNO
inner join  dbo.PackageMain pm on CP.PackageID = pm.PackageID
WHERE  C.CLNO= @Clno and  (pm.PackageID = @PackageID or @PackageID = 0) and cp.IsActive =1

set @PackageID = @PackageID2

--For the Package type 'Drug Screening Only' (refpackagetypeId = 4) Auto close
if isnull(@refPackageTypeID,0) = '4'
begin
set @NeedsReview = 'S4'
set @investigator = 'DSOnly'

	if @ApStatus = 'P'
	Begin 
		set  @ApStatus = 'F'
			set @CompDate= @ApDate--dateadd(m,5,@ApDate)
			set @OrigCompDate = @ApDate--dateadd(m,5,@ApDate)
	End

end
 
--For the Package type 'Immunization Tracking Only' (refpackagetypeId = 5) Auto close
if isnull(@refPackageTypeID,0) = '5'
Begin
	set @NeedsReview = 'S4'
	set @investigator = 'Immuniz'

		if @ApStatus = 'P'
		Begin 
			set  @ApStatus = 'F'
				set @CompDate= @ApDate--dateadd(m,5,@ApDate)
				set @OrigCompDate = @ApDate--dateadd(m,5,@ApDate)
		End
End

--For the Package type 'Drug Screening & Immunization Tracking' (refpackagetypeId = 6) Auto close
if isnull(@refPackageTypeID,0) = '6'
Begin
	set @NeedsReview = 'S4'
	set @investigator = 'DSImmu'

		if @ApStatus = 'P'
		Begin 
			set  @ApStatus = 'F'
				set @CompDate= @ApDate--dateadd(m,5,@ApDate)
				set @OrigCompDate = @ApDate--dateadd(m,5,@ApDate)
		End
End

SET @OrigAPNO = 0

IF @AppExist = -1 --if we need to check the existing application

 

      BEGIN

                  --get duplicate app( should pick up the latest app)

                  SELECT  @OrigAPNO = apno, @OrigApdate = convert(varchar,isnull(Appl.CreatedDate,Appl.apdate),0), @checkStatus = Apstatus 

                  FROM appl

                  WHERE   (ssn = @SSN AND i94 = @i94)

                              AND DOB = @DOB

                              AND CLNO = @CLNO

                              AND ClientProgramID = @ClientProgramID

                              AND enteredvia='stuweb'

                              AND  isnull(Appl.CreatedDate,Appl.apdate)  >= DateAdd(dd,-1,getdate()) 

                  ORDER BY Appl.CreatedDate

 

            END   

 

 

IF @OrigAPNO >0 --app exists

      BEGIN

      --    SELECT @OrigApdate = (SELECT  convert(varchar,isnull(Appl.CreatedDate,Appl.apdate),0)  as 'Apdate' from appl where apno = @OrigAPNO)

            SET @APNO = -1 

 

 

-- This is a very rare scenario( if user submits the first app by money order and then decides to submit using CC and hits on refresh while submiting)

            IF @checkStatus = 'M' 

                  BEGIN

                        UPDATE Appl SET apstatus = @Apstatus,apdate=@ApDate WHERE apno = @OrigAPNO

                  END

      END

ELSE

      BEGIN

          IF @ApDate IS NOT NULL
			BEGIN
				INSERT INTO dbo.Appl 
					(ApStatus, UserID,Billed, EnteredVia, ApDate, Clno, ClientProgramID, PackageID, Last, First, Middle
					 , Alias1_Last, Alias1_First, Alias1_Middle, Alias2_Last, Alias2_First, Alias2_Middle
					 , Alias3_Last, Alias3_First, Alias3_Middle, Alias4_Last, Alias4_First, Alias4_Middle
					 , SSN, DOB, Addr_Street, City, State, Zip, DL_State, DL_Number,  Update_Billing
					 , Priv_Notes, Pub_Notes, NeedsReview, PrecheckChallenge, Phone, Rush, IsAutoPrinted, IsAutoSent
					 , i94, CreatedDate,Email,Investigator,CompDate,OrigCompDate)
				VALUES
					(@ApStatus, @UserID, @Billed, @EnteredVia, @ApDate, @Clno, @ClientProgramID, @PackageID, @Last, @First, @Middle
					 , @Alias1_Last, @Alias1_First, @Alias1_Middle, @Alias2_Last, @Alias2_First, @Alias2_Middle
					 , @Alias3_Last, @Alias3_First, @Alias3_Middle, @Alias4_Last, @Alias4_First, @Alias4_Middle
					 , @SSN, @DOB, @Addr_Street, @City, @State, @Zip, @DLState, @DLnumber, @Update_Billing
					 , @Priv_Notes, @Pub_Notes, @NeedsReview, @PrecheckChallenge, @Phone, @Rush, @IsAutoPrinted, @IsAutoSent
					 , @i94, @CreatedDate,@Email,@investigator,@CompDate,@OrigCompDate)
			END
		ELSE
			BEGIN
				INSERT INTO dbo.Appl
					(ApStatus, UserID,Investigator,Billed, EnteredVia, Clno, ClientProgramID, PackageID, Last, First, Middle
					 , Alias1_Last, Alias1_First, Alias1_Middle, Alias2_Last, Alias2_First, Alias2_Middle
					 , Alias3_Last, Alias3_First, Alias3_Middle, Alias4_Last, Alias4_First, Alias4_Middle
					 , SSN, DOB, Addr_Street, City, State, Zip, DL_State, DL_Number, Update_Billing, Priv_Notes, Pub_Notes
					 , NeedsReview, PrecheckChallenge, Phone, Rush, IsAutoPrinted, IsAutoSent, i94, CreatedDate,Email,CompDate,OrigCompDate)
				VALUES
					(@ApStatus, @UserID,@investigator, @Billed, @EnteredVia, @Clno, @ClientProgramID, @PackageID, @Last, @First, @Middle
					 , @Alias1_Last, @Alias1_First, @Alias1_Middle, @Alias2_Last, @Alias2_First, @Alias2_Middle
					 , @Alias3_Last, @Alias3_First, @Alias3_Middle, @Alias4_Last, @Alias4_First, @Alias4_Middle
					 , @SSN, @DOB, @Addr_Street, @City, @State, @Zip,@DLState, @DLnumber, @Update_Billing, @Priv_Notes, @Pub_Notes
					 , @NeedsReview, @PrecheckChallenge, @Phone, @Rush, @IsAutoPrinted, @IsAutoSent, @i94, @CreatedDate,@Email,@CompDate,@OrigCompDate)
			END
		
            

            SET @APNO = @@IDENTITY

 
					IF (@res_add_1 IS NOT NULL AND @res_add_1 <>'') or (@res_city_1 IS NOT NULL AND @res_city_1 <>'') or (@res_state_1 IS NOT NULL AND @res_state_1 <>'') or (@res_zip_1 IS NOT NULL AND @res_zip_1 <>'') or (@res_Country_1 IS NOT NULL AND @res_Country_1 <>'')


                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_1,@res_city_1,@res_state_1,@res_zip_1,@res_Country_1,'StuWeb')

 

                  End

                   IF (@res_add_2 IS NOT NULL AND @res_add_2 <>'') or (@res_city_2 IS NOT NULL AND @res_city_2 <>'') or (@res_state_2 IS NOT NULL AND @res_state_2 <>'') or (@res_zip_2 IS NOT NULL AND @res_zip_2 <>'') or (@res_Country_2 IS NOT NULL AND @res_Country_2 <>'')



                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_2,@res_city_2,@res_state_2,@res_zip_2,@res_Country_2,'StuWeb')

 

                  End

                  IF (@res_add_3 IS NOT NULL AND @res_add_3 <>'')or (@res_city_3 IS NOT NULL AND @res_city_3 <>'')or (@res_state_3 IS NOT NULL AND @res_state_3 <>'') or (@res_zip_3 IS NOT NULL AND @res_zip_3 <>'')  or (@res_Country_3 IS NOT NULL AND @res_Country_3 <>'')



                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_3,@res_city_3,@res_state_3,@res_zip_3,@res_Country_3,'StuWeb')

 

                  End

                 IF (@res_add_4 IS NOT NULL AND @res_add_4 <>'') or (@res_city_4 IS NOT NULL AND @res_city_4 <>'')  or (@res_state_4 IS NOT NULL AND @res_state_4 <>'')  or (@res_zip_4 IS NOT NULL AND @res_zip_4 <>'') or (@res_Country_4 IS NOT NULL AND @res_Country_4 <>'')


                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_4,@res_city_4,@res_state_4,@res_zip_4,@res_Country_4,'StuWeb')

 

                  End

                  IF (@res_add_5 IS NOT NULL AND @res_add_5 <>'')  or (@res_city_5 IS NOT NULL AND @res_city_5 <>'')  or (@res_state_5 IS NOT NULL AND @res_state_5 <>'')  or (@res_zip_5 IS NOT NULL AND @res_zip_5 <>'') or (@res_Country_5 IS NOT NULL AND @res_Country_5 <>'')



                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_5,@res_city_5,@res_state_5,@res_zip_5,@res_Country_5,'StuWeb')

 

                  End

                 IF (@res_add_6 IS NOT NULL AND @res_add_6 <>'')  or (@res_city_6 IS NOT NULL AND @res_city_6 <>'')  or (@res_state_6 IS NOT NULL AND @res_state_6 <>'')  or (@res_zip_6 IS NOT NULL AND @res_zip_6 <>'') or (@res_Country_6 IS NOT NULL AND @res_Country_6 <>'')


                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_6,@res_city_6,@res_state_6,@res_zip_6,@res_Country_6,'StuWeb')

 

                  End

                  IF (@res_add_7 IS NOT NULL AND @res_add_7 <>'')  or (@res_city_7 IS NOT NULL AND @res_city_7 <>'')  or (@res_state_7 IS NOT NULL AND @res_state_7 <>'')  or (@res_zip_7 IS NOT NULL AND @res_zip_7 <>'') or (@res_Country_7 IS NOT NULL AND @res_Country_7 <>'')

 



                  BEGIN

                        INSERT INTO [dbo].[ApplAddress]

                           ([APNO]

                           ,[Address]

                           ,[City]

                           ,[State]

                           ,[Zip]

                           ,[Country]

                           ,[Source])

                        VALUES

                              (@APNO,@res_add_7,@res_city_7,@res_state_7,@res_zip_7,@res_Country_7,'StuWeb')

 

                  End

 

if @crimQuestion ='Yes' 

Begin

INSERT INTO [PreCheck].[dbo].[ApplAdditionalData]
           ([CLNO]
           ,[APNO]
           ,[SSN]
           ,[Crim_SelfDisclosed]
           --,[Empl_CanContactPresentEmployer]
           ,[DataSource]
           ,[DateCreated])
     VALUES
           (@Clno,@APNO,@SSN,1,'StuWeb',getdate())

            IF (@Crim_County_1 IS NOT NULL AND @Crim_County_1 <>'')  or (@crim_state_1 IS NOT NULL AND @crim_state_1 <>'') or (@crim_country_1 IS NOT NULL AND @crim_country_1 <>'') or (@crim_date_1 IS NOT NULL AND @crim_date_1 <>'')  or (@crim_offense_1 IS NOT NULL AND @crim_offense_1 <>'')


                  Begin

                        INSERT INTO [dbo].[ApplicantCrim]

                           ([APNO]

                           ,[City]

                           ,[State]

                           ,[Country]

                           ,[CrimDate]

                           ,[Offense]

                           ,[Source])

                   VALUES

                              (@APNO,@Crim_County_1,@crim_state_1,@crim_country_1,@crim_date_1,@crim_offense_1,'StuWeb')

 

                  End

                  

            IF (@Crim_County_2 IS NOT NULL AND @Crim_County_2 <>'') or (@crim_state_2 IS NOT NULL AND @crim_state_2 <>'')  or (@crim_country_2 IS NOT NULL AND @crim_country_2 <>'')  or (@crim_date_2 IS NOT NULL AND @crim_date_2 <>'') or (@crim_offense_2 IS NOT NULL AND @crim_offense_2 <>'')



                  Begin

                        INSERT INTO [dbo].[ApplicantCrim]

                           ([APNO]

                           ,[City]

                           ,[State]

                           ,[Country]

                           ,[CrimDate]

                           ,[Offense]

                           ,[Source])

                   VALUES

                              (@APNO,@Crim_County_2,@crim_state_2,@crim_country_2,@crim_date_2,@crim_offense_2,'StuWeb')

 

                  End

 

            IF (@Crim_County_3 IS NOT NULL AND @Crim_County_3 <>'')  or (@crim_state_3 IS NOT NULL AND @crim_state_3 <>'')  or (@crim_country_3 IS NOT NULL AND @crim_country_3 <>'')  or (@crim_date_3 IS NOT NULL AND @crim_date_3 <>'')  or (@crim_offense_3 IS NOT NULL AND @crim_offense_3 <>'')

                    Begin

                        INSERT INTO [dbo].[ApplicantCrim]

                           ([APNO]

                           ,[City]

                           ,[State]

                           ,[Country]

                           ,[CrimDate]

                           ,[Offense]

                           ,[Source])

                   VALUES

                              (@APNO,@Crim_County_3,@crim_state_3,@crim_country_3,@crim_date_3,@crim_offense_3,'StuWeb')

 

                  End

 

            IF (@Crim_County_4 IS NOT NULL AND @Crim_County_4 <>'') or (@crim_state_4 IS NOT NULL AND @crim_state_4 <>'')  or (@crim_country_4 IS NOT NULL AND @crim_country_4 <>'') or (@crim_date_4 IS NOT NULL AND @crim_date_4 <>'')  or (@crim_offense_4 IS NOT NULL AND @crim_offense_4 <>'')



                  Begin

                        INSERT INTO [dbo].[ApplicantCrim]

                           ([APNO]

                           ,[City]

                           ,[State]

                           ,[Country]

                           ,[CrimDate]

                           ,[Offense]

                           ,[Source])

                   VALUES

                              (@APNO,@Crim_County_4,@crim_state_4,@crim_country_4,@crim_date_4,@crim_offense_4,'StuWeb')

 

                  End

 

            IF (@Crim_County_5 IS NOT NULL AND @Crim_County_5 <>'')  or (@crim_state_5 IS NOT NULL AND @crim_state_5 <>'') or (@crim_country_5 IS NOT NULL AND @crim_country_5 <>'') or (@crim_date_5 IS NOT NULL AND @crim_date_5 <>'')  or (@crim_offense_5 IS NOT NULL AND @crim_offense_5 <>'')

 



                  Begin

                        INSERT INTO [dbo].[ApplicantCrim]

                           ([APNO]

                           ,[City]

                           ,[State]

                           ,[Country]

                           ,[CrimDate]

                           ,[Offense]

                           ,[Source])

                   VALUES

                              (@APNO,@Crim_County_5,@crim_state_5,@crim_country_5,@crim_date_5,@crim_offense_5,'StuWeb')

 

                  End

 

End

 

 

      

            --Added to work for HGC....Change the hardcoding to use a flag from the client table

            --schapyala 09/25/06

            IF @Clno = 5199

            BEGIN

                  UPDATE dbo.ApplStudentAction 

                  SET Apno = @APNO

                  WHERE SSN = @SSN

                        AND CLNO_Hospital IN (SELECT CLNO_Hospital FROM dbo.ClientSchoolHospital WHERE CLNO_School = @clno)

                        AND Apno IS NULL

            END

END --end of else @OrigAPNO >0

 

SET NOCOUNT ON

 

 

 








