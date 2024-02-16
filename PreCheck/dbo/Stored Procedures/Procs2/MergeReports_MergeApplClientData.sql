-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/02/2017
-- Description:	Merge reports for ApplClientData
-- EXEC [MergeReports_MergeApplClientData] 3818147
-- =============================================
CREATE PROCEDURE [MergeReports_MergeApplClientData]
	-- Add the parameters for the stored procedure here
	@APNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select name as ClientName, (First + ' ' + Middle + ' ' + last) as ApplicantName, xmld 
	from ApplClientData 
	left join client on client.clno = ApplClientData.clno 
	inner join Appl on Appl.apno = ApplClientData.Apno
	where ApplClientData.apno = @APNO
END
