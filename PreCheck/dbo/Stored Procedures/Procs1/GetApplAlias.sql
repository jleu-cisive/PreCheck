
CREATE  PROCEDURE [dbo].[GetApplAlias](@APNO INT) AS
SET NOCOUNT ON
SELECT Alias=STUFF(' ;' + (SELECT ISNULL(Last,'') +', '+ ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Generation,'') + '; ' 
					FROM  ApplAlias AS A(NOLOCK)
					  where IsActive = 1 AND apno =@APNO AND A.IsPrimaryName=0
					FOR XML PATH('')), 1, 2, '') 

SET NOCOUNT OFF

	--GetApplAlias 3582983