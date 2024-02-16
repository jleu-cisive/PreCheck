-- =============================================
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
--EXEC [PBI_StewardExecutiveAccessDashboard_Applications] 2019,228,15382,7519 --02sec
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_Applications
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint,
@ParentEmployerID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
SELECT DISTINCT GETDATE() DateDataRefreshed, c.AffiliateID, a.APNO, a.Last + ', ' + a.First FullName, a.Sex, a.ApStatus AppStatus, a.EnteredVia
	, a.ApDate DateCreated, cer.ClientCertUpdated DateCertified, a.OrigCompDate, a.ReopenDate, a.CompDate
	, a.CLNO ClientId, c.Name ClientName, c.State ClientState, aff.Affiliate AffiliateName
	,ISNULL(COALESCE(cpm.PackageDesc, dpm.PackageDesc), 'NO PACKAGE') PackageName, COALESCE(cpm.DefaultPrice, dpm.DefaultPrice) PackagePrice
	,ISNULL(f.IsOneHR, 0) IsOneHR
FROM dbo.Appl a with(nolock) --5894
INNER JOIN dbo.ClientPackages cp with(Nolock) --This will help get the actual package for this client
	ON a.CLNO = cp.CLNO AND cp.PackageID = a.PackageID
LEFT JOIN PackageMain cpm with(nolock)
	ON cp.PackageID = cpm.PackageID
LEFT JOIN PackageMain dpm with(nolock) 
	ON a.PackageID = dpm.PackageID
INNER JOIN dbo.ClientCertification cer with(nolock)
	ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
INNER JOIN client c with(nolock) 
	ON c.clno = a.clno
INNER JOIN refAffiliate aff with(nolock) 
	ON aff.AffiliateID = c.AffiliateID
	LEFT JOIN
	(SELECT FacilityID, FacilityNum, FacilityName, Division, IsOneHR, ROW_NUMBER() OVER (PARTITION by FacilityNum ORDER BY FacilityID DESC) RowNumber 
	  from HEVN.dbo.Facility with(nolock
	  ) WHERE ParentEmployerID = @ParentEmployerID /*7519*/) f 
	  ON isnull(a.deptcode,0) = f.FacilityNum AND f.RowNumber=1
WHERE year(a.OrigCompDate) >= @Year -- 2019
AND c.AffiliateID IN (@AffiliateID) /*228*/
AND c.weborderparentclno = @weborderparentclno /*15382*/
AND a.OrigCompDate IS NOT NULL
    
END

