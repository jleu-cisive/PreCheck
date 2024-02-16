


CREATE procedure [dbo].[Integration_Verification_GetMVRPending_0114209]
as 

select 
top 20
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
'CI' as input,'CO' as output,case when IsNull(st.IsReleaseNeeded,0) = 1 then 'Y' else 'N' end as 'IsReleaseNeeded','3Y' as SubType
from dl d (nolock) inner join appl a (nolock) on d.apno = a.apno
				   inner join client c  (nolock) on a.clno = c.clno 
				   left join refaffiliate r  (nolock) on c.affiliateid = r.AffiliateID
				   left join state st (nolock) on lower(st.State) = lower(a.dl_state)				   
where d.sectstat = '9' and IsHidden=0  and a.apstatus in ('p','w')--and d.Web_status = 0 
and IsNull(dl_state,'') <> '' and replace(RTRIM(LTRIM(IsNull(a.dl_number,''))),'_','') <> ''
--and IsNull(ordered,'') = ''
and DateOrdered is null 
and a.CLNO not in (2135,3468)
--and a.apno not in (1951560,1952897,1947024)
order by dl_state,a.apno

