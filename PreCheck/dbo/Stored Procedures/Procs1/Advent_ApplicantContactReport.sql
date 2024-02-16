-- =============================================
-- Author:	Sahithi Gangaraju
-- Create date: 2/11/2020
-- Description:	HDT request:67148 
--AdventApplicantContactReport to show all of the applicant contact events from the day prior.
-- ===================================================================================================
CREATE PROCEDURE [dbo].[Advent_ApplicantContactReport]
	
AS
BEGIN
	
	SET NOCOUNT ON;

declare @AffiliateID int = 230
declare @CLNO int = 15355

--drop table #tmpIntegrationRequestDetails
SELECT  	Request.n.value('RequisitionNumber[1]','VARCHAR(30)') AS RequisitionNumber,  
			Request.n.value('ClientApplicationNumber[1]','VARCHAR(30)') AS TransactionID,  
			Request.n.value('CandidateID[1]','VARCHAR(30)') AS CandidateID,
			Request.n.value('RequisitionJobCode[1]','VARCHAR(30)') AS FacilityNumber,  
			Request.n.value('PrimaryLocationCodeDescription[1]','VARCHAR(100)') AS PrimaryLocationCodeDescription,  
			Request.n.value('Last[1]','VARCHAR(50)') AS LastName,
			Request.n.value('First[1]','VARCHAR(50)') AS FirstName,
			R.APNO,
			Request.n.value('Attn[1]','VARCHAR(50)') AS Attn,
			R.FacilityCLNO
		INTO #tmpIntegrationRequestDetails
	FROM Integration_OrderMgmt_Request(nolock) R
	CROSS APPLY TransformedRequest.nodes('//NewApplicant[1]') AS Request(n) 
	WHERE R.CLNO = @CLNO

	--select TOP 10 * FROM Integration_OrderMgmt_Request where CLNO=15355


SELECT
			a.First as ApplicantFirstName,
			a.last as ApplicantLastName,
			tmp.CandidateID,
			tmp.RequisitionNumber as 'Requisition ID',
			c.Name AS 'Facility Name',
	        tmp.Attn AS 'Preboarding Specialist',
			a.APNO as 'Report Number',
			applS.Description AS 'Component Type',
			CASE ac.ApplSectionID
			WHEN 1 THEN (SELECT e.Employer FROM Empl AS e WHERE e.EmplID = ac.SectionUniqueID)
			WHEN 2 THEN (SELECT e.School FROM Educat AS e WHERE e.EducatID = ac.SectionUniqueID)
			WHEN 3 THEN (SELECT p.Name FROM PersRef AS p WHERE p.PersRefID = ac.SectionUniqueID)
			WHEN 4 THEN (SELECT p.Lic_Type FROM ProfLic AS p WHERE p.ProfLicID = ac.SectionUniqueID)
		    END AS 'Component Description',
			rmc.ItemName AS 'Method Of Contact',
			rrc.ItemName AS 'Reason for Contact',
			FORMAT(ac.CreateDate, 'MM/dd/yyyy hh:mm tt') AS 'Date of Contact'
FROM ApplicantContact AS ac WITH (NOLOCK)
INNER JOIN Appl AS a WITH (NOLOCK) ON a.APNO = ac.APNO
INNER JOIN Client AS c WITH (NOLOCK) ON c.CLNO = a.CLNO
INNER JOIN refMethodOfContact AS rmc WITH (NOLOCK) ON rmc.refMethodOfContactID = ac.refMethodOfContactID
INNER JOIN refReasonForContact AS rrc WITH (NOLOCK) ON rrc.refReasonForContactID = ac.refReasonForContactID
INNER JOIN ApplSections AS applS WITH (NOLOCK) ON applS.ApplSectionID = ac.ApplSectionID
inner join #tmpIntegrationRequestDetails  as tmp on tmp.APNO =a.APNO
LEFT JOIN refAffiliate as refAf WITH (NOLOCK) ON refAf.AffiliateID = c.AffiliateID
WHERE CONVERT(DATE, ac.CreateDate)= convert (date ,dateadd(day,datediff(day,1,GETDATE()),0))
AND C.AffiliateID = IIF(@AffiliateID =0, C.AffiliateID, @AffiliateID)
		
drop table #tmpIntegrationRequestDetails

END
