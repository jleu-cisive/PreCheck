-- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 09/05/2019  
-- Description: Clone SLA details for client and add the address fields
-- EXEC [dbo].[SLA Details for Client] '2167','08/01/2018','08/31/2018',117, '','1'  
-- EXEC [dbo].[SLA Details for Client] 11340,'03/01/2019', '03/30/2019',4,NULL  
-- EXEC [dbo].[SLA Details for Client] 0,'04/01/2019', '05/20/2019',0,NULL 
-- EXEC [SLA Details for Client]  7519,'06/01/2019','07/01/2019',0,NULL
 /* Modified By: Vairavan A
-- Modified Date: 07/06/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -54481 Update AffiliateID Parameters 971-1053
*/
---Testing
/*
EXEC [dbo].[SLADetailsforClient_Address] 0,'04/01/2019', '05/20/2019','0',NULL 
EXEC [dbo].[SLADetailsforClient_Address] 0,'04/01/2019', '05/20/2019','4',NULL 
EXEC [dbo].[SLADetailsforClient_Address] 0,'04/01/2019', '05/20/2019','4:8',NULL 
*/
-- =============================================  
CREATE  PROCEDURE [dbo].[SLADetailsforClient_Address]   
@CLNO VARCHAR(MAX) = NULL,  
@StartDate DateTime ,   
@EndDate DateTime ,  
--@AffiliateID int,--code commented by vairavan for ticket id -53763(54481)
@AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763(54481)
@CAM varchar(8) = null  

as  
BEGIN 

--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends
  
 if(@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null') Begin  SET @CLNO = NULL  END  
  
 if(@CAM = '0' OR @CAM = '' OR LOWER(@CAM) = 'null') Begin  SET @CAM = NULL  END  
  
 DECLARE @startOfCurrentMonth DATETIME  
 SET @startOfCurrentMonth = DATEADD(month, DATEDIFF(month, 0, @StartDate), 0)  
  
 --SELECT @startOfCurrentMonth  
  
 SELECT a.APNO   
  into #temp1  
 FROM dbo.Appl A with(NOLOCK)  
 WHERE (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno)))   
   AND A.OrigCompDate BETWEEN @StartDate and DateAdd(d,1,@EndDate)   
   AND A.CLNO NOT IN (3468)  

  
 Select distinct Apno, CNTY_NO into #temp2 from Crim with(NOLOCK)  where Apno in (select Apno from #temp1) and ishidden = 0   
 
 SELECT  A.SSN, COUNT(*) NoOfSSNs into #tmpSSN
