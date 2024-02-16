-- dbo.PRI_ShowErrorsByVendor @dateFrom = '10/30/2017',@dateTo = '11/01/2017',@vendorName = 'Wholesale'
CREATE procedure dbo.PRI_ShowErrorsByVendor
(

@vendorOperation varchar(100) = null,
@vendorName varchar(100) = null,
@datefrom varchar(10) = null,
@dateTo varchar(10) = null
) 
as
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
select 
	Request,
	Response,
	Request.value('(//Apno)[1]','int') as Apno,
	Request.value('(//SectionID)[1]','int') as CrimID,
	Response.value('(//ErrorDescription)[1]','varchar(max)') as ErrorMessage,
	VendorName,
	VendorOperation,
	CreatedDate 
from 
	dbo.Integration_VendorOrder 
where  
	vendorOperation = COALESCE(@VendorOperation,VendorOperation) and 
	(CreatedDate > @datefrom and CreatedDate <= @dateTo) and 
	vendorName = COALESCE(@vendorName,VendorName)  and
	Response.value('(//HasError)[1]','bit') = '1' 
	
order by 
	CreatedDate desc,VendorName,VendorOperation asc
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
