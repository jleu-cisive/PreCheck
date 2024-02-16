Create procedure [dbo].[VendorAccounts_GetSettingsById]
(@vendorId int = null)
  as
          
 if (@vendorId is not null)
  select 
  VendorAccountId,
  VendorAccountName,
  UserName,
  Password,
  ServiceType,
  LastUpdated,
  ConfigSettings,
  xsltFrom,
  xsltTo   
    from [dbo].[VendorAccounts] WITH (NOLOCK)
    where VendorAccountId = @vendorId
    and isactive = 1
  else
   select 
   VendorAccountId,
  VendorAccountName,
  UserName,
  Password,
  ServiceType,
  LastUpdated,
  ConfigSettings,
  xsltFrom,
  xsltTo   
    from [dbo].[VendorAccounts] WITH (NOLOCK)
  where isactive = 1  
         
SET ANSI_NULLS ON
