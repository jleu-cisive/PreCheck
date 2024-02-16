-- =============================================
-- Author:		Dongmei
-- Create date: 03/14/2017
-- Description:	only return the county if there is an identical county in the same app with the crim statuses "clear" or "record found"
-- Exec [dbo].[Missed_TransferredRecord_Report]	
-- =============================================
CREATE PROCEDURE [dbo].[Missed_TransferredRecord_Report]	
AS
BEGIN
	
	--select c.apno, c.[clear], c.County from crim c join (
 --   select apno, CNTY_NO, [Clear] from Crim with (nolock)  group by apno, CNTY_NO, clear having [Clear] = 'I' and count(*) = 1 ) d
 --   on c.CNTY_NO = d.CNTY_NO and c.apno = d.apno and c.[clear] in ('F', 'T') order by 1 desc

    select c.apno, c.[clear], c.County, X.Name AS [Client Name], ra.Affiliate
	from crim c(NOLOCK)
	INNER JOIN (select apno, CNTY_NO, [Clear] from Crim with (nolock)  
				group by apno, CNTY_NO, [clear] 
				having [Clear] = 'I' and count(*) >= 1 ) d on c.CNTY_NO = d.CNTY_NO and c.apno = d.apno and c.[clear] in ('F', 'T') 
	inner join Appl AS appl(NOLOCK) on c.apno = appl.APNO 
	INNER JOIN CLIENT AS X(NOLOCK) ON APPL.CLNO = X.CLNO
	INNER JOIN dbo.refAffiliate AS ra(NOLOCK) ON X.AffiliateID = ra.AffiliateID	
	where appl.ApStatus = 'P' 
	order by 1 desc

END
