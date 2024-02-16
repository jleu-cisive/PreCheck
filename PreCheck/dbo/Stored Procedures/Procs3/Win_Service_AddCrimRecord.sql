-- Alter Procedure Win_Service_AddCrimRecord

	CREATE PROCEDURE [dbo].[Win_Service_AddCrimRecord] 
       -- Add the parameters for the stored procedure here
       @Apno INT, @ClearStatus VARCHAR(1), @CntyNo INT,
       @Aliases NVARCHAR(200)
	AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		Declare @County nvarchar(50);
		DECLARE @CrimId int --dhe added on 08/20/2019 for ZipCrim

		/* [Deepak] -- Added the below statements to check the inserts for CORI
		BEGIN TRY
			DECLARE @Message Varchar(100) 
			SELECT @Message = CONCAT('APNO:', @Apno , ' ClearStatus: ', @ClearStatus , ' CntyNo: ', @CntyNo)

			EXEC [Enterprise].[Job].[WriteToTraceLog] 'APP',  '[Win_Service_AddCrimRecord]', @Message, 'Info'

		END TRY
		BEGIN CATCH
		END CATCH
		*/

		-- 05/02/2017 - Deepak --> Added condition to check if same county exists in Crim Table.
		-- Do not duplicate the county if county already exists
		SELECT @CrimId = CrimId FROM CRIM(NOLOCK) WHERE APNO = @Apno AND CNTY_NO = @CntyNo --Changed by dhe for ZipCrim integration --dhe added on 08/20/2019 for ZipCrim
		IF (@CrimId is null)
		BEGIN
			-- Insert statements for procedure here
			SET @County = (SELECT TOP 1 case when isnull(County,'')='' then  (A_County + ', ' + State ) else County end  as County FROM dbo.TblCounties WHERE CNTY_NO = @CntyNo);

			Declare @vendorid nvarchar(50);
			Declare @deliverymethod nvarchar(50);

			-- Get the VendorID and Delivery Method
			SELECT  @vendorid = R_id, @deliverymethod = R_Delivery 
			FROM Iris_Researchers (NOLOCK)
			INNER JOIN Iris_Researcher_Charges(NOLOCK) on R_id = Researcher_id
			WHERE Researcher_Default = 'Yes' 
			  AND CNTY_NO = @CntyNo;

			INSERT INTO dbo.Crim (Apno,County,[Clear],CNTY_NO,IRIS_REC,IrisFlag, b_rule,Disp_Date,Date_Filed,DOB,readytosend,IsCAMReview,IsHidden,IsHistoryRecord,Crimenteredtime,Last_Updated, Crim_SpecialInstr,vendorid,deliverymethod) 
			VALUES(@Apno, @County, @ClearStatus,@CntyNo,'Yes','1','No',NUll,Null,Null,0,0,0,0,getdate(), getdate(), Null,@vendorid,@deliverymethod);

			SELECT Cast(@@IDENTITY as Int)  --Added by dhe for ZipCrim integration
		END

			--values(@Apno, @County, @ClearStatus,@CntyNo,'Yes','1','No',NUll,Null,Null,0,0,0,0,getdate(), getdate(), @Aliases,@vendorid,@deliverymethod);

			--    Declare @Special_instructions nvarchar(4000); 
			--SELECT @Special_instructions = special_instructions from Appl where apno=@Apno and Special_instructions  like '%Aditional Aliases%';

			--if (len(isnull(@Special_instructions,')) < 1 and len(isnull(@Aliases,')) >0 )
			--  update appl set Special_instructions = CONCAT(Special_Instructions,' Aditional Aliases -', @Aliases) where apno=@Apno;

		select @CrimId  --dhe added on 08/20/2019 for ZipCrim
	 
	   END
