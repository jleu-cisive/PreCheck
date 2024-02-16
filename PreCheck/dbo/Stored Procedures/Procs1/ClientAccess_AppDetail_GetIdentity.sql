
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Gets Identity(Social/Credit report) Verification Details for the client in Check Reports
--schapyala added Ishidden = 0 below to suppress unused items from showing - 05/18/2015
-- Remove the functionality specific to AffiliateID 10 (which is 12444 - Tenet) -- this fucntionality is across the clients and not just for one client.
-- Modified by Radhika Dereddy on 05/06/2021 FOr adjudication clients Display the CLEAR status when sectstat is in Veried or Verified/SeeAttached and APstatus is 'F' 
-- EXEC [dbo].[ClientAccess_AppDetail_GetIdentity]  5723818, 1, 12771
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetIdentity]
@apno int ,
@AdjudicationProcess bit = 0,
@clno int = 0 
AS

Select credit.apno, credit.RepType,sectstat.code,
isnull((case when Isnull(@AdjudicationProcess,0) =1 then  ( Case WHEN A.Apstatus ='F' AND credit.sectstat in ('4','5') THEN 'CLEAR' ELSE (
(CASE when AdjStatusCustom.DisplayName is not null then AdjStatusCustom.DisplayName else isnull(AdjStatus.DisplayName,'In Progress') end) )END )
else sectstat.onlinedescription end),sectstat.onlinedescription) as onlinedescription
FROM credit 
INNER JOIN APPL A on a.apno  = credit.apno
LEFT OUTER JOIN SECTSTAT ON credit.sectstat = sectstat.code 
LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON credit.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID --and AdjStatus.CLNO = @clno
LEFT JOIN dbo.ClientAdjudicationStatusCustom AdjStatusCustom ON AdjStatusCustom.clno = a.clno and credit.ClientAdjudicationStatus = AdjStatusCustom.ClientAdjudicationStatusID
where credit.apno = @apno and ishidden=0

SET ANSI_NULLS ON
