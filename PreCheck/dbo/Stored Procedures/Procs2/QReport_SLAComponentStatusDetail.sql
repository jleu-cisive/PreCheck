-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/06/2021
-- Description:	<Description,,>
-- EXEC [QReport_SLAComponentStatusDetail] '', '03/01/2021', '03/31/2021', 230, null
-- =============================================

CREATE PROCEDURE [dbo].[QReport_SLAComponentStatusDetail]
	-- Add the parameters for the stored procedure here
@CLNO VARCHAR(MAX),  
@StartDate DateTime,  
@EndDate DateTime,  
@AffiliateID int,  
@CAM varchar(8) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

if(@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null')
Begin  
	SET @CLNO = NULL  
END 
  
if(@CAM = '0' OR @CAM = '' OR LOWER(@CAM) = 'null')
Begin 
  SET @CAM = NULL  
END  

-- DROP TABLES

DROP TABLE IF EXISTS #SLADetailsByClient
DROP TABLE IF EXISTS #ApplicantContactAll
DROP TABLE IF EXISTS #ApplicantContactALLPivot
DROP TABLE IF EXISTS #ApplicantContactPivot
DROP TABLE IF EXISTS #ApplicantTotal
DROP TABLE IF EXISTS #OverseasEducation
DROP TABLE IF EXISTS #OverseasEducationALLPivot
DROP TABLE IF EXISTS #OverseasEducationByClient
DROP TABLE IF EXISTS #OverseasEducationALL
DROP TABLE IF EXISTS #OverseasEmployment
DROP TABLE IF EXISTS #OverseasEmploymentALLPivot
DROP TABLE IF EXISTS #OverseasEmploymentByClient
DROP TABLE IF EXISTS #OverseasEmploymentALL
DROP TABLE IF EXISTS #ClientVerifiedRateLicense
DROP TABLE IF EXISTS #ClientVerifiedLicenseALLPivot
DROP TABLE IF EXISTS #ClientVerifiedLicenseALL
DROP TABLE IF EXISTS #VerifiedRateLicense
DROP TABLE IF EXISTS #ClientVerifiedRatePersRef
DROP TABLE IF EXISTS #ClientVerifiedReferenceALLPivot
DROP TABLE IF EXISTS #VerifiedRatePersRef
DROP TABLE IF EXISTS #ClientVerifiedReferenceALL
DROP TABLE IF EXISTS #ClientVerifiedRatesBYComponent


-- 1. SLA Details by Client

 SELECT DISTINCT DATENAME(month, a.ApDate) [Report Month],
a.clno [Client ID],
c.name [Client Name] ,
c.[State] AS [Client State],
ra.Affiliate [Affiliate], 
a.ClientApplicantNO AS [CandidateID],    
a.Attn as [Contact Name] ,
a.apno as [Report Number],  
FORMAT(a.apdate,'MM/dd/yyyy hh:mm tt') as [Report Create Date],  
FORMAT(a.origcompdate,'MM/dd/yyyy hh:mm tt') as 'Original Closed Date',  
FORMAT(a.ReopenDate,'MM/dd/yyyy hh:mm tt') as 'Reopen Date',
FORMAT(a.CompDate,'MM/dd/yyyy hh:mm tt') as 'Complete Date',
a.EnteredVia as 'Submitted Via',   
a.Last [Applicant Last],
a.First [Applicant First],
a.SSN,
a.DOB,
a.state as [Applicant State],
p.PackageDesc 'Selected Package' 
INTO #SLADetailsByClient
FROM Client c (NOLOCK)   
INNER JOIN Appl a (NOLOCK) on c.clno = a.clno   
INNER JOIN refAffiliate ra (NOLOCK) on c.AffiliateID = ra.AffiliateID  
LEFT JOIN PackageMain p (NOLOCK) on a.PackageID = P.PackageID 
WHERE (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno)))   
AND A.OrigCompDate BETWEEN @StartDate and DateAdd(d,1,@EndDate)   
AND (RA.AffiliateID = IIF(@AffiliateID=0,RA.AffiliateID,@AffiliateID))  
AND C.CAM = IIF(@CAM is null,c.CAM,@CAM)  
AND A.CLNO NOT IN (3468,2135,3668,3079)

--SELECT * FROM #SLADetailsByClient


---- 2. ApplicantContact_Report_ALL

SELECT
a.[Report Number] as 'Report Number',
applS.Description AS 'ComponentType',
rmc.ItemName AS 'MethodOfContact',
rrc.ItemName AS 'ReasonForContact'  INTO #ApplicantContactAll
FROM ApplicantContact AS ac WITH (NOLOCK)
INNER JOIN #SLADetailsByClient AS a WITH (NOLOCK) ON a.[Report Number] = ac.APNO
INNER JOIN refMethodOfContact AS rmc WITH (NOLOCK) ON rmc.refMethodOfContactID = ac.refMethodOfContactID
INNER JOIN refReasonForContact AS rrc WITH (NOLOCK) ON rrc.refReasonForContactID = ac.refReasonForContactID
INNER JOIN ApplSections AS applS WITH (NOLOCK) ON applS.ApplSectionID = ac.ApplSectionID


--SELECT * FROM #ApplicantContactAll tct

select *,
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='Applicant Involvement' and A.[Report Number] =tct.[Report Number]) as [Emp Email Applicant Involvement],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='Institution Location' and A.[Report Number] =tct.[Report Number]) as [Emp Email Institution Location],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='Institution Name/Issuing Organization' and A.[Report Number] =tct.[Report Number]) as [Emp Email Institution Name/Issuing Organization],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='International' and A.[Report Number] =tct.[Report Number]) as [Emp Email International],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='No Records Found' and A.[Report Number] =tct.[Report Number]) as [Emp Email No Records Found],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='Non Responsive' and A.[Report Number] =tct.[Report Number]) as [Emp Email Non Responsive],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='Other' and A.[Report Number] =tct.[Report Number]) as [Emp Email Other],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and tct.MethodOfContact='Email' and tct.ReasonForContact='State GED' and A.[Report Number] =tct.[Report Number]) as [Emp Email State GED],

(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='Applicant Involvement' and A.[Report Number] =tct.[Report Number]) as [Edu Email Applicant Involvement],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='Institution Location' and A.[Report Number] =tct.[Report Number]) as [Edu Email Institution Location],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='No Records Found' and A.[Report Number] =tct.[Report Number]) as [Edu Email No Records Found],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='Proof' and A.[Report Number] =tct.[Report Number]) as [Edu Email Proof],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='International' and A.[Report Number] =tct.[Report Number]) as [Edu Email International],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='Institution Name/Issuing Organization' and A.[Report Number] =tct.[Report Number]) as [Edu Email Institution Name/Issuing Organization],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='Other' and A.[Report Number] =tct.[Report Number]) as [Edu Email Other],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and tct.MethodOfContact='Email' and tct.ReasonForContact='State GED' and A.[Report Number] =tct.[Report Number]) as [Edu Email State GED],

