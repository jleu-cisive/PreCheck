-- =============================================
-- Author:		Radhika Dereddy 
-- Create date: 01/30/2017
-- Description:	Change Log for Client Notes
-- =============================================
CREATE PROCEDURE ClientNotes_Changelog
	-- Add the parameters for the stored procedure here
	@StartDate Datetime,
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT * FROM CHANGELOG WHERE TABLENAME LIKE '%CLIENTNOTES%' AND ( CHANGEDATE >= @STARTDATE AND CHANGEDATE <@ENDDATE)

END
