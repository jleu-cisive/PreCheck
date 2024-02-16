-- Alter Procedure Crim_Searches_in_MoreInfoStatus
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/27/2018
-- Description:	/*I need a Qreport that will allow me to pull reports that are "in progress" (P = app status) with a crim searches in a "More Information Needed" crim status.
-- The columns should include APNO, CAM, AppDate, LastName, FirstName, County, CrimStatus, MainPrivateNotes, CrimPrivateNotes.  No parameters are necessary. 
-- Please name the Qreport "Crim Searches in More Info Needed Status.
--The Crimstatus will be More Information Needed on all
--The MainPrivateNotes will be the main private notes copied from the front of the report in Oasis
--The CrimPrivateNotes will be the private notes copied from that specified criminal county search in the more info pending status.
-- =============================================
CREATE PROCEDURE dbo.Crim_Searches_in_MoreInfoStatus
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT  a.APNO, a.UserID, a.ApDate, a.[Last], a.[First], TblCounties.A_County + ', ' + TblCounties.State AS county, c.Clear as CrimStatus,
	a.Priv_Notes as 'MainPrivateNotes',	c.Priv_Notes as 'CrimPrivateNotes'
    FROM Crim c 
	INNER JOIN Appl a ON c.APNO = a.APNO
	INNER JOIN dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
	WHERE Apstatus in ('P', 'W')
	AND  c.Clear = 'P'
END
