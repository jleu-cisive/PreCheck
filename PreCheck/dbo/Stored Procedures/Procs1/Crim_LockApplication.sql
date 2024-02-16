
/*
-- Modified By :	Deepak Vodethela	
-- Modified date:	01/11/2017
-- Description:	As part of Alias Logic Re-Write project all the Aliases will be from dbo.ApplAlias (Overflow table) and Sent Crims from ApplAlias_Sections
--Modified by Lalit on 17 july 2023 for #101849 
*/


CREATE PROCEDURE [dbo].[Crim_LockApplication]
(@DeliveryMethod varchar(25), @LockBy varchar(8))
AS
SET NOCOUNT ON

If @DeliveryMethod = 'WEB SERVICE'
	UPDATE dbo.Appl SET InUse = @LockBy WHERE APNO IN
	(
		SELECT APNO FROM iris_ws_new_orders
	)
	and Inuse is null
	
Else
	UPDATE A SET InUse = @LockBy 
	FROM dbo.Appl AS A 
	INNER JOIN dbo.Crim C WITH (NOLOCK) ON A.APNO = C.APNO 
	INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1
	INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
	LEFT OUTER JOIN dbo.Iris_Researchers IR WITH (NOLOCK) ON C.VendorID = IR.R_ID
	WHERE A.InUse IS NULL 
	  AND C.[Clear] = 'M' 
	  AND IR.R_Delivery = @DeliveryMethod
	  and (A.ApStatus = 'P' OR A.ApStatus = 'W')
	  and c.IsHidden<>1




SET NOCOUNT OFF




