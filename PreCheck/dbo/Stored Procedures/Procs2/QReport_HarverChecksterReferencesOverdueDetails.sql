﻿
-- =============================================  
-- Author:  <Arindam Mitra>  
-- Requested by: Michelle Paz HDT:124404  
-- Create date: <01/29/2024>  
-- Description: The purpose of this report will be to identify overdue references. The parameters will be all open references.  
-- exec [dbo].[QReport_HarverChecksterReferencesOverdueDetails] 
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_HarverChecksterReferencesOverdueDetails]  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
  
 select a.APNO as ReportNumber, a.ApDate as [App Date], a.First +' '+ isnull(a.Middle, '') +' ' + a.Last as [Applicant Name],  
 a.clno as [Client#], c.name as [Client Name], ra.Affiliate as Affiliate, wss.description as [Webstatus], pr.web_updated  as [Webstatus updated],   
    pr.DateOrdered as [Assigned to module date],pr.name [ReferenceName], pr.Phone [RefrencePhone], pr.Email [ReferenceEmail], pr.OrderId [HarverChecksterRefID],pr.Priv_Notes, pr.Pub_Notes,  lg.IsProcessed, lg.ProcessedDate, lg.IsUsed, lg.Exception  
 from dbo.appl a (nolock)   
 inner join dbo.client c with (nolock) on a.CLNO = c.CLNO  
 left join dbo.refAffiliate ra with(nolock) on ra.AffiliateID = c.AffiliateID  
 inner join dbo.PersRef pr with(nolock) on a.APNO = pr.APNO   
 left join dbo.Websectstat wss with(nolock) on pr.Web_Status =cast(wss.code as int)  
 left join dbo.Verification_VendorOrderLog lg with (nolock) on lg.OrderID = pr.OrderId and OperationType='InProgress'  
 left join dbo.VendorAccounts va with (nolock) on lg.VendorID= va.VendorAccountId and va.VendorAccountName='HarverCheckster'  
 where   
 pr.SectStat='9'  
 and   
 a.apstatus in ('p','w')  
 and IsNull(pr.IsOnReport,0) = 1   
 and (isnull(pr.OrderId,'')<>'' or isnull(pr.DateOrdered,'')<>'')  
 AND pr.web_updated>'01/01/2024'     --- first date to use the HarverCheckster -- used it here to avoid table scan  
  
END  