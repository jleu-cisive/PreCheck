-- =============================================
-- Author:		Prasanna
-- Requester: Dana Sangerhassen
-- Create date: 08/24/2017
-- Description:	All Criminal Search Reporting Status
-- Execution: EXEC [dbo].[AllCriminalSearchReportingStatus] 
-- =============================================
CREATE PROCEDURE [dbo].[AllCriminalSearchReportingStatus]
	
AS
SET NOCOUNT ON

BEGIN

	select a.apno as [Report Number],a.apdate as ApDate,a.last as [Last Name],a.first as [First Name],c.Name as [Client Name],refAff.Affiliate as [Client Affiliate],
			case when c.clear = 'O' then 'O-Ordered'
				when c.clear = 'R' then 'R-Pending'
				when c.clear = 'W' then 'W-Waiting'
				when c.clear = 'X' then 'X-Error Getting Results'
				when c.clear = 'E' then 'E-Error Sending Order'
				when c.clear = 'M' then 'M-Ordering'
				when c.clear = 'V' then 'V-Vendor Reviewed'
				when c.clear = 'I' then 'I-Transferred Record'
				when c.clear = 'N' then 'N-Alias Name Ordered'
				when c.Clear = 'D' then 'D-Review Reportability'
				when c.Clear = 'Z' then 'Z-Needs Research'
				when c.Clear = 'Q' then 'Q-Needs QA'
				when c.Clear = 'G' then 'G-Reinvestigations'
				else c.clear end as 'CrimStatus',
	(case when a.apdate is null then dbo.elapsedbusinessdays_2(a.CreatedDate, GETDATE()) else dbo.elapsedbusinessdays_2(a.apdate, GETDATE()) end)as [Elapsed Days from Client Perspective],
	(case when a.apdate is null then dbo.elapsedbusinessdays_2(c.Crimenteredtime, GETDATE()) else dbo.elapsedbusinessdays_2(c.Ordered, GETDATE()) end)as [Elapsed Days of Search],c.County as [County State of search]
	--SUBSTRING(c.County,charIndex(',',c.County)+1,100) as [County State of search]
	from appl a with (nolock)
	inner join Client client with (nolock) on a.CLNO = client.CLNO
	inner join crim c with (nolock) on a.apno = c.apno
	inner join refaffiliate refAff with (nolock) on refAff.AffiliateID = client.AffiliateID
	where c.Clear not in('T','F','P') and c.IsHidden=0  order by [Report Number] desc

END

SET NOCOUNT OFF