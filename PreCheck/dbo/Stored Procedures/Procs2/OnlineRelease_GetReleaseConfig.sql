
--OnlineRelease_GetReleaseConfig 1616,'IsCustomReleaseRequired'

CREATE PROCEDURE [dbo].[OnlineRelease_GetReleaseConfig]
    
	@CLNO as INT,
	@Keyvalue as VARCHAR (30)
AS
SELECT c.CLNO,c.Name,isnull(cr.ShortRelease,'False') as ShortRelease,
isnull(cr.ContactpresentEmployer,'True') as ContactpresentEmployer,
isnull(cr.DisplayEducation,'True') as DisplayEducation,
isnull(cr.DisplayCriminal,'True') as DisplayCriminal,
isnull(cr.DisplayLicense,'True') as DisplayLicense, 
isnull(cr.ClientDisclosure,'') as ClientDisclosure,
isnull(cr.ReleaseNotificationEmail,'')as ReleaseNotificationEmail,
isnull(cr.CriminalQuestion,'<b>You MUST read this section carefully before answering the question below.</b><br/><ul type="disc"><li>Do not report a record of any arrest, detention, diversion, supervision, adjudication or court disposition that was subject to the process and jurisdiction of a juvenile court. </li>
<li>Do not report any conviction that has been sealed, expunged, statutorily eradicated, annulled, dismissed, dismissed under a first offender’s law, pardoned by the Governor or which state law allows you to lawfully deny as set forth below.</li> 
<li>You MUST review the <a href="https://weborder.precheck.net/ClientAccess/resources/StateSpecificCrimNotice.pdf" target="_blank">state law information</a> before answering. </li><li>You are not required to disclose violations, infractions, petty misdemeanors (MN) or summary offenses (PA).</li>
<li>By selecting either &quot;Yes&quot; or &quot;No&quot; below, you are stating that you have read the applicable state notices provided above and that you provide a true and accurate statement below.</li><li>A conviction will not necessarily be a bar to employment. This information will only be used for job-related purposes consistent with applicable law and in determining whether the conviction is related to the job for which you are applying.</li> 
<li>If you answer &quot;Yes&quot; below, provide city, county, and state where offense occurred, conviction date and nature of the offense, along with sentencing information.</li></ul><b><br/><br/><span style="Color:Red; display:inline;"><U>QUESTION:</U> Have you ever been convicted of, plead guilty, no contest, or nolo contendere to a misdemeanor or felony?</span></b>')as CriminalQuestionLabel,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey=@Keyvalue),'false') as CustomReleaseRequired,
 isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='10YearResidentialHistory'),'false') as YearResidentialHistory ,

isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HideAliasNames'),'false') as HideAliasNames ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HideDriverLicense'),'false') as HideDriverLicense ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HideResidentialHistory'),'false') as HideResidentialHistory ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HideCurrentAddress'),'false') as HideCurrentAddress ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HidePreviousAddresses'),'false') as HidePreviousAddresses,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='ValidateResidentialHistory'),'false') as ValidateResidentialHistory ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='CriminalQuestion'),'false') as CriminalQuestion ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='RemoveCreditHistory'),'false') as RemoveCreditHistory  
,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='ShowSSNblurb'),'false') as ShowSSNblurb  
--Added by Praveen
,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='RequiredAllAddresses'),'false') as RequiredAllAddresses
  ,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='DisplayEducationBlurb'),'false') as DisplayEducationBlurb
   ,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='DisplayLicenseStatus'),'false') as DisplayLicenseStatus
  ,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='SubmitEducationMandatory'),'false') as SubmitEducationMandatory
   ,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='SubmitEmailMandatory'),'false') as SubmitEmailMandatory
    ,isnull((SELECT VALUE FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='CustomEducationSchoolNameHeader'),'false') as CustomEducationSchoolNameHeader
	,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='EducationRequired'),'false') as EducationRequired,
	isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='DriverLicenseRequired'),'false') as DriverLicenseRequired,
	isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='7YearEmploymentHistory'),'false') as YearEmploymentHistory ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HideEmploymentHistory'),'false') as HideEmploymentHistory ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HideCurrentEmployment'),'false') as HideCurrentEmployment ,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='HidePreviousEmployments'),'false') as HidePreviousEmployments,
isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='ValidateEmploymentHistory'),'false') as ValidateEmploymentHistory,

isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='RequiredAllEmployments'),'false') as RequiredAllEmployments
,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='DisplayEmployment'),'false') as DisplayEmployment


,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='CustomAuthorizationHeader'),'ACKNOWLEDGMENT AND AUTHORIZATION') as CustomAuthorizationHeader
,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='CustomDisclosureHeader'),'DISCLOSURE REGARDING BACKGROUND INVESTIGATION') as CustomDisclosureHeader
,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='CustomStateLawNoticesHeader'),'STATE LAW NOTICES') as CustomStateLawNoticesHeader
,isnull((SELECT LOWER(VALUE) FROM dbo.clientconfiguration WHERE clno = @CLNO and configurationkey='CustomConsumerType'),'APPLICANT') as CustomConsumerType


FROM dbo.Client c left outer join dbo.ClientConfig_Release cr on c.clno = cr.clno WHERE c.CLNO = @CLNO





