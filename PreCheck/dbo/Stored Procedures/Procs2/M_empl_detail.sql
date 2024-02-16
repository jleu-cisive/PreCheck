
--**************************************************************************************
-- Modified by Prasanna - on 09/08/2021 for HDT#14900 - Add ClientEmail in Employment Module
-- EXEC [dbo].[M_empl_detail] 3425052, 4313443
-- EXEC [dbo].[M_empl_detail] 6324430,7000957   --5119202, 4281232      6324430&dstate=SJV&empid=7000957 
-- updated by Lalit on 9 feb 2023 for adding thirdparty/vendor dropdown
-- Modified on 9/26/2023 by Dongmei He for Velocity Update 1.7
--*****************************************************************************************

CREATE PROCEDURE [dbo].[M_empl_detail]  @apno int,@empid int as 

--Update section - set the Rel_Cond, Emp_Type to n/a if empty
declare @relCond char(1), @empType char(1)

set @relcond = (select e.rel_cond from empl e WITH(NOLOCK) where  e.emplid = @empid) 
set @empType = (select e.Emp_Type from empl e WITH(NOLOCK) where  e.emplid = @empid)
                          
if(LTRIM(RTRIM(@relCond))='')
begin
  update Empl set Rel_Cond = 'N' where EmplID = @empid
end


if(LTRIM(RTRIM(@empType)) = '')
begin
   update Empl set Emp_Type = 'N' where EmplID = @empid
end
--End Update --Suchitra Yellapantula 10-24-2016
declare @ThirdpartyVendorsEmEdid int=0
select top 1 @ThirdpartyVendorsEmEdid=ThirdpartyVendorsEmEdid from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@empid and SectionId= 1 and isactive=1 order by ThirdpartyVendorsEmEdid desc


-- online Employment module - JS

select 
	e.apno, e.emplid, e.employer, e.location,e.ver_salary, e.dnc,e.dept,e.rfl, e.sectstat, e.web_status,IsNull(e.isintl,0) as international, e.web_updated,e.phone, a.alias ,a.alias2 ,a.alias3,a.alias4,
	e.salary_A,  e.includealias,e.includealias2,e.includealias3,e.includealias4, e.from_a, e.supervisor,e.to_a,e.from_v,e.to_v, e.ver_by , e.title , e.priv_notes, e.pub_notes, e.position_v, e.salary_v, e.position_a,
	e.rehire, e.rel_cond, a.userid, e.specialq,a.apstatus,e.investigator, a.apdate, a.enteredby,a.first, a.middle, a.last, a.dob, a.ssn, a.pos_sought,e.emp_type,a.special_instructions, a.phone applPhone, a.email as applicantEmail, a.clno, ref.Affiliate, c.OKtoContact,cc.Email as clientEmail,--Prasanna modified email to ApplicantEmail and added new column clientEmail
	isnull(a.alias1_last,'') + ', ' + isnull(a.alias1_first,'') + '  ' + isnull(a.alias1_middle,'') as newalias1,
	isnull(a.alias2_last,'') + ', ' + isnull(a.alias2_first,'') + '  ' + isnull(a.alias2_middle,'') as newalias2,
	isnull(a.alias3_last,'') + ', ' + isnull(a.alias3_first,'') + '  ' + isnull(a.alias3_middle,'') as newalias3,
	isnull(a.alias4_last,'') + ', ' + isnull(a.alias4_first,'') + '  ' + isnull(a.alias4_middle,'') as newalias4,e.city,e.state,Replace(e.zipcode,'''','') as zipcode,e.employerid,
	isnull(c.emplemployernotes,'') as employernotes,isnull(c.emplclientnotes,'') as employerclientnotes,e.SupPhone,
	c.name, e.last_worked, e.IsCamReview,
	f.reason as followupneededreason,
	f.followupon as followupneededdate,
	(SELECT ETADate
	 FROM ApplSectionsETA AS X(NOLOCK)
	 WHERE X.ApplSectionID = 1 
	   AND X.Apno = @Apno 
	   AND X.SectionKeyID = @empid
	   AND X.UpdatedBy <> 'DeriveETAFromTATService') AS ETADate,
	   tpve.ThirdPartyVendorId as ThirdPartyVendorId,   --- added by lalit for thirdparty dropdown
       e.recipientname_v,
	   e.city_v,
	   e.state_v,
	   e.country_v
from empl e(nolock)
JOIN appl a(nolock) on e.apno = a.apno
join client c(nolock) on a.clno = c.clno
left join clientcontacts cc(nolock) on cc.clno = c.clno  -- Prasanna added the join for HDT#14900 
        AND ((LTRIM(RTRIM(substring(Attn,0,CHARINDEX(',', Attn)))) = cc.LastName and LTRIM(RTRIM((substring(Attn, CHARINDEX(',', Attn)+1, len(Attn)-(CHARINDEX(',', Attn)-1))))) = cc.FirstName) 
		OR  (ISNULL(a.Attn,'') = ISNULL(cc.Email,'')))
inner join dbo.refAffiliate ref(nolock) ON c.AffiliateID = ref.AffiliateID 
left join applsections_followup f(nolock) on f.applsectionid = e.emplid and f.apno = e.apno  AND f.sectionid ='Empl'
left join ThirdpartyVendorsEmEd tpve(nolock)on e.EmplID=tpve.SectionKeyId and tpve.ThirdpartyVendorsEmEdid=@ThirdpartyVendorsEmEdid --- added by lalit for thirdparty dropdown
where  a.apno = @apno and e.emplid = @empid 
  and (f.Repeat_Followup = 0 or f.Repeat_Followup is null)
order by a.investigator, a.last





 

 


