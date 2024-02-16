



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- Modified By: Radhika Dereddy on 08/11/2016
-- =============================================

--EXEC [Client_Monthly_Info] '2135:2167', '08/01/2016', '08/11/2016'
CREATE  PROCEDURE [dbo].[Client_Monthly_Info] 
@CLNO VARCHAR(MAX) = NULL,
--@CLNO int,
@StartDate DateTime = '01/12/2012', 
@EndDate DateTime = '01/12/2012'

as
BEGIN

if(@CLNO = '' OR LOWER(@CLNO) = 'null') Begin  SET @CLNO = NULL  END

	 Select APNO  into #temp1 from APPL where 
	 --clno = @clno  --commented by Radhika
	 (@clno IS NULL OR clno IN (SELECT * from [dbo].[Split](':',@clno))) and apdate between @StartDate and DateAdd(d,1,@EndDate)
 
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
	,[dbo].GetInvoiceDetailPerSection (a.apno,9,null) Reference_Charges
	into #temp3
	from client c (NOLOCK) inner join appl a (NOLOCK) on c.clno=a.clno 
	left join (select apno,count(1) crimcount from #temp2 group by apno) crim on a.apno = crim.apno
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
	-- c.clno = @CLNO --commented by Radhika
	 (@clno IS NULL OR c.clno IN (SELECT * from [dbo].[Split](':',@clno)))
	 and apdate between @StartDate and DateAdd(d,1,@EndDate) --(--3041--) and apdate between --'01/01/06'-- and DateAdd(d,1,--'12/31/06'--)
	order by month(apdate)

	select * from #temp3
	union all
	select 'Total' as [Month Order], '' as [Client ID], '' as [Client Name], '' as [Report Number], '' as [Applicant Last Name], '' as [Applicant First Name], '' as SSN, '' as DOB,
	SUM([Criminal Searches]) as [Criminal Searches], 
	SUM([Employment Verifications]) as [Employment Verifications], SUM([Education Verifications]) as [Education Verifications], 
	SUM([License Verifications]) as [License Verifications], SUM([PID]) as [PID], SUM([SanctionCheck]) as [SanctionCheck], 
	SUM([MVR]) as [MVR], SUM([Credit Report]) as [Credit Report], SUM([Personal References]) as [Personal References], 
	SUM([Civil Searches]) as [Civil Searches], '' as [PackageDesc], '' as [SelectedPackage], 0 as [Package], SUM(Fees) as Fees,
	SUM(Crim_Charges) as Crim_Charges, SUM(Crim_Service_Charges) as Crim_Service_Charges, SUM(Civil_Charges) as Civil_Charges,
	SUM(social_Charges) as social_Charges, SUM(credit_Charges) as credit_Charges, SUM(MVR_Charges) as MVR_Charges, SUM(Employment_Charges) as Employment_Charges,
	SUM(Education_Charges) as Education_Charges, SUM(License_Charges) as License_Charges, SUM(Reference_Charges) as Reference_Charges
	 from #temp3
drop table #temp1
drop table #temp2
drop table #temp3

END
