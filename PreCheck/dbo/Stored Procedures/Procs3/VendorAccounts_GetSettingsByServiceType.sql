CREATE procedure [dbo].[VendorAccounts_GetSettingsByServiceType](
  @serviceType varchar(50))
  as
  select IsNull(VendorAccountName,'') as VendorAccountName,UserName,Password,ServiceType,LastUpdated,ConfigSettings
  from [dbo].[VendorAccounts]
    where lower(@serviceType) = lower(ServiceType) and IsActive = 1
 
   
SET ANSI_NULLS ON
