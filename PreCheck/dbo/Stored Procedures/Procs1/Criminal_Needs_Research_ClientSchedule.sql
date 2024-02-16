-- Alter Procedure Criminal_Needs_Research_ClientSchedule
-- =============================================
-- Author: Radhika Dereddy
-- Requester: Misty Smallwood
-- Create date: 02/09/2021
-- Description:	To get the details of Vendors and their Auto Pay Volume and Price
-- Execution: EXEC [dbo].[Criminal_Needs_Research_ClientSchedule]  'Msmallwo',NULL,NULL,NULL
--			  EXEC [dbo].[Criminal_Needs_Research_ClientSchedule]  'ppaz','Z',NULL,NULL
--			  EXEC [dbo].[Criminal_Needs_Research_ClientSchedule]]  NULL,NULL,'BROWARD','FL'
--			  EXEC [dbo].[Criminal_Needs_Research_ClientSchedule]  NULL,NULL,NULL,'FL'
--			  EXEC [dbo].[Criminal_Needs_Research_ClientSchedule] NULL,NULL,NULL,NULL
-- =============================================
CREATE PROCEDURE [dbo].[Criminal_Needs_Research_ClientSchedule]
	-- Add the parameters for the stored procedure here
	@Investigator varchar(8),
	@CrimStatus varchar(50),
	@County varchar(40),
	@State varchar(25)
AS
SET NOCOUNT ON

IF LEN(LTRIM(RTRIM(@Investigator))) = 0 
	SET @Investigator = NULL

IF LEN(LTRIM(RTRIM(@CrimStatus))) = 0 
	SET @CrimStatus = NULL

IF LEN(LTRIM(RTRIM(@County))) = 0 
	SET @County = NULL

IF LEN(LTRIM(RTRIM(@State))) = 0 
	SET @State = NULL


SELECT  a.apno AS APNO,c.Ordered AS CriminalSearchDate, Replace(CC.County,',',' ') AS County,CC.[State] AS [State],
--Replace(REPLACE(LEFT(c.Priv_Notes,32766), char(10),';'),char(13),';') as  [Private Notes], 
Replace(ra.Affiliate,',',' ')  as [Affiliate Name], Replace(client.Name,',',' ') as [Client Name], client.CAM, ase.ETADate as ETA,
a.ApDate, CS.crimdescription AS CrimStatus, L.UserID AS Investigator
FROM appl a WITH (NOLOCK)
INNER JOIN crim c WITH (NOLOCK) ON a.apno = c.apno
INNER JOIN Client client WITH (NOLOCK) ON client.CLNO = a.CLNO
INNER JOIN refAffiliate ra WITH (NOLOCK) ON ra.AffiliateID = client.AffiliateID
LEFT JOIN ApplSectionsETA ase WITH (NOLOCK) on ase.apno = c.apno and ase.SectionKeyID = c.CrimID
INNER JOIN dbo.TblCounties AS CC WITH(NOLOCK) ON CC.cnty_no = C.cnty_no
INNER JOIN Crimsectstat AS CS(NOLOCK) ON C.[Clear] = CS.crimsect
LEFT OUTER JOIN dbo.ChangeLog AS L WITH(NOLOCK) ON L.ID = C.CrimID AND L.TableName LIKE '%Crim.Clear%' AND L.NewValue IN ('Z')
WHERE ISNULL(a.apstatus,'P') IN ('P','W')
  and c.clear IN ('Z')
  and c.ishidden = 0
  AND (@CrimStatus IS NULL OR C.Clear LIKE '%' + @CrimStatus + '%')
 AND (@County IS NULL OR C.County LIKE '%' + @County + '%')
 and CC.[State] = IIF(@State IS NULL, CC.[State], @State)
 AND (@Investigator IS NULL OR L.UserID = @Investigator)
  -- Commented the below conditions by Radhika Dereddy on 02/01/2021
  --AND (@CrimStatus IS NULL OR C.Clear LIKE '%' + @CrimStatus + '%')
  --AND (@County IS NULL OR C.County LIKE '%' + @County + '%')
  --AND (@State IS NULL OR CC.[State] = @State)
--  AND LEN(Replace(REPLACE(LEFT(c.Priv_Notes,32766) , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/11/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.
GROUP BY a.apno,c.Ordered,CC.County,CC.[State],
--c.Priv_Notes,
ra.Affiliate,client.Name, client.CAM,a.ApDate,L.UserID,
CS.crimdescription,c.Crimenteredtime, ase.ETADate
