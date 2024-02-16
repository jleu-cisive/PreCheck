create procedure dbo.sp_Find_PublicRecords_Integration_Order
(@vendorid int, --11:SJV, 7:Baxter,10:Wholesale,12:Innovative
@vendoroperation varchar(100), -- either SubmitOrder,InProgress, or Completed
@datefrom datetime,
@dateto datetime,
@crimid int)
--dbo.sp_Find_Integration_PublicRecords_Order 11,'SubmitOrder','09/04/2019 11:50','09/04/2019 12:05',32294139
as 
BEGIN
	
	select 
		ivo.* 
	from 
		dbo.Integration_VendorOrder ivo inner join dbo.VendorAccounts va 
		on ivo.VendorName = va.VendorAccountName
	where 
		va.VendorAccountId = @vendorid and 
		va.IsActive=1 and
		VendorOperation=@vendoroperation and --'SubmitOrder'
		Request.value('(//SectionID)[1]','int') = @crimid and 
		CreatedDate > @datefrom and CreatedDate < @dateto --'09/04/2019 12:05'
		--Request.value('(//SectionID)[1]','int') = 32294139 and CreatedDate > '09/04/2019 11:50' and CreatedDate < '09/04/2019 12:05'			
 order by ivo.Integration_VendorOrderId desc

END