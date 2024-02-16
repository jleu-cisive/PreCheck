

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheck_GetPAckages] 
@CLNO int
	

As

SELECT ClientPackages.PackageID, PackageMain.PackageDesc ,ClientPackages.Rate ,IsActive   
FROM ClientPackages INNER JOIN PackageMain ON PackageMain.PackageID = ClientPackages.PackageID  
WHERE ClientPackages.CLNO = @CLNO and IsActive=1
ORDER BY PackageMain.PackageDesc

