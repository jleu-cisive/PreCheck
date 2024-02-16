-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for ApplicantContacts dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_ApplicantContacts] 2019,228,15382 --00:01:39
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_ApplicantContacts
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
--;WITH cteAppl AS
--(
	SELECT distinct a.APNO
	into #tmp
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer with(nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year--2019
	--AND month(a.apDate) = 1
AND c.AffiliateID IN  (@AffiliateID)--(228)
AND c.weborderparentclno = @weborderparentclno--15382
	AND a.OrigCompDate IS NOT NULL
--)

SELECT
	a.APNO,
	applS.Description ComponentType,
	CASE ac.ApplSectionID
		WHEN 1 THEN (SELECT e.Employer FROM Empl AS e  with(nolock)  WHERE e.EmplID = ac.SectionUniqueID)
		WHEN 2 THEN (SELECT e.School FROM Educat AS e  with(nolock)  WHERE e.EducatID = ac.SectionUniqueID)
		WHEN 3 THEN (SELECT p.Name FROM PersRef AS p  with(nolock)  WHERE p.PersRefID = ac.SectionUniqueID)
		WHEN 4 THEN (SELECT p.Lic_Type FROM ProfLic AS p  with(nolock)  WHERE p.ProfLicID = ac.SectionUniqueID)
	END ComponentDescription,
	CASE ac.ApplSectionID
		WHEN 1 THEN (SELECT ss.Description FROM Empl AS e  with(nolock)  INNER JOIN dbo.SectStat ss   with(nolock)  ON e.SectStat=ss.Code WHERE e.EmplID = ac.SectionUniqueID)
		WHEN 2 THEN (SELECT ss.Description FROM Educat AS e  with(nolock)  INNER JOIN dbo.SectStat ss  with(nolock)  ON e.SectStat=ss.Code WHERE e.EducatID = ac.SectionUniqueID)
		WHEN 3 THEN (SELECT ss.Description FROM PersRef AS p  with(nolock)  INNER JOIN dbo.SectStat ss  with(nolock)  ON p.SectStat=ss.Code WHERE p.PersRefID = ac.SectionUniqueID)
		WHEN 4 THEN (SELECT ss.Description FROM ProfLic AS p  with(nolock)  INNER JOIN dbo.SectStat ss with(nolock)   ON p.SectStat=ss.Code WHERE p.ProfLicID = ac.SectionUniqueID)
	END AS Status,
	rmc.ItemName AS MethodOfContact,
	rrc.ItemName AS ReasonforContact,
	ac.Investigator,
	FORMAT(ac.CreateDate, 'MM/dd/yyyy hh:mm tt') AS DateofContact
FROM ApplicantContact AS ac WITH (NOLOCK)
	INNER JOIN #tmp AS a WITH (NOLOCK) ON a.APNO = ac.APNO
	INNER JOIN refMethodOfContact AS rmc WITH (NOLOCK) ON rmc.refMethodOfContactID = ac.refMethodOfContactID
	INNER JOIN refReasonForContact AS rrc WITH (NOLOCK) ON rrc.refReasonForContactID = ac.refReasonForContactID
	INNER JOIN ApplSections AS applS WITH (NOLOCK) ON applS.ApplSectionID = ac.ApplSectionID

    
END

