CREATE procedure [dbo].[VendorAccounts_GetSettingsByName](
  @vendorName varchar(30))
  as
  select IsNull(VendorAccountName,'') as VendorAccountName,UserName,Password,ServiceType,LastUpdated,ConfigSettings
  from [dbo].[VendorAccounts]
    where lower(@vendorName) = lower(VendorAccountName) 
    
    
    /****** Object:  StoredProcedure [dbo].[VendorAccounts_GetSettingsByName]    Script Date: 03/26/2012 10:12:51 ******/
SET ANSI_NULLS ON
