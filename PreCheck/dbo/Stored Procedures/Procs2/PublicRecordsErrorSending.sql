-- Alter Procedure PublicRecordsErrorSending
-- ============================================================
-- Author:	Prasanna
-- Requester: Jaret Vity
-- Create date: 10/24/2019
-- Description:	Public Records Error Sending
-- Execution: EXEC [dbo].[PublicRecordsErrorSending]  4824820,'10/01/2019','10/30/2019'
-- ==============================================================
CREATE PROCEDURE [dbo].[PublicRecordsErrorSending]
	@APNO int,
	@Startdate datetime,
	@enddate datetime

AS
SET NOCOUNT ON

BEGIN

	select a.apno as [Report Number],a.UserID as CAM,ra.Affiliate,a.ApDate,a.Last as [LastName], a.First as [FirstName],
	cnty.A_County + ', ' + cnty.State AS County,cr.Clear,isnull(cr.Ordered,cr.Crimenteredtime) as CrimEnteredDate FROM  Appl a(NOLOCK) 
	INNER JOIN Crim cr(NOLOCK) ON cr.APNO = a.APNO 	
	INNER JOIN crimsectstat css on css.crimsect = cr.[Clear]
	LEFT JOIN  dbo.TblCounties cnty(NOLOCK) ON cr.CNTY_NO = cnty.CNTY_NO
	LEFT JOIN Client c(NOLOCK) on c.CLNO= a.CLNO
	LEFT JOIN refAffiliate ra(NOLOCK) on ra.AffiliateID = c.AffiliateID
    WHERE cr.Clear in('E') AND ishidden = 0 AND a.APNO = IIF(@APNO = 0,a.APNO, @APNO) AND (isnull(cr.Ordered,cr.Crimenteredtime) >= @StartDate
    and isnull(cr.Ordered,cr.Crimenteredtime) <= @enddate) order by a.apno

END
