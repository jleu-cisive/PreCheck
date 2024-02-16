-- =============================================
-- Create date: Radhika Dereddy on 12/11/2016
-- Request by Zach Daigle - Exclude the counties mentioned below
-- CNTY_NO 2480 - Sex Offender,
-- CNTY_NO 2738 - Federal Criminal,
-- CNTY_NO 2737 - Federal Civil,
-- CNTY_NO 3519 - National Criminal,
-- CNTY_NO 229 - Federal Bankruptcy
/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320
--exec [Client_Quarterly_Information] '08/01/2016','08/11/2016',0,'126:30'
*/
-- =============================================

--EXEC [Client_Quarterly_Information]  '11/01/2016', '11/30/2016',10555
CREATE  PROCEDURE [dbo].[Client_Quarterly_Information] 
@StartDate DateTime, 
@EndDate DateTime,
@CLNO int,
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221
as
BEGIN

--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END
--code added by vairavan for ticket id -67221 ends

 Select APNO  into #temp1 from APPL where apdate between @StartDate and DateAdd(d,1,@EndDate)
 
    Select distinct Apno, CNTY_NO into #temp2 from Crim (NOLOCK)  where Apno in (select Apno from #temp1) and ishidden = 0 

	select DATENAME(month, apdate)  [Month Ordered],a.clno as [Client ID],name as [Client Name],a.apno as [Report Number],a.Last as [Applicant Last Name],
	a.First as [Applicant First Name],a.SSN,a.DOB,isnull(crimcount,0) as[Criminal Searches],isnull(Emplcount,0) as [Employment Verifications],
	isnull(Educatcount,0) as [Education Verifications],isnull(Licensecount,0) as [License Verifications],isnull(Socialcount,0) as PID,
	isnull(MedicareCount,0) as SanctionCheck,isnull(MVRcount,0) as MVR,isnull(Creditcount,0) as [Credit Report],
	isnull(Referencecount,0) as [Personal References],isnull(Civilcount,0) as [Civil Searches],substring(Description,10,len(Description)) PackageDesc,PackageDesc SelectedPackage,
	[dbo].GetInvoiceDetailPerSection (a.apno,0,null) Package
	,[dbo].GetInvoiceDetailPerSection (a.apno,1,null) Fees
	,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crim') Crim_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crimpassthru') Crim_Service_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,3,null) Civil_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,4,'social') social_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,4,'credit') credit_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,5,null) MVR_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,6,null) Employment_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,7,null) Education_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,8,null) License_Charges
	,[dbo].GetInvoiceDetailPerSection (a.apno,9,null) Reference_Charges--,c.AffiliateID
	into #temp3
	from client c (NOLOCK) inner join appl a (NOLOCK) on c.clno=a.clno 
	left join (select apno,count(1) crimcount from #temp2 where CNTY_NO not in (2480,2738,2737,3519,229) group by apno) crim on a.apno = crim.apno
	left join (select apno,count(1) Emplcount from Empl (NOLOCK) where Empl.IsOnReport = 1 and empl.ishidden = 0 group by apno) Empl on a.apno = Empl.apno
	left join (select apno,count(1) Educatcount from Educat (NOLOCK) where Educat.IsOnReport = 1 and educat.ishidden = 0 group by apno) Educat on a.apno = Educat.apno
	left join (select apno,count(1) Licensecount from ProfLic (NOLOCK) where ProfLic.IsOnReport = 1 and proflic.ishidden = 0 group by apno) ProfLic on a.apno = ProfLic.apno
	left join (select apno,count(1) Socialcount from Credit (NOLOCK) where  Credit.reptype = 'S' group by apno) Social on a.apno = Social.apno
	left join (select apno,count(1) MVRcount from DL (NOLOCK) group by apno) DL on a.apno = DL.apno
	left join (select apno,count(1) MedicareCount from MedInteg (NOLOCK) group by apno) MedInteg on a.apno = MedInteg.apno
	left join (select apno,count(1) Creditcount from Credit (NOLOCK) where  reptype = 'C' group by apno) Credit on a.apno = Credit.apno
	left join (select apno,count(1) Referencecount from PersRef (NOLOCK) where PersRef.IsOnReport = 1 and persref.ishidden = 0 group by apno) PersRef on a.apno = PersRef.apno 
	left join (select apno,count(1) Civilcount from Civil (NOLOCK) group by apno) Civil on a.apno = Civil.apno 
	left join InvDetail Inv (NOLOCK) on Inv.APNO = a.APNO and type=0
	left join packagemain p (NOLOCK) on a.PackageID = P.PackageID
	where
	c.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO) and
	apdate between @StartDate and DateAdd(d,1,@EndDate) 
	and (@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
	

	--select * from #temp3

	select [Client Id], [Client Name],
	isnull(AVG(CASE WHEN [Criminal Searches] <> 0 then CONVERT(DECIMAL(16,2), [Criminal Searches]) else null end),0) as[Avg Criminal Searches],
	isnull(AVG(CASE WHEN [Employment Verifications] <> 0 then CONVERT(DECIMAL(16,2), [Employment Verifications]) else null end),0) as[Avg Employment Verifications],
	isnull(AVG(CASE WHEN [Education Verifications] <> 0 then CONVERT(DECIMAL(16,2), [Education Verifications]) else null end),0) as[Avg Education Verifications],
	isnull(AVG(CASE WHEN [License Verifications] <> 0 then CONVERT(DECIMAL(16,2), [License Verifications]) else null end),0) as[Avg License Verifications],
	isnull(AVG(CASE WHEN PID <> 0 then CONVERT(DECIMAL(16,2), PID) else null end),0) as[Avg PID],
	isnull(AVG(CASE WHEN SanctionCheck <> 0 then CONVERT(DECIMAL(16,2), SanctionCheck) else null end),0) as[Avg SanctionCheck],	
	isnull(AVG(CASE WHEN MVR <> 0 then CONVERT(DECIMAL(16,2), MVR) else null end),0) as[Avg MVR],
	isnull(AVG(CASE WHEN [Credit Report] <> 0 then CONVERT(DECIMAL(16,2), [Credit Report]) else null end),0) as[Avg CreditReport],
	isnull(AVG(CASE WHEN [Personal References] <> 0 then CONVERT(DECIMAL(16,2), [Personal References]) else null end),0) as[Avg Personal Reference],
	isnull(AVG(CASE WHEN [Civil Searches] <> 0 then CONVERT(DECIMAL(16,2), [Civil Searches]) else null end),0) as[Avg Civil Searches],
	Count([Report Number]) AppCount,
	Sum(Package) [Total Package],
	sum(Fees) [Total Fees],
	sum(Crim_Charges) [TotalCrim_Charges],
	sum(Crim_Service_Charges) [Total Crim_Service_Charges],
	sum(Civil_Charges) [Total Civil_Charges],
	sum(social_Charges) [Total social_Charges],
	sum(credit_Charges) [Total credit_Charges],
	sum(MVR_Charges) [Total MVR_Charges],
	sum(Employment_Charges) [Total Employment_Charges],
	sum(Education_Charges) [Total Education_Charges],
	sum(License_Charges) [Total License_Charges],
	sum(Reference_Charges) [Total Reference_Charges]--,max(AffiliateID) as AffiliateID
	into #temp4 from #temp3
	group by [Client ID], [Client Name]


	
	select [Client Id], [Client Name], 
	CAST([Avg Criminal Searches] as Decimal(12,2)) [Avg Criminal Searches], 
	CAST([Avg Employment Verifications] as Decimal(12,2)) [Avg Employment Verifications],
	CAST([Avg Education Verifications] as Decimal(12,2)) [Avg Education Verifications],
	CAST([Avg License Verifications] as Decimal(12,2)) [Avg License Verifications],
	CAST([Avg PID] as Decimal(12,2)) [Avg PID],
	CAST([Avg SanctionCheck] as Decimal(12,2)) [Avg SanctionCheck],
	CAST([Avg MVR] as Decimal(12,2)) [Avg MVR],
	CAST([Avg CreditReport] as Decimal(12,2)) [Avg CreditReport],
	CAST([Avg Personal Reference] as Decimal(12,2)) [Avg Personal Reference],
	CAST([Avg Civil Searches] as Decimal(12,2)) [Avg Civil Searches],
	AppCount,
	CAST([Total Package] as Decimal(12,2)) [Total Package],
	CAST([Total Fees] as Decimal(12,2)) [Total Fees],
	[TotalCrim_Charges],
	[Total Crim_Service_Charges],
	[Total Civil_Charges],
	[Total social_Charges],
	[Total credit_Charges],
	[Total MVR_Charges],
	[Total Employment_Charges],
	[Total Education_Charges],
	[Total License_Charges],
	[Total Reference_Charges]--,AffiliateID
	from #temp4 


drop table #temp1
drop table #temp2
drop table #temp3
drop table #temp4


END

