
/***************************************************************************
* Procedure Name: [dbo].[Verification_VendorLogGetStatus_PersRefs] 
* Created By: Amy Liu
* Created On: 11/20/2020
exec [dbo].[Verification_VendorLogGetStatus_PersRefs] 'ARefChex', 'InProgress'
*****************************************************************************/


CREATE PROCEDURE [dbo].[Verification_VendorLogGetStatus_PersRefs]
(
@vendor varchar(30),
@operationType varchar(50) 
)
AS
BEGIN
	SET NOCOUNT ON;  
	SET FMTONLY OFF
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		  -- select distinct pr.SectStat, vvolg.OrderID
	  ---below remove all these manually completed order but it is still under inProgress.
	 -- update vvolg set vvolg.IsProcessed=1
	 --FROM [dbo].[Verification_VendorOrderLog] vvolg
	 --inner join dbo.PersRef pr on vvolg.OrderID=pr.OrderId
	 --inner join dbo.VendorAccounts va on vvolg.VendorID = va.VendorAccountId
	 --  where vvolg.IsProcessed=0 and vvolg.OperationType='InProgress'  
	 --  and (pr.SectStat<>'9' or (pr.SectStat='9' and pr.Web_Status not in (99,0,44)))

	 		--  select vvolg.*
	 	  update vvolg set vvolg.IsProcessed=1        ---don't allow process verified and unverified orders --amyliu on 04/12/2021
	 FROM [dbo].[Verification_VendorOrderLog] vvolg
	 inner join dbo.PersRef pr on vvolg.OrderID=pr.OrderId
	 inner join dbo.VendorAccounts va on vvolg.VendorID = va.VendorAccountId
	   where vvolg.IsProcessed=0 and vvolg.OperationType='InProgress'  
	   and (pr.SectStat in ('U', '4') or (pr.SectStat='9' and pr.Pub_Notes like '%question%'))

	   ---reset all failed orders which have isused=1 or have exception in a hour to rerun regardless
	   			update lg set lg.IsUsed=0, lg.Exception=''
			from dbo.Verification_VendorOrderLog lg (nolock)
			inner join dbo.PersRef pr with (nolock) on lg.OrderID = pr.OrderId
		--	inner join dbo.appl a with (nolock) on pr.APNO = a.APNO
			--left join dbo.Verification_PersRefOrderLogDetail lgd on lg.Verification_VendorOrderLogID= lgd.Verification_VendorOrderLogID
			where pr.DateOrdered>='02/25/2021'  and isprocessed =0 and  IsUsed=1
			--	and pr.SectStat='9' and pr.Web_Status in ( 99, 44, 0)
			--and pr.PersRefID<>2822060
	

		DROP TABLE IF EXISTS #tmpOrders

		CREATE TABLE #tmpOrders(OrderID varchar(50)	)

	CREATE CLUSTERED INDEX IX_tmpOrders_01 ON #tmpOrders(OrderID);
	--declare @vendor varchar(30)='ARefChex',
	--		@operationType varchar(50)= 'InProgress' 
	
		insert into #tmpOrders	       
   --select vvolg.Verification_VendorOrderLogID 
   select distinct vvolg.OrderID
	 FROM [dbo].[Verification_VendorOrderLog] vvolg
	-- inner join dbo.PersRef pr on vvolg.OrderID=pr.OrderId
	 inner join dbo.VendorAccounts va on vvolg.VendorID = va.VendorAccountId
	   where vvolg.OperationType=@operationType and vvolg.IsUsed=0 and vvolg.IsProcessed=0 and va.VendorAccountName=@vendor  --'ARefChex'
--	   and pr.PersRefID in (2611259,
--2612579,
--2612580)

	-- select * from #tmpOrders t
	update vvolg set vvolg.IsUsed=1, vvolg.Exception=''
	from [dbo].[Verification_VendorOrderLog] vvolg
	inner join #tmpOrders t on vvolg.OrderID = t.OrderID

	select vvolgRows. [Verification_VendorOrderLogID]
      ,vvolgRows.[Integration_VendorOrderID]
      ,vvolgRows.[OperationType]
      ,vvolgRows.[VendorID]
      ,vvolgRows.[OrderID] 
      ,vvolgRows.[IsProcessed]
      ,vvolgRows.[ProcessedDate]
      ,vvolgRows.[CurrentOrderType]
      ,vvolgRows.[CurrentOrderStatus]
      ,vvolgRows.[SentCount]
      ,vvolgRows.[CurrentUpdateDate]
      ,vvolgRows.[Error]
      ,vvolgRows.[Exception]
      ,vvolgRows.[IsUsed]
      ,vvolgRows.[CreatedBy]
      ,vvolgRows.[CreatedDate]
	from 
	(
	select vvolg.*, ROW_NUMBER() over (partition by vvolg.OrderID order by vvolg.verification_VendorOrderLogID desc) rn
	from [dbo].[Verification_VendorOrderLog] vvolg
	inner join #tmpOrders t on vvolg.OrderID = t.OrderID
	)vvolgRows  where vvolgRows.rn=1
	order by vvolgRows.ProcessedDate asc

	Drop table #tmpOrders

END
