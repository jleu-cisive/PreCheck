




-- EXEC [ClientAccess_Get_ReleaseFormBySSN] 8424, '462995368'
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 08-12-2008
-- Description:	 Gets release form info for the client when search by SSN
--Updated by: Radhika Dereddy on 10/30/2015 to get the releases from Archive
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Release_Get_ReleaseFormBySSN]
	@CLNO  INT,
	@SSN varchar(11)
	
As

SELECT releaseformID,last, first, clno, ssn, date , EnteredVia, [HasApInfo] from

(
SELECT releaseformID,last, first, a.clno, ssn, date , EnteredVia,  (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from releaseform a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where replace(ssn,'-','') = replace(@SSN,'-','') 
and (a.clno = @CLNO or isnull(c.WebOrderParentCLNO,0) = @CLNO 
or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno in(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 )))


UNION ALL


SELECT releaseformID,last, first, a.clno, ssn, date , EnteredVia,  (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from [Precheck_MainArchive].[dbo].[ReleaseForm_Archive] a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where replace(ssn,'-','') = replace(@SSN,'-','') 
and (a.clno = @CLNO or isnull(c.WebOrderParentCLNO,0) = @CLNO 
or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno in(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 )))
								
)
 as T
order by releaseformID desc



----[dbo].[ClientAccess_Get_ReleaseFormBySSN] 9763,'450-35-9458'
--SELECT releaseformID,last, first, a.clno, ssn, date ,    (CASE 
--        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
--        ELSE 'Y'
--     END) AS [HasApInfo]
--from releaseform a WITH (NOLOCK)
-- Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
--where replace(ssn,'-','') = replace(@SSN,'-','') 
--and (a.clno = @CLNO or isnull(c.WebOrderParentCLNO,0) = @CLNO 
--or a.clno in(Select clno from ClientHierarchyByService 
--								where parentclno in(select parentclno from ClientHierarchyByService 
--													where clno = @CLNO and refHierarchyServiceID=2 )))
--order by releaseformID desc


SET ANSI_NULLS ON



