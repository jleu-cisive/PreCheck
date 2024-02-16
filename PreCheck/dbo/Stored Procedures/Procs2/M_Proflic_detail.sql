/*
	EXEC [M_Proflic_detail] 3429057,1558543
*/

CREATE PROCEDURE [dbo].[M_Proflic_detail]  @apno int, @proflicid int AS
-- online education module - JS
select
  u.employeeid,p.apno,p.lic_no,p.year,p.expire,p.status, p.proflicid, p.organization,p.contact_name,p.contact_title,p.contact_date,p.investigator,p.lic_type,p.state,  p.sectstat,p.web_status,p.priv_notes,p.pub_notes,
a.alias,a.alias2,a.alias3,a.alias4, p.includealias,p.includealias2,p.includealias3,p.includealias4,a.special_instructions,
  a.userid, p.investigator, a.apdate, a.enteredby,a.first, a.middle, a.last, a.dob, a.ssn, a.pos_sought,a.phone applPhone,a.email,c.OKtoContact,
isnull(a.alias1_last,'') + ', ' + isnull(a.alias1_first,'') + '  ' + isnull(a.alias1_middle,'') as firstalias,
isnull(a.alias2_last,'') + ', ' + isnull(a.alias2_first,'') + '  ' + isnull(a.alias2_middle,'') as secondalias,
isnull(a.alias3_last,'') + ', ' + isnull(a.alias3_first,'') + '  ' + isnull(a.alias3_middle,'') as thirdalias,
isnull(a.alias4_last,'') + ', ' + isnull(a.alias4_first,'') + '  ' + isnull(a.alias4_middle,'') as fourthalias,
  c.name, c.clno, p.last_worked,ref.affiliate
-- Added by kiran on 2/6/2008
,p.Lic_Type_V,p.Lic_No_V,p.State_V,p.Year_V,p.Expire_V,
p.NameOnLicense_V, p.Speciality_V, p.LifeTime_v,p.MultiState_V,p.BoardActions_V,p.ContactMethod_V, P.licenseTypeId , --Added by radhika on 01/10/2014
Case When a.clno in (Select clno from DBO.ClientConfiguration where (configurationkey = 'WO_Merge_CredentialCertificate' or configurationkey = 'WO_Merge_LMP_BG_CredentialCertificate') and value = 'True') then 1 else 0 end [GenerateCredentialCertificate?] 
,	(SELECT ETADate
	 FROM ApplSectionsETA AS X(NOLOCK)
	 WHERE X.ApplSectionID = 4
	   AND X.Apno = @Apno 
	   AND X.SectionKeyID = @proflicid
	   AND X.UpdatedBy <> 'DeriveETAFromTATService') AS ETADate
from proflic p(NOLOCK)
  join appl a(NOLOCK) on p.apno = a.apno
  join client c(NOLOCK) on a.clno = c.clno
  inner join dbo.refAffiliate ref ON c.AffiliateID = ref.AffiliateID
  left join users u(NOLOCK) on p.investigator = u.userid
where  a.apno = @apno and p.proflicid = @proflicid
order by a.investigator, a.last



