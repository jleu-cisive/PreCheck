-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/21/2018
-- Description:	 Marc Salinas - I would please like a new Q-Report created for the licensing module.
-- Create a Q-Report and add client affiliate name to better track HCA items.
-- Modified By Radhika Dereddy on 10/18/2019 to not include report which are IsHidden and IsOnReport is false for license
-- Modified By Doug DeGenaro on 10/22/2019 to also include pending per ticket 60571
--Modified by Sahithi on 02/14/2020 to add column organization HDT:67338
--Modified by Cameron DeCook on 8/2/2023 adding First, Last HDT#104571
-- =============================================
CREATE PROCEDURE [dbo].[ManagementReports_Licensing_Qreport] --'09/01/2019','10/21/2019'
    -- Add the parameters for the stored procedure here
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

    SELECT a.APNO,
           a.First,
           a.Last,
           a.ApDate,
           a.CLNO,
           C.Name,
           ra.Affiliate,
           ra.AffiliateID,
           a.UserID,
           pl.Investigator,
           pl.Organization,
           pl.Lic_Type,
           pl.State,
           a.ApStatus,
           ss.Description 'LicenseReportStatus',
           ws.description 'WebStatus',
           pl.Pub_Notes,
           pl.Priv_Notes
    FROM Appl a
        INNER JOIN Client C
            ON a.CLNO = C.CLNO
        INNER JOIN ProfLic pl
            ON a.APNO = pl.Apno
               AND
               (
                   (
                       pl.IsHidden = 1
                       AND pl.IsOnReport = 1
                   )
                   OR SectStat IN ( '9' )
               )
        INNER JOIN SectStat ss
            ON pl.SectStat = ss.Code
        INNER JOIN Websectstat ws
            ON pl.Web_status = ws.code
        INNER JOIN refAffiliate ra
            ON C.AffiliateID = ra.AffiliateID
    WHERE pl.CreatedDate >= @StartDate
          AND pl.CreatedDate <= DATEADD(s, -1, DATEADD(d, 1, @EndDate))
    ORDER BY a.ApDate ASC;

END;
