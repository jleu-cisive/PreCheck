



-- =============================================
-- Author:		Najma Begum
-- Create date: 04/10/2013
-- Description:	Get drugscreen data
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetResults]
	-- Add the parameters for the stored procedure here
	@SSN varchar(25)='', @FN varchar(25),@LN varchar(25),
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	--History & latest
	SELECT RD.OrderIDOrApno,RD.ScreeningType,RD.DateReceived, RD.OrderStatus,RD.TestResult,Rd.TestResultDate, RD.LastUpdate, PDF.PDFReport from  OCHS_ResultDetails RD left join (Select TID, PDFReport, max(AddedOn) as LastUpdated from OCHS_PDFReports group by TID, PDFReport) PDF on RD.TID = PDF.TID and RD.LastUpdate = PDF.LastUpdated
    Where (RD.SSNOrOtherID = @SSN and RD.CLNO = @CLNO) OR (RD.FirstName = @FN and RD.LastName = @LN and CLNO = @CLNO) OR (RD.FullName = (@LN + ', ' + @FN) and RD.CLNO = @CLNO)

	-- 
	-- Add logic for getting single latest record.
	-- Insert statements for procedure here
	
	
END
