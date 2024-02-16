
--==============================================================================================================================
--Modified by: Piyush Panwar on 02/14/2023 as per HDT#15350 to add 2 columns HasGraduated and GraduationYear in Intranet Modules
-- Modified on 9/26/2023 by Dongmei He for Velocity Update 1.7
--==============================================================================================================================

CREATE PROCEDURE [dbo].[M_edu_detail]   @apno int,@eduid int as

--EXEC M_edu_detail 4903461,22336

-- online education module - JS
-- added by Lalit on 24 jan 23 for auto selecting thirdparty vendor
declare @ThirdpartyVendorsEmEdid int=0      
select top 1 @ThirdpartyVendorsEmEdid=ThirdpartyVendorsEmEdid from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@eduid and SectionId= 2 and isactive=1 order by ThirdpartyVendorsEmEdid desc

select top 1
		u.employeeid,e.apno, e.EducatID, e.school, e.state, e.phone, e.sectstat,e.web_status,IsNull(e.IsIntl,0) as international,e.name as eduname,a.alias,a.alias2,a.alias3,a.alias4,
		e.degree_a, e.studies_a, e.from_a, e.to_a,e.from_v,e.to_v,e.degree_v,e.studies_v,e.contact_name,e.contact_date,e.contact_title,e.priv_notes,e.pub_notes, e.includealias,e.includealias2,e.includealias3,e.includealias4,
		a.userid, e.investigator, a.apdate, a.enteredby,a.first, a.middle, a.last, a.dob, a.ssn, a.pos_sought,a.special_instructions,e.schoolid,rf.releaseformid,
		a.Phone applPhone, a.Email as applicantEmail, a.clno, ref.Affiliate, c.OKtoContact,cc.Email as clientEmail,--Prasanna modified email to ApplicantEmail and added new column clientEmail
		--e.graduationyear, e.HasGraduated, --Added by Humera Ahmed on 8/6/2021 For task #6120 CIC Education Graduation Information
		appe.IsGraduated,appe.GraduationYear, --Added by Piyush Panwar on 1/30/2023 For task #15350 Add Education Module Yes or No
		isnull(a.alias1_last,'')+ ', ' + isnull(a.alias1_first,'') + '  ' + isnull(a.alias1_middle,'') as firstalias,
		isnull(a.alias2_last,'')+ ', ' + isnull(a.alias2_first,'') + '  ' + isnull(a.alias2_middle,'') as secondalias,
		isnull(a.alias3_last,'')+ ', ' + isnull(a.alias3_first,'') + '  ' + isnull(a.alias3_middle,'') as thirdalias,
		isnull(a.alias4_last,'')+ ', ' + isnull(a.alias4_first,'') + '  ' + isnull(a.alias4_middle,'') as fourthalias,e.campusname,e.city,e.zipcode,
		c.name,
		f.reason as followupneededreason,
		f.followupon as followupneededdate,
		(SELECT ETADate
		 FROM ApplSectionsETA AS X(NOLOCK)
		 WHERE X.ApplSectionID = 2
		   AND X.Apno = @Apno 
		   AND X.SectionKeyID = @eduid
		   AND X.UpdatedBy <> 'DeriveETAFromTATService') AS ETADate,
		  tpve.ThirdPartyVendorId as ThirdPartyVendorId,       -- added by lalit on 23jan24
    e.RecipientName_V,
	e.GraduationDate_V,
	e.City_V,
	e.State_V,
	e.Country_V
from educat AS e(NOLOCK)
join appl AS a(NOLOCK) on e.apno = a.apno
left join Enterprise.dbo.Applicant app(NOLOCK) on a.apno = app.ApplicantNumber -- Piyush Panwar added the join for HDT 15350
left join Enterprise.dbo.ApplicantEducation appe(NOLOCK) on app.ApplicantID = appe.ApplicantID and e.School= appe.SchoolName  -- Piyush Panwar added the join for HDT 15350
join client AS c(NOLOCK) on a.clno = c.clno
left join clientcontacts cc(nolock) on cc.clno = c.clno  -- Prasanna added the join for HDT#21934 
        AND ((LTRIM(RTRIM(substring(Attn,0,CHARINDEX(',', Attn)))) = cc.LastName and LTRIM(RTRIM((substring(Attn, CHARINDEX(',', Attn)+1, len(Attn)-(CHARINDEX(',', Attn)-1))))) = cc.FirstName) 
		OR  (ISNULL(a.Attn,'') = ISNULL(cc.Email,'')))
inner join dbo.refAffiliate AS ref(NOLOCK) ON c.AffiliateID = ref.AffiliateID --radhika dereddy 02/14/2014
left join releaseform AS rf(NOLOCK) on a.ssn = rf.ssn and a.clno = rf.clno
left join users AS u(NOLOCK) on u.userid = e.investigator
left join applsections_followup AS f(NOLOCK) on f.applsectionid = e.educatid and f.apno = e.apno
left join ThirdpartyVendorsEmEd tpve(nolock)on e.EducatID=tpve.SectionKeyId and tpve.ThirdpartyVendorsEmEdid=@ThirdpartyVendorsEmEdid   -- added by lalit on 23jan24
where  a.apno = @apno and e.educatid = @eduid 
and   ((f.sectionid ='Educat' or f.sectionid is null) and (f.Repeat_Followup = 0 or f.Repeat_Followup is null))
order by rf.date DESC

