
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-21-2008
-- Description:	 Gets Employement Details for the client in Check Reports
-- EXEC [dbo].[ClientAccess_AppDetail_GetEmpl] 5723818, 1, 12771
-- Modified By : Radhika Dereddy on 12/20/2018
-- Modified reason: When ETA project went Live the Adjudication Process was impacted(broken), so now making the changes to the Stored procedure to accommodate the functionality of the
-- Adjudication clients, Non adjudicatio clients and the ETA (Estimated Time Aggregate)process so all the statuses are displayed as intended.
-- Remove the functionality specific to AffiliateID 10 (which is 12444 - Tenet) -- this fucntionality is across the clients and not just for one client.
-- Remove the bit field for @HasETA, this is a varchar value
-- Modified by AmyLiu on 08/17/2020: for project IntranetModule status-substatus to show status and its substatus
-- Modified by Radhika Dereddy on 05/06/2021 FOr adjudication clients Display the CLEAR status when sectstat is in Veried or Verified/SeeAttached and APstatus is 'F' 
-- =============================================

CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetEmpl]
@apno int ,
@AdjudicationProcess bit = 0,
@clno int = 0
AS

 Declare @HasETA varchar(10)
 SET @HasETA = (Select ISNULL((Select Value from ClientConfiguration where CLNO = @clno AND ConfigurationKey = 'Report_&_Component_ETA_Display_In_Client_Access'), 'false'))

SELECT emplid,Employer, 
CASE WHEN sectstat.code in('0', '9', 'A','R') and LOWER(@HasETA) = 'true' THEN 
				CASE WHEN CAST(eta.ETADate AS DATE) < CAST(CURRENT_TIMESTAMP AS DATE) THEN 'ETA Unavailable' 
					 ELSE 'ETA: ' + LEFT(CONVERT(VARCHAR, eta.ETADate, 101), 10) 
				END 
		ELSE isnull((case when Isnull(@AdjudicationProcess,0) =1 then  ( Case WHEN A.Apstatus ='F' AND Empl.sectstat in ('4','5') THEN 'CLEAR' ELSE (
						(CASE when AdjStatusCustom.DisplayName is not null then AdjStatusCustom.DisplayName else isnull(AdjStatus.DisplayName,'In Progress') end) ) END )
			else sectstat.Description +'|'+ isnull(sss.SectSubStatus,'')  end),sectstat.Description +'|'+ isnull(sss.SectSubStatus,'') )			
		END  onlinedescription
FROM Empl (NOLOCK)
INNER JOIN APPL A(NOLOCK) on a.apno  = Empl.apno
LEFT OUTER JOIN SECTSTAT(NOLOCK) ON empl.sectstat = sectstat.code 
left join dbo.SectSubStatus sss (nolock) on empl.SectStat= sss.SectStatusCode and sss.ApplSectionID=1 and Empl.SectSubStatusID = sss.SectSubStatusID 
LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus(NOLOCK) ON empl.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID --and AdjStatus.CLNO = @clno
LEFT JOIN dbo.ClientAdjudicationStatusCustom AdjStatusCustom(NOLOCK) ON AdjStatusCustom.clno = a.clno and Empl.ClientAdjudicationStatus = AdjStatusCustom.ClientAdjudicationStatusID
LEFT JOIN dbo.ApplSectionsETA eta(NOLOCK) ON eta.Apno = A.APNO AND eta.SectionKeyID = Empl.EmplID AND eta.ApplSectionID = 1
where isonreport = 1 
and ishidden = 0 
and Empl.apno = @apno

SET ANSI_NULLS ON
