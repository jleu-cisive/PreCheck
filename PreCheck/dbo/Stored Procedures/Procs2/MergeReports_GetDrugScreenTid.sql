-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/11/2017
-- Description:	Merge Reports Application refers to this stored procedure to get the
-- drug screen pdf when candidateinfoid is the orderidorapno
-- EXEC MergeReports_GetDrugScreenTid  3818147
-- =============================================
CREATE PROCEDURE [dbo].[MergeReports_GetDrugScreenTid]
	-- Add the parameters for the stored procedure here
	 @APNO int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
 Select p.TID from OCHS_PDFReports p inner join
 (
 Select TID From  OCHS_ResultDetails r inner join OCHS_CandidateInfo C on r.OrderIDOrApno = cast(C.apno as varchar) where C.APNO =@APNO
 UNION 
 Select TID From  OCHS_ResultDetails r inner join OCHS_CandidateInfo C on r.OrderIDOrApno = cast(C.OCHS_CandidateInfoID as varchar) where C.APNO =@APNO
 UNION
 Select TID From  OCHS_ResultDetails r where  isnull(r.OrderIDOrApno,'') = cast(@APNO as varchar)
 ) Qry on p.TID = Qry.TID
END
