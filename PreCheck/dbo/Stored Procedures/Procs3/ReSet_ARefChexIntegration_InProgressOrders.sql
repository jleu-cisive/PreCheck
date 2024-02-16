-- =============================================
-- Author:		<Amy Liu>
-- Create date: <02/25/2021>
-- Description:	<This stored procedure is used to remove IsUsed =1 when the Order InProgress is failed to getstatus>
-- =============================================
CREATE PROCEDURE [dbo].[ReSet_ARefChexIntegration_InProgressOrders]
AS
BEGIN
			update lg set lg.IsUsed=0, lg.Exception=''
			from dbo.Verification_VendorOrderLog lg (nolock)
			inner join dbo.PersRef pr with (nolock) on lg.OrderID = pr.OrderId
			inner join dbo.appl a with (nolock) on pr.APNO = a.APNO
			--left join dbo.Verification_PersRefOrderLogDetail lgd on lg.Verification_VendorOrderLogID= lgd.Verification_VendorOrderLogID
			where pr.DateOrdered>='02/25/2021'  and isprocessed =0 and  IsUsed=1
				and pr.SectStat='9' and pr.Web_Status= 99
				--and isnull(Exception,'')<>''
END

/*
 select distinct pr.apno, pr.persrefid,pr.SectStat, pr.SectSubStatusID, pr.Web_Status, pr.Priv_Notes, pr.Pub_Notes, 
 lg.OrderID, lg.IsProcessed, lg.IsUsed, lg.ProcessedDate, lg.Exception
			from dbo.Verification_VendorOrderLog lg (nolock)
			inner join dbo.PersRef pr with (nolock) on lg.OrderID = pr.OrderId
			inner join dbo.appl a with (nolock) on pr.APNO = a.APNO
			--left join dbo.Verification_PersRefOrderLogDetail lgd on lg.Verification_VendorOrderLogID= lgd.Verification_VendorOrderLogID
			where pr.DateOrdered>='02/25/2021'  and isprocessed =0  --and  IsUsed=1
			and pr.SectStat='9' and pr.Web_Status= 99

			*/