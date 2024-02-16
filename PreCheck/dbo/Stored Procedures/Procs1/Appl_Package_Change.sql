-- =======================================================================================================
-- Created by  : Vairavan A
-- Create date : 07/17/2023
-- Ticket no   : 101230 
-- Description : Create QReport to identify Package Change on Report
/*---Testing
EXEC [dbo].[Appl_Package_Change] '2020-01-01','2020-12-30';
*/
-- =======================================================================================================

CREATE PROCEDURE dbo.Appl_Package_Change 
@StartDate date,
@EndDate date
AS
BEGIN
  SET NOCOUNT ON;

   Drop table if exists #apno
   Drop table if exists #tmp

  SELECT DISTINCT
    a.apno,
    a.ApDate,
    a.CreatedDate,
    a.EnteredVia,
    a.First,
    a.Last,
    a.ApStatus,
    a.clno,
    b.ID,
    b.OldValue,
    b.NewValue,
    b.ChangeDate,
    b.UserID INTO #apno
  FROM appl a WITH (NOLOCK)
  INNER JOIN ChangeLog b WITH (NOLOCK)
    ON (a.APNO = b.id
    AND b.tablename = 'Appl.Packageid'
    )
  WHERE ISNULL(a.ApDate, a.CreatedDate) BETWEEN @StartDate AND @EndDate


  SELECT
    a.APNO AS [Report Number],
    ISNULL(a.ApDate, a.CreatedDate) AS [Created Date],
    'Appl.PackageID' AS [TableName],
    OldValue AS [OldValue],
    CAST('' AS varchar(100)) AS OldName,
    NewValue AS [NewValue],
    CAST('' AS varchar(100)) AS NewName,
    a.ChangeDate,
    a.UserID,
    a.CLNO AS [Client ID],
    c.Name AS [Client Name],
    rf.AffiliateID AS [Affiliate ID],
    rf.Affiliate AS Affiliate,
    c.CAM AS [Client’s CAM],
    a.EnteredVia,
    a.First AS [First Name],
    a.Last AS [Last Name],
    a.ApStatus AS [Status] INTO #tmp
  FROM #apno a WITH (NOLOCK)
  INNER JOIN Client c WITH (NOLOCK)
    ON (a.CLNO = c.CLNO)
  INNER JOIN refAffiliate rf WITH (NOLOCK)
    ON (c.AffiliateID = rf.AffiliateID)

  UPDATE a
  SET a.OldName = pm.PackageDesc
  FROM #tmp a
  INNER JOIN PackageMain pm WITH (NOLOCK)
    ON (a.OldValue = pm.PackageID)

  UPDATE a
  SET a.NewName = pm.PackageDesc
  FROM #tmp a
  INNER JOIN PackageMain pm WITH (NOLOCK)
    ON (a.NewValue = pm.PackageID)

  SELECT
    *
  FROM #tmp;

  SET NOCOUNT OFF;
END