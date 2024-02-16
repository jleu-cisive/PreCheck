





-- EXEC [ClientAccess_Get_ReleaseFormByDate] 8424, '11/01/2012', '12/31/2012'
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 08-12-2008
-- Description:	 Gets release form info for the client when search by date
--Updated by: Radhika Dereddy on 10/30/2015 to get the releases from Archive
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Release_Get_ReleaseFormByDate]
	@CLNO  INT,
 @StartDate	  DateTime,
 @EndDate      DateTime
	
As
SELECT releaseformID,last, first, clno, ssn, date , EnteredVia, [HasApInfo] from

(
SELECT releaseformID,last, first, a.clno, ssn, date , EnteredVia,   (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from releaseform a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where date >= @StartDate and date < DateAdd(d,1,@EndDate) 
and (a.clno = @CLNO or c.WebOrderParentCLNO = @CLNO  or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno=(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 )))



UNION ALL


SELECT releaseformID,last, first, a.clno, ssn, date , EnteredVia,   (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from [Precheck_MainArchive].[dbo].[ReleaseForm_Archive] a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where date >= @StartDate and date < DateAdd(d,1,@EndDate) 
and (a.clno = @CLNO or c.WebOrderParentCLNO = @CLNO  or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno=(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 )))
								

) as T
order by releaseformID desc
SET ANSI_NULLS ON




