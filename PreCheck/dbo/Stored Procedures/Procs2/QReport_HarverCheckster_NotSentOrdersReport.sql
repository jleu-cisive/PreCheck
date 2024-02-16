
-- =============================================
-- Author:		<Arindam Mitra>
-- Requested by: Michelle Paz HDT:124404  
-- Create date: <01/29/2024>
-- Description: <Show orders which has not been sent>  
-- exec [dbo].[QReport_HarverChecksterClosedRefernces] 
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_HarverCheckster_NotSentOrdersReport]   
AS  
BEGIN  
  
 SET NOCOUNT ON;  
  select  distinct x.apno,x.appFirst ApplicantFirst, x.appLast applicantLast,x.appEmail as applicantEmail,x.appPhone applicantPhone, x.PersRefID,x.SectStat, x.SectSubStatusID, x.Web_Status,x.OrderId, x.DateOrdered, x.name, x.phone,x.Email,x.OperationType,
 x.CurrentOrderStatus,x.EmailCurrentStatus, x.EmailLastSentOn, x.EmailSentCount, x.SMSCurrentStatus, x.SMSLastSentOn, x.SMSSentCount, x.CreatedDate,x.response  
  from  
  (  
  select a.clno,a.first appFirst, a.last appLast, a.Email appEmail,a.phone appPhone, pr.APNO,pr.PersRefID,pr.OrderId, pr.DateOrdered,  
  pr.SectStat, pr.SectSubStatusID, pr.Web_Status,wss.description,pr.name, pr.phone, pr.email,pr.Pub_Notes,pr.Priv_Notes,  
  lg.OperationType , lg.CurrentOrderStatus,lgd.*  
  ,row_number() over (partition by lgd.Verification_VendorOrderLogID order by lgd.verification_vendorOrderLogDetailID  DESC) lgdrow      
  from dbo.Verification_VendorOrderLog lg  
  inner join PersRef pr on lg.OrderID=pr.OrderId  
  inner join appl a (nolock) on a.APNO=pr.APNO  
  inner join dbo.Websectstat wss on pr.web_status = wss.code  
  left join [dbo].[Verification_PersRefOrderLogDetail] lgd  on lgd.Verification_VendorOrderLogID = lg.Verification_VendorOrderLogID   
  where  lg.CreatedDate>='01/01/2024'  
  and   
  lg.OperationType='InProgress'  
  and lg.IsProcessed=0  
  and SectStat not in ('u','4')  
  
  )x   
  where x.lgdrow=1   
  and   
  (  
   (isnull(x.EmailSentCount,0)=0 and isnull(x.SMSSentCount,0)=0)   
   --(x.EmailCurrentStatus='Notsent' and x.SMSCurrentStatus='Notsent')  ---notSent List  
  )  
  order by x.apno, x.PersRefID, x.DateOrdered, x.CreatedDate  
END  