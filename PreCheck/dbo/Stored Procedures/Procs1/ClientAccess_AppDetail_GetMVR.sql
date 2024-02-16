-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Gets Motor Vehicle Report Details for the client in Check Reports
-- EXEC [dbo].[ClientAccess_AppDetail_GetMVR] 3993277, 0, 12771
-- Modified By : Radhika Dereddy on 12/20/2018
-- Modified reason: When ETA project went Live the Adjudication Process was impacted(broken), so now making the changes to the Stored procedure to accommodate the functionality of the
-- Adjudication clients, Non adjudicatio clients and the ETA (Estimated Time Aggregate)process so all the statuses are displayed as intended.
-- Remove the functionality specific to AffiliateID 10 (which is 12444 - Tenet) -- this fucntionality is across the clients and not just for one client.
-- Remove the bit field for @HasETA, this is a varchar value
-- Modified by Radhika Dereddy on 05/06/2021 FOr adjudication clients Display the CLEAR status when sectstat is in Veried or Verified/SeeAttached and APstatus is 'F' 
-- =============================================

CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetMVR] 
@apno int ,
@AdjudicationProcess bit = 0,
@clno int = 0 
AS


 Declare @HasETA varchar(10)
 SET @HasETA = (Select ISNULL((Select Value from ClientConfiguration where CLNO = @clno AND ConfigurationKey = 'Report_&_Component_ETA_Display_In_Client_Access'), 'false'))


Select  DL.apno,
	CASE WHEN sectstat.code in('0', '9', 'A') and LOWER(@HasETA) = 'true' THEN  
		CASE WHEN CAST(eta.ETADate AS DATE) < CAST(CURRENT_TIMESTAMP AS DATE) THEN 'ETA Unavailable' 
			 ELSE 'ETA: ' + LEFT(CONVERT(VARCHAR, eta.ETADate, 101), 10) 
		END 
		ELSE isnull((case when Isnull(@AdjudicationProcess,0) =1 then  ( Case WHEN A.Apstatus ='F' AND DL.sectstat in ('4','5') THEN 'CLEAR' ELSE (
		(CASE when AdjStatusCustom.DisplayName is not null then AdjStatusCustom.DisplayName else isnull(AdjStatus.DisplayName,'In Progress') end) ) END )
		else sectstat.onlinedescription end),sectstat.onlinedescription)
	END onlinedescription
FROM DL 
INNER JOIN APPL A on a.apno  = DL.apno
LEFT OUTER JOIN SECTSTAT ON DL.sectstat = sectstat.code 
LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON DL.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID --and AdjStatus.CLNO = @clno
LEFT JOIN dbo.ClientAdjudicationStatusCustom AdjStatusCustom ON AdjStatusCustom.clno = a.clno and DL.ClientAdjudicationStatus = AdjStatusCustom.ClientAdjudicationStatusID
LEFT JOIN dbo.ApplSectionsETA eta ON eta.Apno = DL.APNO AND eta.ApplSectionID = 6
where DL.apno = @apno and ishidden=0

SET ANSI_NULLS ON
