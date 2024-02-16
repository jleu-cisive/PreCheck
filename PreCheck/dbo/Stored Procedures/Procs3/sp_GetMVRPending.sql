
CREATE procedure [dbo].[sp_GetMVRPending](
--@DateFrom DateTime = null,
--@DateTo DateTime = null,
@State char(2) = null,
@CLNO int = null)
as 

if ISNULL(@CLNO,'') = '' 
	Set @CLNO = 0
select a.clno,Affiliate,d.ordered OrderedDate,d.CreatedDate RecordCreatedOn, d.apno,a.last, a.first, a.middle, a.dob, a.dl_state, a.dl_number,replace(a.ssn,'-','') as ssn 
from dl d (nolock) inner join appl a (nolock) on d.apno = a.apno
				   inner join client c  (nolock) on a.clno = c.clno 
				   left join refaffiliate r  (nolock) on c.affiliateid = r.AffiliateID
where d.sectstat = '9' and IsHidden=0
and (a.CLNO = @CLNO or @CLNO = 0)
and (a.dl_state = @State or ISNULL(@State,'') = '')
--and (Case When isnull(@DateFrom,'')='' then  '1/1/1900' else d.ordered end) between (Case When isnull(@DateFrom,'')='' then  '1/1/1900' else @DateFrom end)  and (Case When isnull(@DateTo,'')='' then  Current_TimeStamp else DateAdd(d,1,@DateTo) end)
order by dl_state,a.apno
