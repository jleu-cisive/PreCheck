-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-21-2008
-- Description:	 Gets Personal Reference Details for the client in Check Reports
-- Modified By : Radhika Dereddy on 12/20/2018
-- Remove the functionality specific to AffiliateID 10 (which is 12444 - Tenet) -- this fucntionality is across the clients and not just for one client.
-- Modified by AmyLiu on 08/17/2020: for project IntranetModule status-substatus to show status and its substatus
-- Modified by Radhika Dereddy on 05/06/2021 FOr adjudication clients Display the CLEAR status when sectstat is in Veried or Verified/SeeAttached and APstatus is 'F'
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetPersRef]
@apno int ,
@AdjudicationProcess bit = 0,
@clno int = 0 
AS


Select persrefid,name, SectStat,
isnull((case when Isnull(@AdjudicationProcess,0) =1 then ( Case WHEN A.Apstatus ='F' AND persref.sectstat in ('4','5') THEN 'CLEAR' ELSE (
						(CASE when AdjStatusCustom.DisplayName is not null 
								then AdjStatusCustom.DisplayName else isnull(AdjStatus.DisplayName,'In Progress') end) ) END )
					else sectstat.Description +'|'+ isnull(sss.SectSubStatus,'')  end),sectstat.Description +'|'+ isnull(sss.SectSubStatus,'') )
		as onlinedescription
FROM persref 
INNER JOIN APPL A on a.apno  = persref.apno
LEFT OUTER JOIN SECTSTAT ON persref.sectstat = sectstat.code 
left join dbo.SectSubStatus sss (nolock) on persref.SectStat= sss.SectStatusCode and sss.ApplSectionID=3 and persref.SectSubStatusID = sss.SectSubStatusID
LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON persref.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID --and AdjStatus.CLNO = @clno
LEFT JOIN dbo.ClientAdjudicationStatusCustom AdjStatusCustom ON AdjStatusCustom.clno = a.clno and persref.ClientAdjudicationStatus = AdjStatusCustom.ClientAdjudicationStatusID
where isonreport = 1 
and ishidden = 0
and persref.apno =  @apno


SET ANSI_NULLS ON
