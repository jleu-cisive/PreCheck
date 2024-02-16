

CREATE Proc [dbo].[ClientMonthlyInformation_Distinct_Crims]
@clno int = 8424,
@StartDate datetime = '12/01/2013',
@EndDate Datetime = '01/01/2014'

As

select DATENAME(month, apdate)  Apmonth,a.clno,name ,a.apno,a.Last,a.First,a.SSN,a.DOB, isnull(crimcount,0) crimcount,isnull(Emplcount,0) Emplcount,
isnull(Educatcount,0) Educatcount,isnull(Licensecount,0) Licensecount,isnull(Socialcount,0) Socialcount,
isnull(MedicareCount,0) MedicareCount,isnull(MVRcount,0) MVRcount,isnull(Creditcount,0) Creditcount,
isnull(Referencecount,0) Referencecount,isnull(Civilcount,0) Civilcount,substring(Description,10,len(Description)) PackageDesc,PackageDesc SelectedPackage,
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
from client c (NOLOCK) inner join appl a (NOLOCK) on c.clno=a.clno 
left join (SELECT 	distinct apno, SUM(iif(COUNT(1)>1,1,1)) over(Partition By Apno) as crimcount from crim where ishidden = 0 and CNTY_NO <> 2480 
GROUP BY apno,county) crim on a.apno = crim.apno
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
where c.clno = @clno and apdate between @StartDate and DateAdd(d,1, @EndDate)
order by month(apdate)