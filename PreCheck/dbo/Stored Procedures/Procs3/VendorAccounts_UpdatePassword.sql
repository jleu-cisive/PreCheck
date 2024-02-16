/****** Object:  StoredProcedure [dbo].[VendorAccounts_UpdatePassword]    Script Date: 03/26/2012 10:12:51 ******/
CREATE procedure [dbo].[VendorAccounts_UpdatePassword]
(@password varchar(30),
 @vendorName varchar(30)
 )
as
update VendorAccounts 
set Password = @password
where lower(VendorAccountName) = lower(@vendorName)