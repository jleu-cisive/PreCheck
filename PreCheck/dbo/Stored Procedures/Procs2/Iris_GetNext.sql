-- Alter Procedure Iris_GetNext





-- =============================================
-- Author:		<Bhavana Bakshi>
-- Create date: <05/13/2008>
-- Description:	<IRIS: Get next functionality>
-- =============================================
CREATE PROCEDURE [dbo].[Iris_GetNext](@getnext int = null)
AS
BEGIN

	SET NOCOUNT ON;


if(@getnext = 1) --generic queue
BEGIN
     --VendorReviewedCount
  

	SELECT  TOP 1 c.CrimID, c.APNO, c.irisordered,c.Clear, c.CNTY_NO, c.b_rule, c.Ordered,
			a.[First], 	a.Middle, a.[Last], c.County, c.batchnumber, 
			TblCounties.A_County,TblCounties.State,TblCounties.A_County + ', ' + TblCounties.State as zcounty,cl.clno
	FROM	Crim c
			INNER JOIN Appl a ON c.APNO = a.APNO
			INNER JOIN client cl ON a.CLNO = cl.CLNO
			INNER JOIN  dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
			INNER JOIN iris_researchers ir ON ir.r_id = c.vendorid
	WHERE	(c.iris_rec = 'yes') and (c.clear = 'V') and a.ApStatus in ('p', 'w', 'f') 
			-- AND c.deliverymethod = 'WEB SERVICE'
			AND R_Delivery <> 'WEB SERVICE'
			AND isnull(cl.clienttypeid,0) <> 15 
			AND isnull(a.Inuse,'')='' --Added by schapyala on 06/02/2011 to fine tune the get next
			ORDER BY a.apdate,c.apno,TblCounties.state,TblCounties.a_county
END


if(@getnext = 2)--integrated vendors queue
BEGIN
 --VendorReviewedCount

	SELECT  TOP 1 c.CrimID, c.APNO, c.irisordered,c.Clear, c.CNTY_NO, c.b_rule, c.Ordered,
				a.[First], 	a.Middle, a.[Last], c.County, c.batchnumber, 
				TblCounties.A_County,TblCounties.State,TblCounties.A_County + ', ' + TblCounties.State as zcounty
		FROM	Crim c
				INNER JOIN Appl a ON c.APNO = a.APNO
				INNER JOIN client cl ON a.CLNO = cl.CLNO
				INNER JOIN  dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
				INNER JOIN iris_researchers ir ON ir.r_id = c.vendorid
		WHERE	(c.iris_rec = 'yes') and (c.clear = 'V') and a.ApStatus in ('p', 'w', 'f') 
				-- AND c.deliverymethod = 'WEB SERVICE
				AND R_Delivery = 'WEB SERVICE'
				AND isnull(cl.clienttypeid,0) <> 15
				AND isnull(a.Inuse,'')=''
				ORDER BY a.apdate,c.apno,TblCounties.state,TblCounties.a_county


END
if(@getnext = 3) --Resale queue
BEGIN
 --VendorReviewedCount
	SELECT  TOP 1 c.CrimID, c.APNO, c.irisordered,c.Clear, c.CNTY_NO, c.b_rule, c.Ordered,
					a.[First], 	a.Middle, a.[Last], c.County, c.batchnumber, 
					TblCounties.A_County,TblCounties.State,TblCounties.A_County + ', ' + TblCounties.State as zcounty
		FROM	Crim c
					INNER JOIN Appl a ON c.APNO = a.APNO
					INNER JOIN client cl ON a.CLNO = cl.CLNO
					INNER JOIN  dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
					INNER JOIN iris_researchers ir ON ir.r_id = c.vendorid
		WHERE	(c.iris_rec = 'yes') and (c.clear = 'V') and a.ApStatus in ('p', 'w', 'f') 
					-- AND c.deliverymethod = 'WEB SERVICE'
					AND R_Delivery <> 'WEB SERVICE'
					AND isnull(cl.clienttypeid,0) = 15 --for Resale clienttype
					AND isnull(a.Inuse,'')=''
					ORDER BY a.apdate,c.apno,TblCounties.state,TblCounties.a_county


END

END
