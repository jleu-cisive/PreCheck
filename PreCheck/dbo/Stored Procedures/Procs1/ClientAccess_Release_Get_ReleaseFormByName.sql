




--EXEC [ClientAccess_Release_Get_ReleaseFormByName] 14380, 'Jennifer','Mitchell'
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 08-12-2008
-- Description:	 Gets release form info for the client when search by date
--Updated by: Radhika Dereddy on 10/30/2015 to get the releases from Archive
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Release_Get_ReleaseFormByName]
	@CLNO  INT,
	@FirstName varchar(20),
	@LastName varchar(20)
	
As

SELECT releaseformID,last, first, clno, ssn, date , EnteredVia, [HasApInfo] from

(

SELECT releaseformID,last, first, a.clno, ssn, date , EnteredVia,   (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from releaseform a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where last like (Replace(@LastName,'unknown9','') + '%') 
and first like ( Replace(@FirstName,'unknown9','')+ '%') 
and (a.clno = @CLNO or c.WebOrderParentCLNO = @CLNO or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno=(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 )))

UNION ALL


SELECT releaseformID,last, first, a.clno, ssn, date , EnteredVia,   (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from [Precheck_MainArchive].[dbo].[ReleaseForm_Archive] a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where last like (Replace(@LastName,'unknown9','') + '%') 
and first like ( Replace(@FirstName,'unknown9','')+ '%') 
and (a.clno = @CLNO or c.WebOrderParentCLNO = @CLNO or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno=(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 )))

)
 as T
order by releaseformID desc


SET ANSI_NULLS ON



