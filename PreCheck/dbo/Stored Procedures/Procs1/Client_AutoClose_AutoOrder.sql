  -- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 06/02/2014  
-- Description: <Description,,>  
-- Modified By: Deepak Vodethela  
-- Modified by: 02/14/2018  
-- Description: Added NumberOfReports,AORExceptions,ACExceptions columns to the QReport.(See Ticket#29540 for full explnation)  
-- Excecution: EXEC [Client_AutoClose_AutoOrder] '02/01/2018','02/13/2018', 0  
-- Modified By : Radhika Dereddy  
-- Modified Date: 08/14/2018  
-- Modified Reason : Per Dana - Please add following fields in the output for this report: Affiliate, Adjudication Client (T/F answer) (if Adjudication Process radio button in Client Config/Adjuction tab is set to True)   
-- =============================================  
/* Modified By: YSharma   
-- Modified Date: 10/18/2022  
-- Description: Ticketno-#56320   
Modify existing q-reports that have affiliate ids in their search parameters  
Details:   
Change search parameters for the Affiliate Id field  
     * search by multiple affiliate ids (ex 4:297)  
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates  
     * multiple affiliates to be separated by a colon    
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)  
*/  
/* Modified By: Vairavan A   
-- Modified Date: 01/23/2024 
-- Description: Ticket no - 123940  Qreport called Clients with Auto Order and/or Auto Close not loading
-- [dbo].[Client_AutoClose_AutoOrder]   '01/01/2024','01/22/2024',0, NULL  
*/ 
--============================================= 

CREATE PROCEDURE [dbo].[Client_AutoClose_AutoOrder]   
 -- Add the parameters for the stored procedure here  
 @StartDate Datetime ,  
 @EndDate DateTime,  
 @CLNO int ,
 @AffiliateID Varchar(Max)   -- Added on the behalf for HDT #56320
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  

IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320  
 Begin      
  SET @AffiliateID = NULL      
 END 

 --code added for ticket no - 123940 starts
 Drop table if exists #TempClient
 Drop table if exists #AutoOrderTotal
 Drop table if exists #AutoCloseTotal
 Drop table if exists #NumberOfReports
 --code added for ticket no - 123940 ends

 Create Table #TempClient  
 (  
 CLNO int,  
 ClientName varchar(100),  
 ClientType varchar(50),  
 CAM varchar(8),  
 Affiliate nvarchar(50),  
 AffiliateID int,  
 AdjudicationClient varchar(5),  
 AutoOder varchar(500),  
 AutoClose varchar(500),  
 AutoOrderTotal int,  
 AutoCloseTotal int,  
 NumberOfReports int  
 )  
  
   --code commented for ticket no - 123940 starts
  /*
  -- Insert statements for procedure here  
 Insert into #TempClient (CLNO, ClientName, ClientType, CAM,  Affiliate, AffiliateID, AdjudicationClient, AutoOder, AutoClose, AutoOrderTotal, AutoCloseTotal,NumberOfReports)  
    (  
 SELECT c.clno as CLNO,c.name as ClientName,rc.clienttype as ClientType,c.CAM,ra.Affiliate,ra.AffiliateID,  
  isnull((select Value from ClientConfiguration(NOLOCK) where clno = c.clno and configurationkey = 'AdjudicationProcess'),'False') as AdjudicationClient,  
  isnull((select Value from ClientConfiguration(NOLOCK) where clno = c.clno and configurationkey = 'AutoOrder'),'False') as AutoOrder,  
  isnull((select Value from ClientConfiguration(NOLOCK) where clno = c.clno and configurationkey = 'AutoClose'),'False') as AutoClose,  
  isnull(iif(isnull((select Value from ClientConfiguration(NOLOCK) where clno = c.clno and configurationkey = 'AutoOrder'),'False') = 'True',  
  isnull((select count(A.apno) from appl AS A(NOLOCK) where A.clno = c.clno and A.investigator = 'AUTO' and (A.apdate between @startdate and DATEADD(d,1,@EndDate))),'0'),'0'),'0') as AutoOrderTotal,  
  isnull(iif(isnull((select Value from ClientConfiguration(NOLOCK) where clno = c.clno and configurationkey = 'AutoClose'),'False')  = 'True',  
  isnull((select count(app.apno) from ApplAutoCloseLog AS app(NOLOCK) inner join appl AS Ap(NOLOCK) on app.apno = Ap.apno  where (app.closedon between @startdate and DATEADD(d,1,@EndDate) and Ap.clno = c.clno )),'0'),'0'),'0') as AutoCloseTotal,  
  (Select COUNT(a.Apno) as NumberOfReports From Appl a(NOLOCK) Where A.clno = c.clno AND a.Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)) AS NumberOfReports  
 FROM Client AS C(NOLOCK)   
 INNER JOIN refAffiliate ra (NOLOCK) ON C.AffiliateID =  ra.AffiliateID  
 LEFT OUTER JOIN refClientType AS rc(NOLOCK) on rc.ClientTypeID = c.ClientTypeID   
 WHERE c.clno = IIF(@CLNO=0, CLNO, @CLNO) 
 AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320 
 AND c.IsInActive = 0  
 )  
 */
   --code commented for ticket no - 123940 ends

   --code added for ticket no - 123940 starts
  select c.clno,count(A.apno) apno  into #AutoOrderTotal
  from appl AS A with(NOLOCK) 
      inner join  Client c with(NOLOCK) 
  on c.clno = a.clno
  and A.investigator = 'AUTO' 
  and A.apdate between @startdate and DATEADD(d,1,@EndDate)
  group by c.clno

  select c.clno,count(app.apno) as apno into #AutoCloseTotal
  from ApplAutoCloseLog AS app with(NOLOCK) 
	   inner join appl AS Ap with(NOLOCK) 
  on app.apno = Ap.apno 
	   inner join Client c  with(NOLOCK) 
  on c.clno = ap.clno
  and app.closedon between @startdate and DATEADD(d,1,@EndDate) 
  group by c.clno

  Select  c.clno,COUNT(a.Apno)  as cnt  into #NumberOfReports
  From Appl a with(NOLOCK) 
	inner join Client c with(NOLOCK) 
  on c.clno = a.clno
  and a.Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
  group by c.clno

  
  -- Insert statements for procedure here  
 Insert into #TempClient (CLNO, ClientName, ClientType, CAM,  Affiliate, AffiliateID, AdjudicationClient, AutoOder, AutoClose, AutoOrderTotal, AutoCloseTotal,NumberOfReports)  
    ( 

	 SELECT c.clno as CLNO,c.name as ClientName,rc.clienttype as ClientType,c.CAM,ra.Affiliate,ra.AffiliateID,  
	  isnull(ap.value,'False') as AdjudicationClient,  
	  isnull(ao.value,'False') as AutoOrder,  
	  isnull(ac.value,'False') as AutoClose,  
	  isnull(iif(isnull(ao.value,'False') = 'True', isnull(aot.apno,'0'),'0'),'0') as AutoOrderTotal,  
	  isnull(iif(isnull(ao.value,'False')  = 'True', isnull(act.apno,'0'),'0'),'0') as AutoCloseTotal,  
	  nor.cnt AS NumberOfReports  
	 FROM Client AS C with(NOLOCK)    
	     INNER JOIN 
		 refAffiliate ra with(NOLOCK) 
	 ON C.AffiliateID =  ra.AffiliateID  
	     LEFT OUTER JOIN 
		 refClientType AS rc with(NOLOCK)  
	 on rc.ClientTypeID = c.ClientTypeID   
	     left join 
		 (select Value,clno from ClientConfiguration with(NOLOCK)  where configurationkey = 'AdjudicationProcess') ap  
	 on  c.clno = ap.clno
		left join (select Value,clno from ClientConfiguration with(NOLOCK) where configurationkey = 'AutoOrder') ao 
	 on  c.clno = ao.clno
	  left join (select Value,clno from ClientConfiguration with(NOLOCK) where configurationkey = 'AutoClose') ac 
	 on  c.clno = ac.clno
	 left join #AutoOrderTotal aot
	 on(c.clno = aot.clno)
	  left join #AutoCloseTotal act
	 on(c.clno = act.clno)
	  left join #NumberOfReports nor 
	 on(c.clno = nor.clno)
	 WHERE c.clno = IIF(@CLNO=0, c.CLNO, @CLNO) 
	 AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320 
	 AND c.IsInActive = 0  
   )

   --code added for ticket no - 123940 ends

 Select CLNO, ClientName, ClientType, CAM, Affiliate, AffiliateID,AdjudicationClient, AutoOder, AutoClose, AutoOrderTotal, AutoCloseTotal,   
      NumberOfReports,   
     (NumberOfReports - AutoOrderTotal) AS AORExceptions,  
     (NumberOfReports - AutoCloseTotal) AS ACExceptions  
 From #TempClient  
  
 UNION ALL  
  
 Select '', 'TOTAL' ClientName, '', '',  '','','','','',  
 Sum(AutoOrderTotal),  
 Sum(AutoCloseTotal),  
 Sum(NumberOfReports),  
 '' AS AORExceptions, '' AS ACExceptions    
 From #TempClient  
  
 Drop Table #TempClient  

  SET NOCOUNT OFF; 
END 

