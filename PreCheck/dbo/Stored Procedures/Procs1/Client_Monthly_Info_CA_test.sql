  
  
  
  
  
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date, ,>  
-- Description: <Description, ,>  
-- Modified By: Radhika Dereddy on 08/11/2016  
-- =============================================  
  
--EXEC [Client_Monthly_Info] '2135:2167', '08/01/2016', '08/11/2016'  
CREATE  PROCEDURE [dbo].[Client_Monthly_Info_CA_test]   
  @CLNO VARCHAR(MAX) = NULL,  
--@CLNO int,  
  --@affiliateId int,  --code commented by Mainak for ticket id -55501
  @AffiliateIDs varchar(MAX) = '0',--code added by Mainak for ticket id -55501
  @StartDate DateTime = '01/12/2012',   
  @EndDate DateTime = '01/12/2012'  
  
as  
BEGIN  
  
if(@CLNO = '' OR LOWER(@CLNO) = 'null') Begin  SET @CLNO = NULL  END  

	--code added by Mainak for ticket id -55501 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by Mainak for ticket id -55501 ends
  
  Select APNO  into #temp1   
  from APPL a  
   INNER JOIN client c WITH (nolock)  ON c.clno = a.clno  
  where   
  --clno = @clno  --commented by Radhika  
  (@clno IS NULL OR a.clno IN (SELECT * from [dbo].[Split](':',@clno))) and apdate between @StartDate and DateAdd(d,1,@EndDate)  
  --  and c.AffiliateID = IIF(@affiliateId=0,c.affiliateId, @affiliateId) --code commented by Mainak for ticket id -55501
  AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Mainak for ticket id -55501
	
   
    Select distinct Apno, CNTY_NO into #temp2 from Crim (NOLOCK)  where Apno in (select Apno from #temp1) and ishidden = 0   
  
  
 select DATENAME(month, apdate)  [Month Ordered]  
 ,a.clno as [Client ID]  
 ,name as [Client Name]  
 ,a.apno as [Report Number]  
 ,a.Last as [Applicant Last Name]  
 ,a.First as [Applicant First Name]  
 ,a.SSN  
 ,FORMAT(a.DOB, 'MM/dd/yyyy') AS 'DOB'  
 ,a.ApStatus as [Report Status]  
 ,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Report Create Date'  
    ,FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Closed Date'  
    ,FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'  
    ,FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'  
 ,isnull(crimcount,0) as[Criminal Searches]  
 ,isnull(Emplcount,0) as [Employment Verifications]  
 ,isnull(Educatcount,0) as [Education Verifications]  
 ,isnull(Licensecount,0) as [License Verifications]  
 ,isnull(Socialcount,0) as PID  
 ,isnull(MedicareCount,0) as [Sanction Check]  
 ,isnull(MVRcount,0) as MVR  
 ,isnull(Creditcount,0) as [Credit Report]  
 ,isnull(Referencecount,0) as [Personal References]  
 ,isnull(Civilcount,0) as [Civil Searches]  
 ,substring(Description,10,len(Description)) [Package Desc],PackageDesc [Selected Package]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,0,null) Package  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,1,null) Fees  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crim') [Crim Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crimpassthru') [Crim Service Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,3,null) [Civil Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,4,'social') [Social Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,4,'credit') [Credit Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,5,null) [MVR Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,6,null) [Employment Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,7,null) [Education Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,8,null) [License Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,9,null) [Reference Charges]  
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
 -- and c.AffiliateID = IIF(@affiliateId=0,c.affiliateId, @affiliateId) --code commented by Mainak for ticket id -55501
  AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Mainak for ticket id -55501  
 order by month(apdate)  
  
 select * from #temp3  
 union all  
 select 'Total' as [Month Order], '' as [Client ID], '' as [Client Name], '' as [Report Number], '' as [Applicant Last Name], '' as [Applicant First Name], '' as SSN, '' as DOB,  
 '' as [Report Status],  
 '' AS 'Report Create Date',  
    '' AS 'Original Closed Date',  
    '' AS 'Reopen Date',  
    '' AS 'Complete Date',  
 SUM([Criminal Searches]) as [Criminal Searches],   
 SUM([Employment Verifications]) as [Employment Verifications], SUM([Education Verifications]) as [Education Verifications],   
 SUM([License Verifications]) as [License Verifications], SUM([PID]) as [PID], SUM([Sanction Check]) as [Sanction Check],   
 SUM([MVR]) as [MVR], SUM([Credit Report]) as [Credit Report], SUM([Personal References]) as [Personal References],   
 SUM([Civil Searches]) as [Civil Searches], '' as [Package Desc], '' as [Selected Package], 0 as [Package], SUM(Fees) as Fees,  
 SUM([Crim Charges]) as [Crim Charges], SUM([Crim Service Charges]) as [Crim Service Charges], SUM([Civil Charges]) as [Civil Charges],  
 SUM([Social Charges]) as [Social Charges], SUM([Credit Charges]) as [Credit Charges], SUM([MVR Charges]) as [MVR Charges], SUM([Employment Charges]) as [Employment Charges],  
 SUM([Education Charges]) as [Education Charges], SUM([License Charges]) as [License Charges], SUM([Reference Charges]) as [Reference Charges]  
  from #temp3  
drop table #temp1  
drop table #temp2  
drop table #temp3  
  
END  
  