FROM dbo.Appl AS A WITH(NOLOCK) 
WHERE REPLACE(a.SSN,'-','') IN (SELECT REPLACE(SSN,'-','') 
           FROM dbo.Appl WITH(NOLOCK) 
           WHERE APNO IN (SELECT * FROM #temp1))
GROUP BY A.SSN


  
 select 
	distinct DATENAME(month, a.ApDate)  [Report Month],
	a.clno [Client ID],
	ra.Affiliate, 
	a.ClientApplicantNO AS [CandidateID],  
	name [Client Name] ,
	c.[Addr1] AS [Client Address],
	c.[City] AS [Client City],
	c.[State] AS [Client State],
	c.[Zip] As [Client Zip],
	Attn as [Contact Name] ,
	a.apno as [Report Number],  
	FORMAT(a.apdate,'MM/dd/yyyy hh:mm tt') as 'Report Create Date',  
	FORMAT(a.origcompdate,'MM/dd/yyyy hh:mm tt') as 'Original Closed Date',  
	a.EnteredVia as 'Submitted Via', C.CAM,   
	a.Last [Applicant Last],
	a.First [Applicant First],
	a.SSN,
	a.DOB,
 isnull(crimcount,0) [Crim Count],isnull(Emplcount,0) [Emp Count],  
 isnull(Educatcount,0) [Edu Count],isnull(Licensecount,0) [Lic Count],isnull(Socialcount,0) PID,  
 isnull(MedicareCount,0) [Sanctions],isnull(MVRcount,0) [MVR Count],isnull(Creditcount,0) [Credit],  
 isnull(Referencecount,0) [Reference Count],isnull(Civilcount,0) [Civil Count],substring(Description,10,len(Description)) PackageDesc, PackageDesc 'SelectedPackage',  
 [dbo].GetInvoiceDetailPerSection (a.apno,0,null) [Package Price]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,1,null) Fees  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crim') [Crim Addtl Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crimpassthru') [Crim Service Charge]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,3,null) [Civil Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,4,'social') [Social Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,4,'credit') [Credit Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,5,null) [MVR Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,6,null) [Emp Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,7,null) [Edu Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,8,null) [Lic Charges]  
 ,[dbo].GetInvoiceDetailPerSection (a.apno,9,null) [Reference Charges]  
 ,( dbo.elapsedbusinessdays_2( a.Apdate, a.Origcompdate ) ) as [Turnaround]  
 ,( dbo.elapsedbusinessdays_2( a.Apdate, a.Origcompdate ) + dbo.elapsedbusinessdays_2( a.Reopendate, a.Compdate ) ) as [Reopen Turnaround],  
 ( dbo.elapsedbusinesshours_2( a.Apdate, a.Origcompdate ) ) as [Business Hours],  
 DATEDIFF(hour, a.apdate , a.origcompdate)as [Calendar Time Hours],  
 DATEDIFF(day, a.apdate , a.origcompdate)as [Calendar Time Days],   
 (CASE WHEN ISNULL(F.IsOneHR,0) = 0 THEN 'False' ELSE 'True' END) AS IsOneHR   
 into #tempResult1  
 from client c with(NOLOCK)   
 inner join appl a with(NOLOCK) on c.clno=a.clno   
 inner join refAffiliate ra  with(NOLOCK)  on ra.AffiliateID = c.AffiliateID  
 left join (select apno,count(1) crimcount from #temp2 group by apno) crim on a.apno = crim.apno  
 left join (select apno,count(1) Emplcount from Empl with(NOLOCK) where Empl.IsOnReport = 1 and empl.ishidden = 0 group by apno) Empl on a.apno = Empl.apno  
 left join (select apno,count(1) Educatcount from Educat with(NOLOCK) where Educat.IsOnReport = 1 and educat.ishidden = 0 group by apno) Educat on a.apno = Educat.apno  
 left join (select apno,count(1) Licensecount from ProfLic with(NOLOCK) where ProfLic.IsOnReport = 1 and proflic.ishidden = 0 group by apno) ProfLic on a.apno = ProfLic.apno  
 left join (select apno,count(1) Socialcount from Credit with(NOLOCK) where  Credit.reptype = 'S' group by apno) Social on a.apno = Social.apno  
 left join (select apno,count(1) MVRcount from DL with(NOLOCK) group by apno) DL on a.apno = DL.apno  
 left join (select apno,count(1) MedicareCount from MedInteg with(NOLOCK) group by apno) MedInteg on a.apno = MedInteg.apno  
 left join (select apno,count(1) Creditcount from Credit with(NOLOCK) where  reptype = 'C' group by apno) Credit on a.apno = Credit.apno  
 left join (select apno,count(1) Referencecount from PersRef with(NOLOCK) where PersRef.IsOnReport = 1 and persref.ishidden = 0 group by apno) PersRef on a.apno = PersRef.apno   
 left join (select apno,count(1) Civilcount from Civil with(NOLOCK) group by apno) Civil on a.apno = Civil.apno   
 left join InvDetail Inv with(NOLOCK) on Inv.APNO = a.APNO and type=0  
 left join packagemain p with(NOLOCK) on a.PackageID = P.PackageID 
 LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON ISNULL(A.DeptCode,0) = F.FacilityNum  and A.CLNO=F.FacilityCLNO  
 LEFT JOIn ApplAdditionalData apd with(NOLOCK) on a.APno = apd.APNO
 WHERE (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno)))   
   AND A.OrigCompDate BETWEEN @StartDate and DateAdd(d,1,@EndDate)   
   --AND (RA.AffiliateID = IIF(@AffiliateID=0,RA.AffiliateID,@AffiliateID)) --code commented by vairavan for ticket id -53763(54481)
   and (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)
   AND C.CAM = IIF(@CAM is null,c.CAM,@CAM)  
   AND A.CLNO NOT IN (3468)     
 
  

 --SELECT * FROM #tempResult1  
  
 SELECT 'Total' [Report Month],'' [Client ID],'' Affiliate, '' AS [CandidateID], ''  [Client Name], '' [Client Address], '' [Client City],'' [Client State], '' [Client Zip],
 ''  [Contact Name],'' [Report Number],'' [Report Create Date],'' [Original Closed Date],  
'' as 'Submitted Via', '' CAM,   
'' [Applicant Last],'' [Applicant First],'' SSN,'' DOB,  sum([Crim Count]) as [Crim Count], sum([Emp Count]) [Emp Count],  
sum([Edu Count])  [Edu Count], sum([Lic Count]) [Lic Count], sum(PID)  PID,  
sum([Sanctions])  [Sanctions],sum([MVR Count])  [MVR Count],sum([Credit]) [Credit],  
sum([Reference Count]) [Reference Count],sum([Civil Count]) [Civil Count],''  PackageDesc,''  [SelectedPackage],  
sum([Package Price]) [Package Price], sum(Fees) Fees, sum([Crim Addtl Charges]) [Crim Addtl Charges], sum([Crim Service Charge]) [Crim Service Charge],  
sum([Civil Charges])  [Civil Charges],  
sum([Social Charges])  [Social Charges],  
sum([Credit Charges])  [Credit Charges] , 
sum([MVR Charges])  [MVR Charges],  
sum([Emp Charges])  [Emp Charges],  
sum([Edu Charges])  [Edu Charges],  
sum([Lic Charges])  [Lic Charges],  
sum([Reference Charges])  [Reference Charges],  
sum([Turnaround])  as [Turnaround],  
sum([Reopen Turnaround])  as  [Reopen Turnaround], 
sum([Business Hours]) AS [Business Hours],  
sum([Calendar Time Hours]) AS [Calendar Time Hours],  
sum([Calendar Time Days]) AS [Calendar Time Days],  
'' AS IsOneHR 
INTO #tempResult2  
FROM #tempResult1  
  
   
  
 SELECT DISTINCT * FROM
 (  
	 SELECT * FROM  #tempResult1   
  
	 UNION ALL  
  
	 SELECT * FROM  #tempResult2   
 ) AS Y  
 ORDER BY [Report Month],[Client ID]  
  
  
 drop table #temp1  
 drop table #temp2  
 drop table #tempResult1  
 drop table #tempResult2  

  
END 