(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Both' and tct.ReasonForContact='Applicant Involvement' and A.[Report Number] =tct.[Report Number]) as [Lic Both Applicant Involvement],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Both' and tct.ReasonForContact='Institution Name/Issuing Organization' and A.[Report Number] =tct.[Report Number]) as [Lic Both Institution Name/Issuing Organization],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Both' and tct.ReasonForContact='License #/Correct # Needed' and A.[Report Number] =tct.[Report Number]) as [Lic Both License #/Correct # Needed],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Both' and tct.ReasonForContact='No Records Found' and A.[Report Number] =tct.[Report Number]) as [Lic Both No Records Found],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Email' and tct.ReasonForContact='Institution Name/Issuing Organization' and A.[Report Number] =tct.[Report Number]) as [Lic Email Institution Name/Issuing Organization],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Email' and tct.ReasonForContact='License #/Correct # Needed' and A.[Report Number] =tct.[Report Number]) as [Lic Email License #/Correct # Needed],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and tct.MethodOfContact='Phone' and tct.ReasonForContact='Other' and A.[Report Number] =tct.[Report Number]) as [Lic Phone No Records Found],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Employment' and A.[Report Number] =tct.[Report Number]) as [Emp Appl Contact Total],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Education' and A.[Report Number] =tct.[Report Number]) as [Edu Appl Contact Total],
(select count(1) from #ApplicantContactAll tct where tct.[ComponentType]='Professional License' and A.[Report Number] =tct.[Report Number]) as [Lic Appl Contact Total],
(select count(1) from #ApplicantContactAll tct WHERE A.[Report Number] =tct.[Report Number]) as [Appl Contact Grand Total]
INTO #ApplicantContactPivot
FROM #SLADetailsByClient A

--SELECT * FROM #ApplicantContactPivot
/*
SELECT [Report Number],SUM([Applicant Contact Education]) as[Applicant Contact Education],
					   SUM([Applicant Contact Employment]) as [Applicant Contact Employment],
					   SUM([Applicant Contact Professional License])as [Applicant Contact Professional License]
INTO #ApplicantContactALLPivot
FROM(
	  SELECT [Report Number],[Education] as [Applicant Contact Education], 
					[Employment] as [Applicant Contact Employment],
					[Professional License] as [Applicant Contact Professional License]
	  FROM
			(
			  SELECT  [Report Number],[ComponentType],MethodOfContact FROM #ApplicantContactAll
			) As SourceTable
			PIVOT (
					Count( ComponentType) for ComponentType in ([Education], [Employment], [Professional License])
				  
				  )AS PivotTable
	) A
GROUP BY [Report Number]

--SELECT * FROM #ApplicantContactALLPivot

SELECT A.*
,ISNULL(al.[Applicant Contact Education], 0) [Applicant Contact Education],
ISNULL(al.[Applicant Contact Employment], 0)[Applicant Contact Employment],
ISNULL(al.[Applicant Contact Professional License],0) [Applicant Contact Professional License]
INTO #ApplicantTotal
FROM #ApplicantContactPivot A
LEFT OUTER JOIN #ApplicantContactALLPivot as al ON A.[Report Number] = al.[Report Number]

*/
--SELECT * FROM #ApplicantTotal


---- 3. [Overseas Education by Clients by Date Range]

SELECT    
a.[Report Number],
CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International/Overseas],   
S.[Description] AS [Status],  
isnull(sss.SectSubStatus,'') as [SectSubStatus], W.description as [Web Status] 
into #OverseasEducation
FROM #SLADetailsByClient AS A(NOLOCK)  
INNER JOIN Educat AS E(NOLOCK) ON E.APNO = A.[Report Number]  
INNER JOIN SectStat AS S(NOLOCK) ON S.CODE = E.SectStat  
INNER JOIN Websectstat AS W(NOLOCK) ON W.code = E.web_status 
LEFT JOIN SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID
WHERE isnull(sss.SectSubStatus ,'') <> '' and
	 E.IsonReport = 1
ORDER BY E.APNO, [status], [SectSubStatus]

--SELECT *  FROM #OverseasEducation 

SELECT [Report Number],SUM([CLEAR])[CLEAR],SUM([VERIFIED])[VERIFIED],SUM([VERIFIED/SEE ATTACHED])[VERIFIED/SEE ATTACHED],
						SUM([COMPLETE])[COMPLETE],SUM([COMPLETE/SEE ATTACHED])[COMPLETE/SEE ATTACHED], SUM([ALERT])[ALERT], 
						SUM([ALERT/SEE ATTACHED])[ALERT/SEE ATTACHED],SUM([UNVERIFIED])[UNVERIFIED],
						SUM([UNVERIFIED/SEE ATTACHED])[UNVERIFIED/SEE ATTACHED], SUM([SEE ATTACHED])[SEE ATTACHED],
						SUM([ENROLLMENT ONLY])[ENROLLMENT ONLY],SUM([EDUC INSTITUTION CLOSED])[EDUC INSTITUTION CLOSED],
						SUM([ALERT/BOARD ACTION])[ALERT/BOARD ACTION]
INTO #OverseasEducationALLPivot
FROM
(
	SELECT  [Report Number],[CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
			[COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
			[UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
			[ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]
	FROM
		(
		  SELECT  [Report Number],[Status],[SectSubStatus] FROM #OverseasEducation
		) As SourceTableEducation
		PIVOT (
				Count([Status]) for [Status] in
								(	[CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
									[COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
									[UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
									[ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]
								)
		)AS PivotTableEducation
)A
GROUP BY [Report Number]

--SELECT * FROM #OverseasEducationALLPivot order by [Report Number]


select A.*,
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Date Discrepancy'  and A.[Report Number] =tct.[Report Number]) as [Edu ALERT Date Discrepancy] ,
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Degree/Studies Discrepancy'  and A.[Report Number] =tct.[Report Number]) as [Edu ALERT Degree/Studies Discrepancy], 
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Enrollment Only'  and A.[Report Number] =tct.[Report Number]) as [Edu ALERT Enrollment Only],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Not Accredited'  and A.[Report Number] =tct.[Report Number]) as [Edu ALERT Not Accredited],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Follow Up ETA'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED Follow Up ETA],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Need More Information'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED Need More Information],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='No Records Found'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIEd No Records Found], 
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='School Permanently Closed'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED School Permanently Closed],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Records on Hold'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED Records on Hold],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='School Unresponsive'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED School Unresponsive],
(select count(1) from #OverseasEducation tct  where tct.SectSubStatus='Record Found'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED Record Found],
(select count(1) from #OverseasEducation tct  where tct.[International/Overseas]='YES'  and A.[Report Number] =tct.[Report Number]) as [Edu International Total]
--(select count(1) from #OverseasEducation tct  where tct.Status ='Verified'  and A.[Report Number] =tct.[Report Number]) as [Edu VERIFIED Total],
--(select count(1) from #OverseasEducation tct  where tct.Status ='Unverified'  and A.[Report Number] =tct.[Report Number]) as [Edu UNVERIFIED Total],
--(select count(1) from #OverseasEducation tct  where tct.Status ='VERIFIED/SEE ATTACHED'  and A.[Report Number] =tct.[Report Number]) as [Edu VERIFIED/SEE ATTACHED Total],
--(select count(1) from #OverseasEducation tct  where tct.Status ='ENROLLMENT ONLY'  and A.[Report Number] =tct.[Report Number]) as [Edu Enrollment Only Total],
--(select count(1) from #OverseasEducation tct  where tct.Status ='ALERT'  and A.[Report Number] =tct.[Report Number]) as [Edu Alert Total],
--(select count(1) from #OverseasEducation tct Where A.[Report Number] =tct.[Report Number] ) as [Edu Status/Sub Status Total]
INTO #OverseasEducationByClient
FROM #ApplicantContactPivot A
--#ApplicantTotal A


--SELECT * FROM #OverseasEducationByClient


SELECT A.*, ISNULL(o.[CLEAR],0) as [Edu Clear], ISNULL(o.[VERIFIED],0) as [Edu Verified], ISNULL(o.[VERIFIED/SEE ATTACHED],0) as [Edu VERIFIED/SEE ATTACHED],
ISNULL(o.[COMPLETE],0) as [Edu COMPLETE], ISNULL(o.[COMPLETE/SEE ATTACHED],0) as [Edu COMPLETE/SEE ATTACHED],
-- ISNULL(o.[ALERT],0)as [Edu ALERT],
ISNULL(o.[ALERT/SEE ATTACHED],0)as [Edu ALERT/SEE ATTACHED], ISNULL(o.[UNVERIFIED],0)as [Edu UNVERIFIED],
ISNULL(o.[UNVERIFIED/SEE ATTACHED],0)as [Edu UNVERIFIED/SEE ATTACHED], ISNULL(o.[SEE ATTACHED],0)as [Edu SEE ATTACHED],
ISNULL(o.[ENROLLMENT ONLY],0)as [Edu ENROLLMENT ONLY], ISNULL(o.[EDUC INSTITUTION CLOSED],0)as [Edu EDUC INSTITUTION CLOSED],
ISNULL(o.[ALERT/BOARD ACTION],0)as [Edu ALERT/BOARD ACTION]
INTO #OverseasEducationALL
FROM #OverseasEducationByClient A
LEFT OUTER JOIN #OverseasEducationALLPivot as o ON A.[Report Number] = o.[Report Number] 

--SELECT * FROM #OverseasEducationALL


----4.[Overseas Employments by Clients by Date Range]

SELECT   E.Apno [Report Number],
E.Employer AS Employer, 
E.city AS [Emp City],
E.[state] AS [Emp State],
CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International/Overseas], 
S.[Description] AS [Status], 
isnull(sss.SectSubStatus, '') as [SectSubStatus]
INTO #OverseasEmployment   
FROM #SLADetailsByClient AS A(NOLOCK)
INNER JOIN dbo.Empl AS E(NOLOCK) ON A.[Report Number] = E.APNO
INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE
LEFT JOIN dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID
WHERE IsonReport = 1
ORDER BY  A.[Client ID], A.[Report Number]
--E.APNO, [status], [SectSubStatus]


-- SELECT * FROM #OverseasEmployment


SELECT [Report Number],SUM([CLEAR])[CLEAR],SUM([VERIFIED])[VERIFIED],SUM([VERIFIED/SEE ATTACHED])[VERIFIED/SEE ATTACHED],
						SUM([COMPLETE])[COMPLETE],SUM([COMPLETE/SEE ATTACHED])[COMPLETE/SEE ATTACHED], SUM([ALERT])[ALERT], 
						SUM([ALERT/SEE ATTACHED])[ALERT/SEE ATTACHED],SUM([UNVERIFIED])[UNVERIFIED],
						SUM([UNVERIFIED/SEE ATTACHED])[UNVERIFIED/SEE ATTACHED], SUM([SEE ATTACHED])[SEE ATTACHED],
						SUM([ENROLLMENT ONLY])[ENROLLMENT ONLY],SUM([EDUC INSTITUTION CLOSED])[EDUC INSTITUTION CLOSED],
						SUM([ALERT/BOARD ACTION])[ALERT/BOARD ACTION]
INTO #OverseasEmploymentALLPivot
FROM
(
			SELECT [Report Number],[CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
						[COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
						[UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
						[ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]			 
			FROM
				(
					SELECT [Report Number],[Status],[SectSubStatus] FROM #OverseasEmployment
				) As SourceTableEmployment
			PIVOT 
			(
				Count([Status]) for [Status] in ([CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
												[COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
												[UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
												[ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]
											 )
			)AS PivotTableEmployment
)A
GROUP BY [Report Number]

-- SELECT * FROM #OverseasEmploymentALLPivot

select A.*,
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Agency Verification'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Agency Verification],
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Discharge'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Discharge],
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Not Eligible for Rehire'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Not Eligible for Rehire],
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Records Found – Date Discrepancy'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Records Found – Date Discrepancy],
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Records Found – Position Discrepancy'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Records Found – Position Discrepancy],
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Voicemail Verified'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Voicemail Verified],
(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and te.[SectSubStatus] ='Company Policy'  and A.[Report Number] =te.[Report Number]) as [Emp ALERT Company Policy],

(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Follow Up ETA' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Follow Up ETA],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Need More Info' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Need More Info],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Need Release' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Need Release],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='No Records' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED No Records],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='No Response' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED No Response],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Records No Longer Available' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Records No Longer Available],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Business Closed' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Business Closed],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Non-Paid Position' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Non-Paid Position],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Self-Employment' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Self-Employment],
(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='Canceled By Client' and A.[Report Number] =te.[Report Number]) as [Emp UNVERIFIED Canceled By Client],

(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Records Found'  and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Records Found],
(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Provided by Supervisor'  and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Provided by Supervisor],
(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Provided by Colleague'  and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Provided by Colleague],
(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Provided by Non-HR Source'  and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Provided by Non-HR Source],
(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Third Party Verification'  and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Third Party Verification],
(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Records No Longer Available'  and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Records No Longer Available],

--(select  count(1) from #OverseasEmployment te where te.Status ='VERIFIED' and A.[Report Number] =te.[Report Number]) as [Emp VERIFIED Total],
--(select  count(1) from #OverseasEmployment te where te.Status ='UNVERIFIED' and A.[Report Number] = te.[Report Number]) as [Emp Unverified Total],
(select  count(1) from #OverseasEmployment te where te.[International/Overseas]='Yes' and A.[Report Number] =te.[Report Number]) as [TotalEmpInternational]
--(select  count(1) from #OverseasEmployment te where te.Status ='Alert' and A.[Report Number] = te.[Report Number]) as [Emp Alert Total],
--(select  count(1) from #OverseasEmployment te Where A.[Report Number] =te.[Report Number]) as [Emp Status/Sub Status Total]
INTO #OverseasEmploymentByClient
FROM #OverseasEducationALL A


--SELECT * FROM #OverseasEmploymentByClient


SELECT A.*, ISNULL(o.[CLEAR],0) as [Emp Clear], ISNULL(o.[VERIFIED],0) as [Emp Verified],
ISNULL(o.[VERIFIED/SEE ATTACHED],0) as [Emp VERIFIED/SEE ATTACHED],
ISNULL(o.[COMPLETE],0) as [Emp COMPLETE], ISNULL(o.[COMPLETE/SEE ATTACHED],0) as [Emp COMPLETE/SEE ATTACHED],
-- ISNULL(o.[ALERT],0)as [Emp ALERT],
ISNULL(o.[ALERT/SEE ATTACHED],0) as [Emp ALERT/SEE ATTACHED], ISNULL(o.[UNVERIFIED],0) as [Emp UNVERIFIED], 
ISNULL(o.[UNVERIFIED/SEE ATTACHED],0) as [Emp UNVERIFIED/SEE ATTACHED],
ISNULL(o.[SEE ATTACHED],0) as [Emp SEE ATTACHED], ISNULL(o.[ENROLLMENT ONLY],0) as [Emp ENROLLMENT ONLY],
ISNULL(o.[EDUC INSTITUTION CLOSED],0) as [Emp EDUC INSTITUTION CLOSED],
ISNULL(o.[ALERT/BOARD ACTION],0)as [Emp ALERT/BOARD ACTION]
INTO #OverseasEmploymentALL
FROM #OverseasEmploymentByClient A
LEFT OUTER JOIN #OverseasEmploymentALLPivot as o ON A.[Report Number] = o.[Report Number]

--SELECT * FROM #OverseasEmploymentALL


--- 5. [Client Verified Rate - License with Affiliate -Report Revised]

SELECT  P.APNO [Report Number]
, P.Lic_Type_V AS 'License Type'
, P.State_V AS 'License State'
, P.Lic_No_V as [License Number]
, S.[Description] AS 'Status'
, isnull(sss.SectSubStatus, '') as [SectSubStatus] into #ClientVerifiedRateLicense
FROM #SLADetailsByClient A  with(nolock) 
INNER JOIN ProfLic P with(nolock) ON A.[Report Number] = P.Apno     
INNER JOIN SectStat S with(nolock) ON S.Code = P.SectStat   
LEFT JOIN dbo.SectSubStatus sss (nolock) on [P].SectStat = sss.SectStatusCode and [P].SectSubStatusID = sss.SectSubStatusID
WHERE (P.IsOnReport = 1)    
AND P.IsHidden = 0 

--Select * from #ClientVerifiedRateLicense

SELECT [Report Number],SUM([CLEAR])[CLEAR],SUM([VERIFIED])[VERIFIED],SUM([VERIFIED/SEE ATTACHED])[VERIFIED/SEE ATTACHED],
						SUM([COMPLETE])[COMPLETE],SUM([COMPLETE/SEE ATTACHED])[COMPLETE/SEE ATTACHED], SUM([ALERT])[ALERT], 
						SUM([ALERT/SEE ATTACHED])[ALERT/SEE ATTACHED],SUM([UNVERIFIED])[UNVERIFIED],
						SUM([UNVERIFIED/SEE ATTACHED])[UNVERIFIED/SEE ATTACHED], SUM([SEE ATTACHED])[SEE ATTACHED],
						SUM([ENROLLMENT ONLY])[ENROLLMENT ONLY],SUM([EDUC INSTITUTION CLOSED])[EDUC INSTITUTION CLOSED],
						SUM([ALERT/BOARD ACTION])[ALERT/BOARD ACTION]
INTO #ClientVerifiedLicenseALLPivot
FROM
(
	SELECT  [Report Number],[CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
			[COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
			[UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
			[ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]
	FROM
		(
			SELECT  [Report Number],[Status],[SectSubStatus] FROM #ClientVerifiedRateLicense
		) As SourceTableLicense
	PIVOT (
			Count( [Status]) for [Status] in ([CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
											  [COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
											  [UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
											  [ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]
											 )
		  )AS PivotTableLicense
)A
GROUP BY [Report Number]

--Select * from ##ClientVerifiedLicenseALLPivot

select A.*,
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='License/Certification Type Mismatch' and A.[Report Number] =te.[Report Number]) as [Lic ALERT License/Certification Type Mismatch],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='Issue Date Mismatch' and A.[Report Number] =te.[Report Number]) as [Lic ALERT Issue Date Mismatch],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='License/Certification Number Mismatch' and A.[Report Number] =te.[Report Number]) as [Lic ALERT License/Certification Number Mismatch],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='No License/Certification Number Issued' and A.[Report Number] =te.[Report Number]) as [Lic ALERT No License/Certification Number Issued],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='Credential Verified through Different State' and A.[Report Number] =te.[Report Number]) as [Lic ALERT Credential Verified through Different State],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='Other Identifiers Used for Verification' and A.[Report Number] =te.[Report Number]) as [Lic ALERT Other Identifiers Used for Verification],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='License/Certification is Not Renewed' and A.[Report Number] =te.[Report Number]) as [Lic ALERT License/Certification is Not Renewed],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and te.[SectSubStatus] ='Canceled By Client' and A.[Report Number] =te.[Report Number]) as [Lic ALERT Canceled By Client],

(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Non-Verifiable' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Non-Verifiable],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Need Fee Approval' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Need Fee Approval],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='State Does Not Regulate' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED State Does Not Regulate],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Applicant has Recently Applied' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Applicant has Recently Applied],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Verification has been Requested' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Verification has been Requested],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Board Website Down' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Board Website Down],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='License/Certification Number Needed' and A.[Report Number] =te.[Report Number] ) as [Lic SEE ATTACHED License/Certification Number Needed],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Valid License Number Needed – Multiple Listings Found' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Valid License Number Needed – Multiple Listings Found],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Valid License Number Needed – Single Listing Found' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Valid License Number Needed – Single Listing Found],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='State Needed' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED State Needed],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Not Available' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Not Available],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and te.[SectSubStatus] ='Issuing Organization Needed' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Issuing Organization Needed],

(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='VERIFIED' and te.[SectSubStatus] ='Record Found'and A.[Report Number] =te.[Report Number]) as [Lic VERIFIED Record Found],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='UNVERIFIED' and te.[SectSubStatus] ='No Record Found' and A.[Report Number] =te.[Report Number]) as [Lic UNVERIFIED No Record Found],

(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='Alert' and A.[Report Number] =te.[Report Number]) as [Lic Alert Total],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='ALERT/BOARD ACTION' and A.[Report Number] =te.[Report Number]) as [Lic ALERT/BOARD ACTION Total],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='ALERT/SEE ATTACHED' and A.[Report Number] =te.[Report Number]) as [Lic ALERT/SEE ATTACHED Total],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='SEE ATTACHED' and A.[Report Number] =te.[Report Number]) as [Lic SEE ATTACHED Total],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='VERIFIED' and A.[Report Number] =te.[Report Number]) as [Lic VERIFIED Total],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='VERIFIED/SEE ATTACHED' and A.[Report Number] =te.[Report Number]) as [Lic VERIFIED/SEE ATTACHED Total],
(select  count(1) from #ClientVerifiedRateLicense te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number]) as [Lic UNVERIFIED Total],
(select  count(1) from #ClientVerifiedRateLicense te ) as [Lic Status/Sub Status Total]
into #VerifiedRateLicense
FROM #OverseasEmploymentALL A


--SELECT * FROM #VerifiedRateLicense

SELECT A.*, ISNULL(o.[CLEAR],0) as [Lic Clear],ISNULL(o.[VERIFIED],0) as [Lic Verified],ISNULL(o.[VERIFIED/SEE ATTACHED],0) as [Lic VERIFIED/SEE ATTACHED],
ISNULL(o.[COMPLETE],0) as [Lic COMPLETE],ISNULL(o.[COMPLETE/SEE ATTACHED],0) as [Lic COMPLETE/SEE ATTACHED], ISNULL(o.[ALERT],0)as [Lic ALERT],
ISNULL(o.[ALERT/SEE ATTACHED],0)as [Lic ALERT/SEE ATTACHED],
ISNULL(o.[UNVERIFIED],0)as [Lic UNVERIFIED], ISNULL(o.[UNVERIFIED/SEE ATTACHED],0)as [Lic UNVERIFIED/SEE ATTACHED], ISNULL(o.[SEE ATTACHED],0)as [Lic SEE ATTACHED],
ISNULL(o.[ENROLLMENT ONLY],0)as [Lic ENROLLMENT ONLY],ISNULL(o.[EDUC INSTITUTION CLOSED],0)as [Lic EDUC INSTITUTION CLOSED],ISNULL(o.[ALERT/BOARD ACTION],0)as [Lic ALERT/BOARD ACTION]
INTO #ClientVerifiedLicenseALL
FROM #VerifiedRateLicense A
LEFT OUTER JOIN #ClientVerifiedLicenseALLPivot as o ON A.[Report Number] = o.[Report Number]

--SELECT * FROM #ClientVerifiedLicenseALL

---- 6.[Client Verified Rate - PersRef with Affiliate]

SELECT DISTINCT [pr].APNO [Report Number],                
[st].[Description] AS [Status],
isnull(sss.SectSubStatus, '') as [SectSubStatus]  into #ClientVerifiedRatePersRef
FROM #SLADetailsByClient AS sl(NOLOCK)
INNER JOIN [PersRef] AS [pr](NOLOCK) ON [sl].[Report Number] = [pr].APNO
INNER JOIN SectStat AS st(NOLOCK) ON [pr].SectStat = st.Code
Left join dbo.SectSubStatus sss (nolock) on [pr].SectStat = sss.SectStatusCode and [pr].SectSubStatusID = sss.SectSubStatusID
WHERE ([pr].IsOnReport = 1)
AND ([pr].[IsHidden] = '')


-- SELECT * FROM #ClientVerifiedRatePersRef

SELECT [Report Number],SUM([CLEAR])[CLEAR],SUM([VERIFIED])[VERIFIED],SUM([VERIFIED/SEE ATTACHED])[VERIFIED/SEE ATTACHED],
						SUM([COMPLETE])[COMPLETE],SUM([COMPLETE/SEE ATTACHED])[COMPLETE/SEE ATTACHED], SUM([ALERT])[ALERT], 
						SUM([ALERT/SEE ATTACHED])[ALERT/SEE ATTACHED],SUM([UNVERIFIED])[UNVERIFIED],
						SUM([UNVERIFIED/SEE ATTACHED])[UNVERIFIED/SEE ATTACHED], SUM([SEE ATTACHED])[SEE ATTACHED],
						SUM([ENROLLMENT ONLY])[ENROLLMENT ONLY],SUM([EDUC INSTITUTION CLOSED])[EDUC INSTITUTION CLOSED],
						SUM([ALERT/BOARD ACTION])[ALERT/BOARD ACTION]
INTO #ClientVerifiedReferenceALLPivot
FROM 
(
		SELECT [Report Number],[CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
			   [COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
			   [UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
			   [ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]	
		FROM
			(
			  SELECT [Report Number],[Status],[SectSubStatus] FROM #ClientVerifiedRatePersRef
			) As SourceTableReference
		PIVOT (
				Count( [Status]) for [Status] in ([CLEAR],[VERIFIED],[VERIFIED/SEE ATTACHED],
												  [COMPLETE],[COMPLETE/SEE ATTACHED], [ALERT], [ALERT/SEE ATTACHED],
												  [UNVERIFIED], [UNVERIFIED/SEE ATTACHED], [SEE ATTACHED],
												  [ENROLLMENT ONLY],[EDUC INSTITUTION CLOSED],[ALERT/BOARD ACTION]
												 )
			 )AS PivotTableReference
)A
GROUP BY [Report Number]

select A.*,
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Unable to Comment per Policy (Reference Works with Applicant)') as [PersRef UNVERIFIED Unable to Comment per Policy (Reference Works with Applicant)],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Declined/Refused to Provide Reference Comments') as [PersRef UNVERIFIED Declined/Refused to Provide Reference Comments],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Invalid Reference Contact Information') as [PersRef UNVERIFIED Invalid Reference Contact Information],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='No Response from Reference') as [PersRef UNVERIFIED No Response from Reference],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Reference is Deceased') as [PersRef UNVERIFIED Reference is Deceased],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Overseas/International') as [PersRef UNVERIFIED Overseas/International],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Missing Information') as [PersRef UNVERIFIED Missing Information],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Client Cancelled') as [PersRef UNVERIFIED Client Cancelled],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='VERIFIED' and A.[Report Number] =te.[Report Number] and te.[SectSubStatus] ='Record Found') as [PersRef VERIFIED Record Found],

(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='UNVERIFIED' and A.[Report Number] =te.[Report Number]) as [PersRef UNVERIFIED Total],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='COMPLETE' and A.[Report Number] =te.[Report Number]) as [PersRef COMPLETE Total],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='VERIFIED' and A.[Report Number] =te.[Report Number]) as [PersRef Verified Total],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='VERIFIED/SEE ATTACHED' and A.[Report Number] =te.[Report Number]) as [PersRef VERIFIED/SEE ATTACHED Total],
(select  count(1) from #ClientVerifiedRatePersRef te where te.Status ='ALERT' and A.[Report Number] =te.[Report Number]) as [PersRef ALERT Total],
(select  count(1) from #ClientVerifiedRatePersRef te ) as [PersRef Status/Sub Status Total]
into #VerifiedRatePersRef
FROM #ClientVerifiedLicenseALL A

--SELECT * FROM #VerifiedRatePersRef


SELECT A.*, ISNULL(o.[CLEAR],0) as [PersRef Clear],ISNULL(o.[VERIFIED],0) as [PersRef Verified],ISNULL(o.[VERIFIED/SEE ATTACHED],0) as [PersRef VERIFIED/SEE ATTACHED],
ISNULL(o.[COMPLETE],0) as [PersRef COMPLETE],ISNULL(o.[COMPLETE/SEE ATTACHED],0) as [PersRef COMPLETE/SEE ATTACHED], ISNULL(o.[ALERT],0)as [PersRef ALERT],
ISNULL(o.[ALERT/SEE ATTACHED],0)as [PersRef ALERT/SEE ATTACHED],ISNULL(o.[UNVERIFIED],0)as [PersRef UNVERIFIED],
ISNULL(o.[UNVERIFIED/SEE ATTACHED],0)as [PersRef UNVERIFIED/SEE ATTACHED], ISNULL(o.[SEE ATTACHED],0)as [PersRef SEE ATTACHED],
ISNULL(o.[ENROLLMENT ONLY],0)as [PersRef ENROLLMENT ONLY],ISNULL(o.[EDUC INSTITUTION CLOSED],0)as [PersRef EDUC INSTITUTION CLOSED],
ISNULL(o.[ALERT/BOARD ACTION],0)as [PersRef ALERT/BOARD ACTION]
INTO #ClientVerifiedReferenceALL
FROM #VerifiedRatePersRef A
LEFT OUTER JOIN #ClientVerifiedReferenceALLPivot as o ON A.[Report Number] = o.[Report Number]

--select * from #ClientVerifiedReferenceALL


SELECT 
	[Report Month],[Client ID],[Client Name],[Client State],[Affiliate],[CandidateID],[Contact Name],[Report Number],[Report Create Date],
	[Original Closed Date],[Reopen Date],[Complete Date],[Submitted Via],[Applicant Last],[Applicant First],[SSN],[DOB],[Applicant State],[Selected Package],
	[Emp Email Applicant Involvement],[Emp Email Institution Location],	[Emp Email Institution Name/Issuing Organization],[Emp Email International],
	[Emp Email No Records Found],[Emp Email Non Responsive],[Emp Email Other],[Emp Email State GED],[Edu Email Applicant Involvement],
	[Edu Email Institution Location],[Edu Email No Records Found],[Edu Email Proof],[Edu Email International],[Edu Email Institution Name/Issuing Organization],
	[Edu Email Other],[Edu Email State GED],[Lic Both Applicant Involvement],[Lic Both Institution Name/Issuing Organization],
	[Lic Both License #/Correct # Needed],[Lic Both No Records Found],[Lic Email Institution Name/Issuing Organization],
	[Lic Email License #/Correct # Needed],[Lic Phone No Records Found],[Emp Appl Contact Total],[Edu Appl Contact Total],[Lic Appl Contact Total],
	[Appl Contact Grand Total],
	--[Applicant Contact Education],[Applicant Contact Employment],[Applicant Contact Professional License],
	[Edu ALERT Date Discrepancy],[Edu ALERT Degree/Studies Discrepancy],
	[Edu ALERT Enrollment Only],[Edu ALERT Not Accredited],[Edu UNVERIFIED Follow Up ETA],[Edu UNVERIFIED Need More Information],
	[Edu UNVERIFIEd No Records Found],[Edu UNVERIFIED School Permanently Closed],[Edu UNVERIFIED Records on Hold],
	[Edu UNVERIFIED School Unresponsive],[Edu UNVERIFIED Record Found],[Edu International Total],
	--[Edu VERIFIED Total],[Edu UNVERIFIED Total],[Edu VERIFIED/SEE ATTACHED Total],[Edu Enrollment Only Total],[Edu Alert Total],[Edu Status/Sub Status Total],
	[Edu Clear],[Edu Verified],[Edu VERIFIED/SEE ATTACHED],[Edu COMPLETE],[Edu COMPLETE/SEE ATTACHED],
	--[Edu ALERT],
	[Edu ALERT/SEE ATTACHED],
	[Edu UNVERIFIED],[Edu UNVERIFIED/SEE ATTACHED],[Edu SEE ATTACHED],[Edu ENROLLMENT ONLY],[Edu EDUC INSTITUTION CLOSED],[Edu ALERT/BOARD ACTION],
	[Emp ALERT Agency Verification],[Emp ALERT Discharge],[Emp ALERT Not Eligible for Rehire],[Emp ALERT Records Found – Date Discrepancy],
	[Emp ALERT Records Found – Position Discrepancy],[Emp ALERT Voicemail Verified],[Emp ALERT Company Policy],[Emp UNVERIFIED Follow Up ETA],
	[Emp UNVERIFIED Need More Info],[Emp UNVERIFIED Need Release],[Emp UNVERIFIED No Records],[Emp UNVERIFIED No Response],
	[Emp UNVERIFIED Records No Longer Available],[Emp UNVERIFIED Business Closed],[Emp UNVERIFIED Non-Paid Position],
	[Emp UNVERIFIED Self-Employment],[Emp UNVERIFIED Canceled By Client],[Emp VERIFIED Records Found],[Emp VERIFIED Provided by Supervisor],
	[Emp VERIFIED Provided by Colleague],[Emp VERIFIED Provided by Non-HR Source],[Emp VERIFIED Third Party Verification],
	[Emp VERIFIED Records No Longer Available],[TotalEmpInternational],
	--[Emp VERIFIED Total],[Emp Unverified Total],[Emp Alert Total],	[Emp Status/Sub Status Total],
	[Emp Clear],[Emp Verified],[Emp VERIFIED/SEE ATTACHED],[Emp COMPLETE],[Emp COMPLETE/SEE ATTACHED],
	--[Emp ALERT],
	[Emp ALERT/SEE ATTACHED],[Emp UNVERIFIED],[Emp UNVERIFIED/SEE ATTACHED],[Emp SEE ATTACHED],[Emp ENROLLMENT ONLY],
	[Emp EDUC INSTITUTION CLOSED],[Emp ALERT/BOARD ACTION],[Lic ALERT License/Certification Type Mismatch],[Lic ALERT Issue Date Mismatch],
	[Lic ALERT License/Certification Number Mismatch],[Lic ALERT No License/Certification Number Issued],
	[Lic ALERT Credential Verified through Different State],[Lic ALERT Other Identifiers Used for Verification],
	[Lic ALERT License/Certification is Not Renewed],[Lic ALERT Canceled By Client],[Lic SEE ATTACHED Non-Verifiable],
	[Lic SEE ATTACHED Need Fee Approval],[Lic SEE ATTACHED State Does Not Regulate],[Lic SEE ATTACHED Applicant has Recently Applied],
	[Lic SEE ATTACHED Verification has been Requested],[Lic SEE ATTACHED Board Website Down],[Lic SEE ATTACHED License/Certification Number Needed],
	[Lic SEE ATTACHED Valid License Number Needed – Multiple Listings Found],[Lic SEE ATTACHED Valid License Number Needed – Single Listing Found],
	[Lic SEE ATTACHED State Needed],[Lic SEE ATTACHED Not Available],[Lic SEE ATTACHED Issuing Organization Needed],[Lic VERIFIED Record Found],
	[Lic UNVERIFIED No Record Found],[Lic Alert Total],[Lic ALERT/BOARD ACTION Total],[Lic ALERT/SEE ATTACHED Total],[Lic SEE ATTACHED Total],
	[Lic VERIFIED Total],[Lic VERIFIED/SEE ATTACHED Total],	[Lic UNVERIFIED Total],[Lic Status/Sub Status Total],[Lic Clear],[Lic Verified],
	[Lic VERIFIED/SEE ATTACHED],[Lic COMPLETE],[Lic COMPLETE/SEE ATTACHED],[Lic ALERT],[Lic ALERT/SEE ATTACHED],[Lic UNVERIFIED],
	[Lic UNVERIFIED/SEE ATTACHED],[Lic SEE ATTACHED],[Lic ENROLLMENT ONLY],[Lic EDUC INSTITUTION CLOSED],[Lic ALERT/BOARD ACTION],
	[PersRef UNVERIFIED Unable to Comment per Policy (Reference Works with Applicant)],	[PersRef UNVERIFIED Declined/Refused to Provide Reference Comments],
	[PersRef UNVERIFIED Invalid Reference Contact Information],[PersRef UNVERIFIED No Response from Reference],
	[PersRef UNVERIFIED Reference is Deceased],[PersRef UNVERIFIED Overseas/International],[PersRef UNVERIFIED Missing Information],
	[PersRef UNVERIFIED Client Cancelled],[PersRef VERIFIED Record Found],[PersRef UNVERIFIED Total],[PersRef COMPLETE Total],[PersRef Verified Total],
	[PersRef VERIFIED/SEE ATTACHED Total],[PersRef ALERT Total],[PersRef Status/Sub Status Total],[PersRef Clear],[PersRef Verified],
	[PersRef VERIFIED/SEE ATTACHED],[PersRef COMPLETE],[PersRef COMPLETE/SEE ATTACHED],[PersRef ALERT],[PersRef ALERT/SEE ATTACHED],
	[PersRef UNVERIFIED],[PersRef UNVERIFIED/SEE ATTACHED],[PersRef SEE ATTACHED],
	[PersRef ENROLLMENT ONLY],[PersRef EDUC INSTITUTION CLOSED],[PersRef ALERT/BOARD ACTION],
Sum(
	[Edu ALERT Date Discrepancy]+[Edu ALERT Degree/Studies Discrepancy]+[Edu ALERT Enrollment Only]+[Edu ALERT Not Accredited]+
	[Edu UNVERIFIED School Permanently Closed]+[Edu UNVERIFIED Records on Hold]+
	[Edu Clear]+ [Edu Verified]+[Edu VERIFIED/SEE ATTACHED]+[Edu COMPLETE]+[Edu COMPLETE/SEE ATTACHED]+
	--[Edu ALERT]+
	[Edu ALERT/SEE ATTACHED]+
	--[Edu UNVERIFIED]+[Edu UNVERIFIED/SEE ATTACHED]+[Edu SEE ATTACHED]+
	[Edu ENROLLMENT ONLY]+[Edu EDUC INSTITUTION CLOSED]+[Edu ALERT/BOARD ACTION]
	--+ [Edu Status/Sub Status Total]
	) [Edu Rate Count],
Sum(
	--[Edu VERIFIED/SEE ATTACHED Total]+[Edu Enrollment Only Total]+[Edu Alert Total]+
	[Edu ALERT Date Discrepancy]+
	[Edu ALERT Degree/Studies Discrepancy]+[Edu ALERT Enrollment Only]+[Edu ALERT Not Accredited]+
	[Edu UNVERIFIED Follow Up ETA]+[Edu UNVERIFIED Need More Information]+[Edu UNVERIFIEd No Records Found]+
	[Edu UNVERIFIED School Permanently Closed]+[Edu UNVERIFIED Records on Hold]+[Edu UNVERIFIED School Unresponsive]+
	[Edu UNVERIFIED Record Found]+[Edu Clear]+[Edu Verified]+[Edu VERIFIED/SEE ATTACHED]+[Edu COMPLETE]+
	[Edu COMPLETE/SEE ATTACHED]+
	--[Edu ALERT]+
	[Edu ALERT/SEE ATTACHED]+[Edu UNVERIFIED]+[Edu UNVERIFIED/SEE ATTACHED]+
	[Edu SEE ATTACHED]+[Edu ENROLLMENT ONLY]+[Edu EDUC INSTITUTION CLOSED]+[Edu ALERT/BOARD ACTION]
	) [Edu Overall Total] ,
Sum(
	[Emp ALERT Agency Verification]+[Emp ALERT Discharge]+[Emp ALERT Not Eligible for Rehire]+[Emp ALERT Records Found – Date Discrepancy]+
	[Emp ALERT Records Found – Position Discrepancy]+[Emp ALERT Voicemail Verified]+[Emp ALERT Company Policy]+
	[Emp UNVERIFIED Records No Longer Available]+[Emp UNVERIFIED Business Closed]+
	[Emp UNVERIFIED Non-Paid Position]+[Emp UNVERIFIED Self-Employment]+
	[Emp VERIFIED Records Found]+[Emp VERIFIED Provided by Supervisor]+[Emp VERIFIED Provided by Colleague]+
	[Emp VERIFIED Provided by Non-HR Source]+[Emp VERIFIED Third Party Verification]+[Emp VERIFIED Records No Longer Available]+
	[Emp Clear]+[Emp Verified]+[Emp VERIFIED/SEE ATTACHED]+[Emp COMPLETE]+[Emp COMPLETE/SEE ATTACHED]+[Emp ALERT/SEE ATTACHED]+
	[Emp ENROLLMENT ONLY]+[Emp EDUC INSTITUTION CLOSED]+[Emp ALERT/BOARD ACTION] 
	--[Emp ALERT]+[Emp UNVERIFIED]+[Emp UNVERIFIED/SEE ATTACHED]+[Emp SEE ATTACHED]+[Emp Status/Sub Status Total]	
	) [Emp Rate Count],
SUM (
	[Emp ALERT Agency Verification]+[Emp ALERT Discharge]+[Emp ALERT Not Eligible for Rehire]+[Emp ALERT Records Found – Date Discrepancy]+
	[Emp ALERT Records Found – Position Discrepancy]+[Emp ALERT Voicemail Verified]+[Emp ALERT Company Policy] +
	[Emp UNVERIFIED Follow Up ETA]+[Emp UNVERIFIED Need More Info]+[Emp UNVERIFIED Need Release]+
	[Emp UNVERIFIED No Records]+[Emp UNVERIFIED No Response]+[Emp UNVERIFIED Records No Longer Available]+[Emp UNVERIFIED Business Closed]+
	[Emp UNVERIFIED Non-Paid Position]+[Emp UNVERIFIED Self-Employment]+[Emp UNVERIFIED Canceled By Client]+
	[Emp VERIFIED Records Found]+[Emp VERIFIED Provided by Supervisor]+[Emp VERIFIED Provided by Colleague]+[Emp VERIFIED Provided by Non-HR Source]+
	[Emp VERIFIED Third Party Verification]+[Emp VERIFIED Records No Longer Available]+
	[Emp Clear]+[Emp Verified]+[Emp VERIFIED/SEE ATTACHED]+[Emp COMPLETE]+[Emp COMPLETE/SEE ATTACHED]+	
	[Emp ALERT/SEE ATTACHED]+[Emp UNVERIFIED]+[Emp UNVERIFIED/SEE ATTACHED]+[Emp SEE ATTACHED]+[Emp ENROLLMENT ONLY] +
	[Emp EDUC INSTITUTION CLOSED]+[Emp ALERT/BOARD ACTION]
	--[Emp VERIFIED Total]+[Emp Unverified Total]+[Emp Status/Sub Status Total]+[Emp ALERT]+
	) [Emp Overall Total],
Sum(
	[Lic Clear]+[Lic Verified]+[Lic VERIFIED/SEE ATTACHED]+[Lic COMPLETE]+[Lic COMPLETE/SEE ATTACHED]+[Lic ALERT]+
	[Lic ALERT/SEE ATTACHED]+[Lic UNVERIFIED]+[Lic UNVERIFIED/SEE ATTACHED]+[Lic SEE ATTACHED]+[Lic ENROLLMENT ONLY]+
	[Lic EDUC INSTITUTION CLOSED]+[Lic ALERT/BOARD ACTION] +[Lic Status/Sub Status Total]
	) [Lic Rate Count],
Sum(
	[Lic ALERT License/Certification Type Mismatch]+[Lic ALERT Issue Date Mismatch]+[Lic ALERT License/Certification Number Mismatch] +
	[Lic ALERT No License/Certification Number Issued]+[Lic ALERT Credential Verified through Different State]+
	[Lic ALERT Other Identifiers Used for Verification]+[Lic ALERT License/Certification is Not Renewed]+
	[Lic ALERT Canceled By Client]+[Lic ALERT/BOARD ACTION Total]+[Lic ALERT/SEE ATTACHED Total]+[Lic SEE ATTACHED Total]+
	[Lic SEE ATTACHED Non-Verifiable]+[Lic SEE ATTACHED Need Fee Approval]+[Lic SEE ATTACHED State Does Not Regulate]+
	[Lic SEE ATTACHED Applicant has Recently Applied]+[Lic SEE ATTACHED Verification has been Requested]+
	[Lic SEE ATTACHED Board Website Down]+[Lic SEE ATTACHED License/Certification Number Needed]+
	[Lic SEE ATTACHED Valid License Number Needed – Multiple Listings Found]+[Lic SEE ATTACHED Valid License Number Needed – Single Listing Found]+
	[Lic SEE ATTACHED State Needed]+[Lic SEE ATTACHED Not Available]+[Lic SEE ATTACHED Issuing Organization Needed]+
	[Lic VERIFIED Record Found]+[Lic VERIFIED Total]+[Lic VERIFIED/SEE ATTACHED Total]+[Lic UNVERIFIED Total]+
	[Lic UNVERIFIED No Record Found]+[Lic Clear]+[Lic Verified]+[Lic VERIFIED/SEE ATTACHED]+[Lic COMPLETE]+[Lic COMPLETE/SEE ATTACHED] +
	[Lic ALERT]+[Lic ALERT/SEE ATTACHED]+[Lic UNVERIFIED]+[Lic UNVERIFIED/SEE ATTACHED]+[Lic SEE ATTACHED]+[Lic ENROLLMENT ONLY]+
	[Lic EDUC INSTITUTION CLOSED]+[Lic ALERT/BOARD ACTION]
	) [Lic Overall Total],
Sum(
	[PersRef Clear]+ [PersRef Verified]+[PersRef VERIFIED/SEE ATTACHED]+[PersRef COMPLETE]+[PersRef COMPLETE/SEE ATTACHED]+[PersRef ALERT]+
	[PersRef ALERT/SEE ATTACHED]+[PersRef UNVERIFIED]+[PersRef UNVERIFIED/SEE ATTACHED]+[PersRef SEE ATTACHED]+[PersRef ENROLLMENT ONLY]+
	[PersRef EDUC INSTITUTION CLOSED]+[PersRef ALERT/BOARD ACTION] + [PersRef Status/Sub Status Total]
	)[PersRef Rate Count],
Sum(
	[PersRef UNVERIFIED Unable to Comment per Policy (Reference Works with Applicant)]+
	[PersRef UNVERIFIED Declined/Refused to Provide Reference Comments]+[PersRef UNVERIFIED Invalid Reference Contact Information]+
	[PersRef UNVERIFIED No Response from Reference]+[PersRef UNVERIFIED Reference is Deceased]+[PersRef UNVERIFIED Overseas/International]+
	[PersRef UNVERIFIED Missing Information]+[PersRef UNVERIFIED Client Cancelled]+[PersRef VERIFIED Record Found]+[PersRef UNVERIFIED Total]+
	[PersRef COMPLETE Total]+[PersRef Verified Total]+[PersRef VERIFIED/SEE ATTACHED Total]+[PersRef ALERT Total]+[PersRef Clear]+
	[PersRef Verified]+[PersRef VERIFIED/SEE ATTACHED]+[PersRef COMPLETE]+[PersRef COMPLETE/SEE ATTACHED]+[PersRef ALERT]+
	[PersRef ALERT/SEE ATTACHED]+[PersRef UNVERIFIED]+[PersRef UNVERIFIED/SEE ATTACHED]+[PersRef SEE ATTACHED]+[PersRef ENROLLMENT ONLY]+
	[PersRef EDUC INSTITUTION CLOSED]+[PersRef ALERT/BOARD ACTION]
	) [PersRef Overall Total]
INTO #ClientVerifiedRatesBYComponent
FROM #ClientVerifiedReferenceALL 
GROUP BY [Report Month],[Client ID],[Client Name],[Client State],[Affiliate],[CandidateID],[Contact Name],[Report Number],[Report Create Date],[Original Closed Date],[Reopen Date],
		[Complete Date],[Submitted Via],[Applicant Last],[Applicant First],[SSN],[DOB],[Applicant State],[Selected Package],[Emp Email Applicant Involvement],[Emp Email Institution Location],
		[Emp Email Institution Name/Issuing Organization],[Emp Email International],[Emp Email No Records Found],[Emp Email Non Responsive],[Emp Email Other],[Emp Email State GED],[Edu Email Applicant Involvement],
		[Edu Email Institution Location],[Edu Email No Records Found],[Edu Email Proof],[Edu Email International],[Edu Email Institution Name/Issuing Organization],[Edu Email Other],
		[Edu Email State GED],[Lic Both Applicant Involvement],[Lic Both Institution Name/Issuing Organization],[Lic Both License #/Correct # Needed],[Lic Both No Records Found],
		[Lic Email Institution Name/Issuing Organization],[Lic Email License #/Correct # Needed],[Lic Phone No Records Found],[Emp Appl Contact Total],[Edu Appl Contact Total],[Lic Appl Contact Total],
		[Appl Contact Grand Total],
		--[Applicant Contact Education],[Applicant Contact Employment],[Applicant Contact Professional License],
		[Edu ALERT Date Discrepancy],[Edu ALERT Degree/Studies Discrepancy],
		[Edu ALERT Enrollment Only],[Edu ALERT Not Accredited],[Edu UNVERIFIED Follow Up ETA],[Edu UNVERIFIED Need More Information],[Edu UNVERIFIEd No Records Found],[Edu UNVERIFIED School Permanently Closed],
		[Edu UNVERIFIED Records on Hold],[Edu UNVERIFIED School Unresponsive],[Edu UNVERIFIED Record Found],[Edu International Total],
		--[Edu VERIFIED Total],[Edu UNVERIFIED Total],[Edu VERIFIED/SEE ATTACHED Total],[Edu Enrollment Only Total],[Edu Alert Total],[Edu Status/Sub Status Total],
		[Edu Clear],[Edu Verified],[Edu VERIFIED/SEE ATTACHED],[Edu COMPLETE],[Edu COMPLETE/SEE ATTACHED],
		--[Edu ALERT],
		[Edu ALERT/SEE ATTACHED],
		[Edu UNVERIFIED],[Edu UNVERIFIED/SEE ATTACHED],[Edu SEE ATTACHED],[Edu ENROLLMENT ONLY],[Edu EDUC INSTITUTION CLOSED],[Edu ALERT/BOARD ACTION],[Emp ALERT Agency Verification],[Emp ALERT Discharge],
		[Emp ALERT Not Eligible for Rehire],[Emp ALERT Records Found – Date Discrepancy],[Emp ALERT Records Found – Position Discrepancy],[Emp ALERT Voicemail Verified],[Emp ALERT Company Policy],[Emp UNVERIFIED Follow Up ETA],
		[Emp UNVERIFIED Need More Info],[Emp UNVERIFIED Need Release],[Emp UNVERIFIED No Records],[Emp UNVERIFIED No Response],[Emp UNVERIFIED Records No Longer Available],[Emp UNVERIFIED Business Closed],
		[Emp UNVERIFIED Non-Paid Position],[Emp UNVERIFIED Self-Employment],[Emp UNVERIFIED Canceled By Client],[Emp VERIFIED Records Found],[Emp VERIFIED Provided by Supervisor],[Emp VERIFIED Provided by Colleague],
		[Emp VERIFIED Provided by Non-HR Source],[Emp VERIFIED Third Party Verification],[Emp VERIFIED Records No Longer Available],[TotalEmpInternational],
		--[Emp VERIFIED Total],[Emp Unverified Total],[Emp Alert Total],
		--[Emp Status/Sub Status Total],
		[Emp Clear],[Emp Verified],[Emp VERIFIED/SEE ATTACHED],[Emp COMPLETE],[Emp COMPLETE/SEE ATTACHED],
		--[Emp ALERT],
		[Emp ALERT/SEE ATTACHED],[Emp UNVERIFIED],[Emp UNVERIFIED/SEE ATTACHED],
		[Emp SEE ATTACHED],[Emp ENROLLMENT ONLY],[Emp EDUC INSTITUTION CLOSED],[Emp ALERT/BOARD ACTION],[Lic ALERT License/Certification Type Mismatch],[Lic ALERT Issue Date Mismatch],[Lic ALERT License/Certification Number Mismatch],
		[Lic ALERT No License/Certification Number Issued],[Lic ALERT Credential Verified through Different State],[Lic ALERT Other Identifiers Used for Verification],[Lic ALERT License/Certification is Not Renewed],
		[Lic ALERT Canceled By Client],[Lic SEE ATTACHED Non-Verifiable],[Lic SEE ATTACHED Need Fee Approval],[Lic SEE ATTACHED State Does Not Regulate],[Lic SEE ATTACHED Applicant has Recently Applied],
		[Lic SEE ATTACHED Verification has been Requested],[Lic SEE ATTACHED Board Website Down],[Lic SEE ATTACHED License/Certification Number Needed],[Lic SEE ATTACHED Valid License Number Needed – Multiple Listings Found],
		[Lic SEE ATTACHED Valid License Number Needed – Single Listing Found],[Lic SEE ATTACHED State Needed],[Lic SEE ATTACHED Not Available],[Lic SEE ATTACHED Issuing Organization Needed],[Lic VERIFIED Record Found],
		[Lic UNVERIFIED No Record Found],[Lic Alert Total],[Lic ALERT/BOARD ACTION Total],[Lic ALERT/SEE ATTACHED Total],[Lic SEE ATTACHED Total],[Lic VERIFIED Total],[Lic VERIFIED/SEE ATTACHED Total],
		[Lic UNVERIFIED Total],[Lic Status/Sub Status Total],[Lic Clear],[Lic Verified],[Lic VERIFIED/SEE ATTACHED],[Lic COMPLETE],[Lic COMPLETE/SEE ATTACHED],[Lic ALERT],[Lic ALERT/SEE ATTACHED],[Lic UNVERIFIED],
		[Lic UNVERIFIED/SEE ATTACHED],[Lic SEE ATTACHED],[Lic ENROLLMENT ONLY],[Lic EDUC INSTITUTION CLOSED],[Lic ALERT/BOARD ACTION],[PersRef UNVERIFIED Unable to Comment per Policy (Reference Works with Applicant)],
		[PersRef UNVERIFIED Declined/Refused to Provide Reference Comments],[PersRef UNVERIFIED Invalid Reference Contact Information],[PersRef UNVERIFIED No Response from Reference],
		[PersRef UNVERIFIED Reference is Deceased],[PersRef UNVERIFIED Overseas/International],[PersRef UNVERIFIED Missing Information],[PersRef UNVERIFIED Client Cancelled],[PersRef VERIFIED Record Found],
		[PersRef UNVERIFIED Total],[PersRef COMPLETE Total],[PersRef Verified Total],[PersRef VERIFIED/SEE ATTACHED Total],[PersRef ALERT Total],[PersRef Status/Sub Status Total],[PersRef Clear],[PersRef Verified],
		[PersRef VERIFIED/SEE ATTACHED],[PersRef COMPLETE],[PersRef COMPLETE/SEE ATTACHED],[PersRef ALERT],[PersRef ALERT/SEE ATTACHED],[PersRef UNVERIFIED],[PersRef UNVERIFIED/SEE ATTACHED],[PersRef SEE ATTACHED],
		[PersRef ENROLLMENT ONLY],[PersRef EDUC INSTITUTION CLOSED],[PersRef ALERT/BOARD ACTION]


SELECT *, 
		ISNULL(([Edu Rate Count]*100 /NULLIF([Edu Overall Total],0)),' ') AS [Edu VR],
		ISNULL(([Emp Rate Count]*100/NULLIF([Emp Overall Total],0)),' ') AS [Emp VR],
		ISNULL(([Lic Rate Count]*100/NULLIF([Lic Overall Total],0)),' ') AS [Lic VR],
		ISNULL(([PersRef Rate Count]*100/NULLIF([PersRef Overall Total],0)),' ') AS [PersRef VR]
FROM #ClientVerifiedRatesBYComponent




END