


--exec ClientAccess_Get_ReleaseFormDefault 8426
--
--exec ClientAccess_Get_ReleaseFormDefault 8424
--
--Select clno from ClientHierarchyByService 
--								where parentclno in (select parentclno from ClientHierarchyByService 
--													where clno = 8424 and refHierarchyServiceID=2 )


-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-16-2008
-- Description:	 Gets release form info for the client on Load 
-- EXEC [ClientAccess_Release_Get_ReleaseFormDefault] 9051
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Release_Get_ReleaseFormDefault]
	@CLNO  INT

As



SELECT  releaseformID,last, first, a.clno, ssn, date, EnteredVia, (CASE 
        WHEN a.[ApplicantInfo_pdf] IS NULL THEN 'N'
        ELSE 'Y'
     END) AS [HasApInfo]
from releaseform a WITH (NOLOCK)
 Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
where date >= DATEADD(d,-15,getDate()) AND date < getDate() 
and (a.clno = @CLNO or c.WebOrderParentCLNO = @CLNO  
or a.clno in(Select clno from ClientHierarchyByService 
								where parentclno=(select parentclno from ClientHierarchyByService 
													where clno = @CLNO and refHierarchyServiceID=2 ))

-- or a.clno in(Select Value from  dbo.ClientConfiguration 
--								where CLNO =  @CLNO and  (ConfigurationKey = 'ShareRelease') )
)

order by last Asc
--order by releaseformID desc
SET ANSI_NULLS ON




