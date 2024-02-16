-- Alter Procedure Iris_GetNext_VendorReviewedCount


-- =============================================
-- Author:		<Bhavana Bakshi>
-- Create date: <05/13/2008>
-- Description:	<IRIS: Get next functionality>
-- =============================================
CREATE PROCEDURE [dbo].[Iris_GetNext_VendorReviewedCount](@getnext int =  null)

AS
BEGIN

	SET NOCOUNT ON;

if(@getnext = 1) --generic queue
BEGIN
     --VendorReviewedCount

   SELECT count(*) as  VendorReviewedCount
	FROM	Crim c
			INNER JOIN Appl a ON c.APNO = a.APNO
			INNER JOIN client cl ON a.CLNO = cl.CLNO
			INNER JOIN  dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
			INNER JOIN iris_researchers ir ON ir.r_id = c.vendorid
	WHERE	(c.iris_rec = 'yes') and (c.clear = 'V') and a.ApStatus in ('p', 'w', 'f') 
			AND R_Delivery <> 'WEB SERVICE'
			AND isnull(cl.clienttypeid,0) <> 15 

END


if(@getnext = 2)--integrated vendors queue
BEGIN
 --VendorReviewedCount
		SELECT count(*) as  VendorReviewedCount
			FROM	Crim c
					INNER JOIN Appl a ON c.APNO = a.APNO
					INNER JOIN client cl ON a.CLNO = cl.CLNO
					INNER JOIN  dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
					INNER JOIN iris_researchers ir ON ir.r_id = c.vendorid
			WHERE	(c.iris_rec = 'yes') and (c.clear = 'V') and a.ApStatus in ('p', 'w', 'f') 
					AND R_Delivery = 'WEB SERVICE'
					AND isnull(cl.clienttypeid,0) <> 15

END
if(@getnext = 3) --Resale queue
BEGIN
 --VendorReviewedCount


	SELECT count(*) as  VendorReviewedCount
	FROM	Crim c
			INNER JOIN Appl a ON c.APNO = a.APNO
			INNER JOIN client cl ON a.CLNO = cl.CLNO
			INNER JOIN  dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
			INNER JOIN iris_researchers ir ON ir.r_id = c.vendorid
	WHERE	(c.iris_rec = 'yes') and (c.clear = 'V') and a.ApStatus in ('p', 'w', 'f') 
			AND R_Delivery <> 'WEB SERVICE'
			AND isnull(cl.clienttypeid,0) = 15 


END

END
