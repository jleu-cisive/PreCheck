-- =============================================
-- Author:		Najma Begum
-- Create date: 09/26/2012
-- Description:	update processed xml response results from pembrooke website.
-- =============================================
CREATE PROCEDURE [dbo].[OccHealthServices_LogResults]
	-- Add the parameters for the stored procedure here
	@ResultID int,@ProviderID varchar(25),@OrderID varchar(25) = '', @SSN varchar(25)='', @ScreeningType varchar(25)='',@FN varchar(25),@LN varchar(25),
	@OrderStatus varchar(25),@DateReceived datetime, @Content nvarchar(max), @TestResult varchar(25) = '',
	@ResultDate datetime, @Coc varchar(25) = '', @ReasonForTest varchar(25)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE [dbo].[OccHealthServicesResultsLog]
   SET [ProviderID] = @ProviderID
      ,[OrderID] = @OrderID
      ,[SSNOrOtherID] = @SSN
      ,[ScreeningType] = @ScreeningType
      ,[FirstName] = @FN
      ,[LastName] = @LN
      ,[OrderStatus] = @OrderStatus
      ,[DateReceived] = @DateReceived
      ,[PDFResult] = @Content
      ,[TestResult] = @TestResult
      ,[ResultDate] = @ResultDate
      ,[ChainOfCustody] = @Coc
      ,[ReasonForTest] = @ReasonForTest
 WHERE [ID] = @ResultID;

END

