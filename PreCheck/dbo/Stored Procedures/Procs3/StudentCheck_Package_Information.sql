  
/*===============================================================================================  
Procedure Name : [dbo].[StudentCheck_Package_Information]  
Requested By: Ryan Ryan Trevino  
Developer: Deepak Vodethela  
Execution : EXEC [dbo].[StudentCheck_Package_Information]
Modified By: Schapyala On 10/06/2017
Modification: Added 2 params to be able to filter by client or show all packages 
Modified By: Prasanna On 06/03/2021  --HDT#7547 Modify Existing Report - "Client Package Information"
Modified by Sahithi:06/09/2021 -HDT8197 , Add new param for affiliate
Modified by Aashima on 30/08/2022 -- HDT#61807, added new column [Accounting System Grouping]
====================================================================================================*/  
  
CREATE PROCEDURE [dbo].[StudentCheck_Package_Information] (@CLNO Int = 0,@ShowActiveOnly bit = 1,@affiliate varchar(30)=null) 
AS  
  --declare @clno int=0
  --declare @ShowActiveOnly bit =1
  --declare @affiliate varchar(30) =null 
SELECT P.ClientPackagesID,M.PackageID,refPackageTypeID,C.CLNO,Name,DescriptiveName as ClientName, T.ClientType, P.ClientPackageDesc ,M.PackageDesc, P.Rate ClientRate,M.DefaultPrice,
LastInvDate,P.IsActive [Active-Package],(~IsInactive) [Active-Client], c.AffiliateID,r.Affiliate, C.[Accounting System Grouping] as [Accounting System Grouping]
FROM dbo.Client AS C (NOLOCK)  
inner join dbo.refAffiliate  r on c.AffiliateID=r.AffiliateID
INNER JOIN dbo.refClientType AS T(NOLOCK) ON T.ClientTypeID = C.ClientTypeID  
INNER JOIN dbo.ClientPackages AS P (NOLOCK) ON P.CLNO = C.CLNO  
INNER JOIN dbo.PackageMain AS M (NOLOCK) ON M.PackageID = P.PackageID  
WHERE C.ClientTypeID IN (select clientTypeID from refClientType) --(6,7,8,9,11,12,13 )  
--and IsInactive = 0  
and (@CLNO =0 or P.CLNO = @CLNO)
and (@affiliate is null  or r.Affiliate=@affiliate)
and P.IsActive = case when @ShowActiveOnly = 1 then 1 else P.IsActive end
and LastInvDate > '1/1/2014'  
ORDER BY C.CLNO,ClientPackagesID  
  