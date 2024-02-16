



-- =============================================
-- Author:		Najma Begum
-- Create date: 03/09/2013
-- Description:	update processed xml response results from pembrooke website.
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_SaveResultDetails]
	-- Add the parameters for the stored procedure here
	@ProviderID varchar(25),@OrderID varchar(25) = '', @SSN varchar(25)='', @ScreeningType varchar(25)='',@FN varchar(25),@LN varchar(25),
	@FullName varchar(50), @OrderStatus varchar(25),@DateReceived datetime, @Content nvarchar(max), @TestResult varchar(25) = '',
	@ResultDate datetime, @Coc varchar(25) = '', @ReasonForTest varchar(25)='', @Clno int=0, @OTID int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	Declare @TID int;
	Select @TID = TID from OCHS_ResultDetails where ProviderID = @ProviderID;

	--Temporary workaround to fix the CLNO when the location has an '-'
	--schapyala/DHe on 02/21/17
	Declare @Location varchar(20),@locindex int
	If @CLNO = 0
		BEGIN
			WITH XMLNAMESPACES ('http://ns.hr-xml.org' as ns1)
			Select top 1 @location = XMLResponse.value('(//ns1:OrganizationalUnitId/ns1:IdValue[@name=''Location Number''])[1]','varchar(20)') 
			from dbo.OCHS_ResultsLog where ProviderID = @ProviderID order by ID desc

			select @locindex = charindex('-',@location,1)

			If @locindex>1
				Set @CLNO = left(@location,@locindex-1)

		END
	
	if(@TID is not null AND @TID <> 0)
		BEGIN
			UPDATE [dbo].[OCHS_ResultDetails]
			SET [ProviderID] = @ProviderID
			,[OrderIDOrApno] = @OrderID
			,[SSNOrOtherID] = @SSN
			,[ScreeningType] = @ScreeningType
			,[FirstName] = @FN
			,[LastName] = @LN
			,[FullName] = @FullName
			,[OrderStatus] = @OrderStatus
			,[DateReceived] = @DateReceived
			--,[PDFResult] = @Content
			,[TestResult] = @TestResult
			,[TestResultDate] = @ResultDate
			,[CoC] = @Coc
			,[ReasonForTest] = @ReasonForTest
			,[CLNO] = @Clno
			,LastUpdate = CURRENT_TIMESTAMP
			WHERE [TID] = @TID;
		END
	ELSE
		BEGIN
		INSERT INTO [dbo].[OCHS_ResultDetails]
           ([ProviderID]
           ,[OrderIDOrApno]
           ,[SSNOrOtherID]
           ,[ScreeningType]
           ,[FirstName]
           ,[LastName]
           ,[FullName]
           ,[OrderStatus]
           ,[DateReceived]
           ,[TestResult]
           ,[TestResultDate]
           ,[CoC]
           ,[ReasonForTest], CLNO)
     VALUES
           (@ProviderID
			,@OrderID
			,@SSN
			,@ScreeningType
			,@FN
			,@LN
			,@FullName
			,@OrderStatus
			,@DateReceived
			--,[PDFResult] = @Content
			,@TestResult
			, @ResultDate
			, @Coc
			,@ReasonForTest, @Clno)
			SELECT @TID =  CAST(scope_identity() AS int);
		END
	SET @OTID = @TID;
	-- If needed, must add logic to deduce Reason for a new version of PDF like test result change or name change etc..
	if(@Content is not null AND @Content <> '' AND @TID is not null AND @TID <> 0)
	BEGIN
--PK:06/03/2014 added condition to not to insert if it's a completed & Cancelled Studentcheck Report		
		--if not exists(select top 1 a.apno,a.EnteredVia,rd.OrderStatus,rd.TestResult from Appl a inner join OCHS_ResultDetails rd on a.apno = @OrderID where a.EnteredVia like'%StuWeb%' and rd.OrderStatus='Completed' and rd.TestResult='Cancelled' order by rd.LastUpdate desc)
		Declare @TblCompCancelledRec as table(apno int, EnteredVia varchar(25),OrderStatus varchar(25),TestResult varchar(25),LastUpdate datetime);

		INSERT INTO @TblCompCancelledRec(apno, EnteredVia,OrderStatus ,TestResult, LastUpdate)

		select top 1 a.apno,a.EnteredVia,rd.OrderStatus,rd.TestResult,rd.LastUpdate from OCHS_ResultDetails rd 
		inner join Appl a on rd.CLNO = a.CLNO where rd.OrderIDOrApno = @OrderID and a.EnteredVia like'%StuWeb%' order by LastUpdate desc

	--  7/14/2014 - Carlos - Removed join with AppNo because OrderIDorApno is not INT and Apno is int. 
	--	select top 1 a.apno,a.EnteredVia,rd.OrderStatus,rd.TestResult,rd.LastUpdate from OCHS_ResultDetails rd 
	--	inner join Appl a on rd.OrderIDOrApno = a.apno where rd.OrderIDOrApno = @OrderID and a.EnteredVia like'%StuWeb%' order by LastUpdate desc

	--	if not exists(select * from @TblCompCancelledRec where OrderStatus='Completed' and TestResult='Cancelled')
	-- 08/22/2018 - radhika dereddy - Added Adulterated as a conclusive status as per HDT 35886
	if ((select Count(1) from @TblCompCancelledRec where OrderStatus='Completed' and (TestResult='Cancelled' OR TestResult='Adulterated'))=0)
		BEGIN
			INSERT INTO [dbo].[OCHS_PDFReports]
				   ([TID]
				   ,[PDFReport]
				   ,[Reason]
				  )
			 VALUES
				   (@TID
				   ,@Content
				   ,@TestResult)
		 END
	--ELSE IF((select Count(1) from @TblCompCancelledRec where OrderStatus='InProgress' and TestResult='Adulterated')=0)
	--	BEGIN
	--		INSERT INTO [dbo].[OCHS_PDFReports]
	--				   ([TID]
	--				   ,[PDFReport]
	--				   ,[Reason]
	--				  )
	--			 VALUES
	--				   (@TID
	--				   ,@Content
	--				   ,@TestResult)
	--	END
	END

END





