-- =======================================================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Exec ActiveClientListWithType '07/01/2000','10/15/2019'
-- Modified by: Prasanna on 10/26/2019 for HDT#59915 Missing accounts 
-- ======================================================================


CREATE PROCEDURE [dbo].[ActiveClientListWithType]
	 @StartDate datetime,
	 @EndDate datetime

AS
BEGIN	
 --existing query
 --select c.clno,name,Affiliate,cam,r.clienttype from client c with (nolock) 
 --left join refclienttype r with (nolock) on c.clienttypeid = r.clienttypeid
 --left join refAffiliate ra with (nolock) on c.AffiliateID = ra.AffiliateID
 --where c.nonclient = 0 and c.isinactive = 0


	 select c.CLNO,c.name,Affiliate,c.cam,r.clienttype,count(a.apno) as [Number Of Reports] from client c 
	 left outer join appl a on c.clno=a.clno 
	 left join refclienttype r with (nolock) on c.clienttypeid = r.clienttypeid
	 left join refAffiliate ra with (nolock) on c.AffiliateID = ra.AffiliateID 
	 where c.nonclient = 0 and c.isinactive = 0 and ((apdate>@StartDate and apdate<@EndDate) or ApDate is NULL)
	 group by c.CLNO,c.name,Affiliate,c.cam,r.clienttype
                                                                                            
END


