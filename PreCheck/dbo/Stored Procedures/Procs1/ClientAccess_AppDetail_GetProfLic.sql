
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-21-2008
-- Description:	 Gets PROFESSIONAL License Details for the client in Check Reports
-- EXEC ClientAccess_AppDetail_GetProfLic 3993277
-- Modified By : Radhika Dereddy on 12/20/2018
-- Modified reason: When ETA project went Live the Adjudication Process was impacted(broken), so now making the changes to the Stored procedure to accommodate the functionality of the
-- Adjudication clients, Non adjudicatio clients and the ETA (Estimated Time Aggregate)process so all the statuses are displayed as intended.
-- Remove the functionality specific to AffiliateID 10 (which is 12444 - Tenet) -- this fucntionality is across the clients and not just for one client.
-- Remove the bit field for @HasETA, this is a varchar value
-- Modified by AmyLiu on 08/17/2020: for project IntranetModule status-substatus to show status and its substatus
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetProfLic]
@apno int ,
@AdjudicationProcess bit = 0,
@clno int = 0
AS

 Declare @HasETA varchar(10)
 SET @HasETA = (Select ISNULL((Select Value from ClientConfiguration where CLNO = @clno AND ConfigurationKey = 'Report_&_Component_ETA_Display_In_Client_Access'), 'false'))


Select proflicid,lic_type,
	CASE WHEN sectstat.code in('0', '9', 'A','R') and LOWER(@HasETA) = 'true' THEN 
				CASE WHEN CAST(eta.ETADate AS DATE) < CAST(CURRENT_TIMESTAMP AS DATE) THEN 'ETA Unavailable' 
					 ELSE 'ETA: ' + LEFT(CONVERT(VARCHAR, eta.ETADate, 101), 10) 
				END 
	ELSE isnull((case when Isnull(@AdjudicationProcess,0) =1 then ( Case WHEN A.Apstatus ='F' AND proflic.sectstat in ('4','5') THEN 'CLEAR' ELSE (
						(CASE when AdjStatusCustom.DisplayName is not null then AdjStatusCustom.DisplayName else isnull(AdjStatus.DisplayName,'In Progress') end) ) end)
					else sectstat.Description +'|'+ isnull(sss.SectSubStatus,'')  end),sectstat.Description +'|'+ isnull(sss.SectSubStatus,'') )
	END onlinedescription
FROM proflic 
INNER JOIN APPL A on a.apno  = proflic.apno
LEFT OUTER JOIN SECTSTAT ON proflic.sectstat = sectstat.code 
left join dbo.SectSubStatus sss (nolock) on proflic.SectStat= sss.SectStatusCode and sss.ApplSectionID=4 and proflic.SectSubStatusID = sss.SectSubStatusID 
LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON proflic.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID --and AdjStatus.CLNO = @clno
LEFT JOIN dbo.ClientAdjudicationStatusCustom AdjStatusCustom ON AdjStatusCustom.clno = a.clno and proflic.ClientAdjudicationStatus = AdjStatusCustom.ClientAdjudicationStatusID
LEFT JOIN dbo.ApplSectionsETA eta ON eta.Apno = A.APNO AND eta.SectionKeyID = ProfLic.ProfLicID AND eta.ApplSectionID = 4
where isonreport = 1 and ishidden = 0 and proflic.apno = @apno

SET ANSI_NULLS ON




