
--Modified by Schapyala 0n 02/28/2022
--skipping 'PA','WA','NH' because of compliance requirement
--Modified By Jalindar ON 09/08/2022 Remove 'NH' by requirement
--Modified by Lalit for #96018 on 2 august 2023

CREATE procedure [dbo].[Integration_Verification_GetMVRPending]
as 
select top 20
a.clno,Affiliate,d.ordered OrderedDate,d.CreatedDate RecordCreatedOn, d.apno,
IsNull(a.last,'') as last,
IsNull(a.first,'') as first, 
IsNull(a.middle,'') as middle, 
--'' as last,'' as middle,'' as first,
a.dob, a.dl_state, 
--a.dl_number,
replace(RTRIM(LTRIM(IsNull(a.dl_number,''))),'_','') dl_number,
--replace(a.ssn,'-','') as ssn,
IsNull(st.DL_SearchType,'OL') as DL_SearchType,
'CI' as input,'CO' as output,case when IsNull(st.IsReleaseNeeded,0) = 1 then 'Y' else 'N' end as 'IsReleaseNeeded','3Y' as SubType,
c.Name as ClientName
from dl d (nolock) inner join appl a (nolock) on d.apno = a.apno
				   inner join client c  (nolock) on a.clno = c.clno 
				   left join refaffiliate r  (nolock) on c.affiliateid = r.AffiliateID
				   left join state st (nolock) on lower(st.State) = lower(a.dl_state)				   
where d.sectstat = '9' and IsHidden=0  and a.apstatus in ('p','w')--and d.Web_status = 0 
and IsNull(dl_state,'') not in ('','PA','WA') and replace(RTRIM(LTRIM(IsNull(a.dl_number,''))),'_','') <> ''
--and IsNull(ordered,'') = ''
and DateOrdered is null 
and a.CLNO not in (2135,3468)
--and a.apno not in (1951560,1952897,1947024)
and (d.AttemptCounter is null or d.AttemptCounter=0 or d.AttemptCounter<2 and getdate()>dateadd(minute,15,coalesce(d.Last_Updated,0)) ) -- added to prevent re-order before 15 minutes from last failure
order by dl_state,a.apno

--Update the excluded specific state records to Needs Review Queue 
-- so they could be manually handled
	update d SET	Web_Status = 44,
					MVRLoggingId = 0,
					IsReleaseNeeded =  1,	 
					Last_Updated = CURRENT_TIMESTAMP
     from dbo.dl d (nolock) inner join dbo.appl a (nolock) on d.apno = a.apno
	where d.sectstat = '9' and IsHidden=0  and a.apstatus in ('p','w')
	and IsNull(dl_state,'') in ('PA','WA') 
	and DateOrdered is null and isnull(web_status,0) <> 44

