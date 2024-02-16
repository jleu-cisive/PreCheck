



-- =============================================
-- Author:		Najma Begum
-- Create date: 04/10/2013
-- Description:	Get drugscreen data
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_HasPDF]
	-- Add the parameters for the stored procedure here
	@Apno varchar(25)=null, @SSN varchar(25)='', @FN varchar(25) ='',@LN varchar(25) ='',
	@CLNO int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	--History & latest
	if exists (Select max(AddedOn) from OCHS_PDFReports p inner join  OCHS_ResultDetails r on r.TID = p.TID
    Where r.OrderIDOrApno = @Apno OR (REPLACE(r.SSNOrOtherID,'-','') = REPLACE(@SSN,'-','') and r.CLNO = @CLNO) OR (r.FirstName = @FN and r.LastName = @LN and r.CLNO = @CLNO) OR (r.FullName = (@LN + ', ' + @FN) and r.CLNO = @CLNO) group by p.PDFReport)
	BEGIN
	Select cast(1 as bit)
	END
	else
	Select cast(0 as bit)

	-- 
	-- Add logic for getting single latest record.
	-- Insert statements for procedure here
	
	
END