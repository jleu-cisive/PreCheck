
-- =============================================
-- Author:		Vidya
-- Create date: <Create Date,,20 Dec 2022>
-- Description:	<Description,,to get Client Package Lead Count Info>
-- =============================================

Create PROCEDURE [dbo].[ClientPackageLeadCountInfo] 


 @CLNO int,
@AffiliateID int,
@AccountingSystemGrouping varchar(200)
AS

BEGIN

		select distinct c.Name as 'Client Name',c.CLNO,r.Affiliate,c.[Accounting System Grouping] as 'ASG',M.PackageDesc as 'Package Name',p.PackageID 'Client Package ID',CASE
    WHEN rs.ServiceType=0 THEN 'CRIM'
    WHEN rs.ServiceType=1 THEN 'CIV'
    WHEN rs.ServiceType=2 THEN 'CRED'
	WHEN rs.ServiceType=3 THEN 'DL'
	WHEN rs.ServiceType=4 THEN 'EMP'
	WHEN rs.ServiceType=5 THEN 'EDUC'
	WHEN rs.ServiceType=6 THEN 'PROF'
	WHEN rs.ServiceType=7 THEN 'PERS'
	WHEN rs.ServiceType=8 THEN 'SOC'
	WHEN rs.ServiceType=9 THEN 'NPDP'
    ELSE rs.Description 
END as 'RateType',
P.Rate as 'Client Package Price',ps.IncludedCount,ps.MaxCount  from client c
inner join dbo.refAffiliate  r on c.AffiliateID=r.AffiliateID
INNER JOIN dbo.ClientPackages AS P (NOLOCK) ON P.CLNO = C.CLNO  
INNER JOIN dbo.PackageMain AS M (NOLOCK) ON M.PackageID = P.PackageID 
--Inner join ClientRates as cr (nolock) on c.CLNO=cr.CLNO
inner join PackageService as ps (nolock) on  P.PackageID=ps.PackageID
inner join refServiceType as rs (nolock) on ps.ServiceType=rs.ServiceType
where (@CLNO=0 or c.CLNO=@CLNO or @CLNO is null)
		and (@AffiliateID=0 or c.AffiliateID=@AffiliateID or @AffiliateID is null) 
		and (@AccountingSystemGrouping='' or c.[Accounting System Grouping]=@AccountingSystemGrouping or @AccountingSystemGrouping is null)


END
