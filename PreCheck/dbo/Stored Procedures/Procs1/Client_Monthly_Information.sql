

--EXEC Precheck.[dbo].[Client_Monthly_Information] 10760,'08/10/2011','09/15/2014'

-- =============================================
-- Author:		<None>
-- Create date: <09/15/2014>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Client_Monthly_Information]
	@CLNO int,
	@StartDate DateTime,
	@EndDate DateTime	
	
AS
BEGIN
	select DATENAME(month, apdate) as [Month Ordered],a.clno as [Client ID],name as [Client Name] ,a.apno as [Report Number],a.Last as [Applicant Last Name],a.First as [Applicant First  Name],a.SSN,a.DOB, isnull(crimcount,0) as [Criminal Searches],isnull(Emplcount,0) as [Employment Verifications],
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
	,[dbo].GetInvoiceDetailPerSection (a.apno,9,null) Reference_Charges
	,acd.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID
	,acd.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as PositionID
	,acd.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode
	from client c (NOLOCK) 
	inner join appl a (NOLOCK) on c.clno=a.clno 
	inner join applClientData acd (NOLOCK) on c.clno = acd.clno and a.apno = acd.apno
	left join (select apno,count(1) crimcount from crim (NOLOCK) where ishidden = 0 group by apno) crim on a.apno = crim.apno
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
	where c.clno = @CLNO and apdate between @StartDate and @EndDate
	--where c.clno in (--3041--) and apdate between --'01/01/06'-- and DateAdd(d,1,--'12/31/06'--)
	order by month(apdate)

END