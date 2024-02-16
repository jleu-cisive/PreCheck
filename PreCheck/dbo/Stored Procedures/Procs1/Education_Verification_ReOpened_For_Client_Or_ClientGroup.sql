  
/*---------------------------------------------------------------------------------  
Procedure Name : [dbo].[Education_Verification_ReOpened_For_Client_Or_ClientGroup]  
Requested By: Dana Sangerhausen  
Created By: AmyLiu on 03/07/2019 HDT47685:   
Description: qreport that identifies education verifications that are reopened by a CAM after they have been placed in a closing status  
   Is OneHR - if 1, and Affiliate is 4, pulls only those verifications for reports associated with OneHR  
EXEC [dbo].[Education_Verification_ReOpened_For_Client_Or_ClientGroup] 0,NULL,NULL,0,0  

/* Modified By: YSharma 
-- Modified Date: 07/01/2022
-- Description: Ticketno-#54480 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*
EXEC [dbo].[Education_Verification_ReOpened_For_Client_Or_ClientGroup] 0,NULL,NULL,'4:177',1 

*/
*/---------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[Education_Verification_ReOpened_For_Client_Or_ClientGroup]  
@Clno VARCHAR(MAX) = 0,  
@StartDate DateTime=NULL,  -- '03/01/2019',  
@EndDate DateTime=NULL,   --'03/11/2019',  
@AffiliateID Varchar(Max),   -- Added on the behalf for HDT #54480
-- @AffiliateID int,  		 -- Comnt for HDT #54480  
@IsOneHR int=0  
AS  
BEGIN  
  
 SET ANSI_WARNINGS OFF   
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED  
  
  
 IF OBJECT_ID('tempdb..#EduOpenedWithOpenedDateList') IS NOT NULL  
  drop table #EduOpenedWithOpenedDateList  
   
IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #54480
 Begin    
  SET @AffiliateID = NULL    
 END
 --declare @Clno VARCHAR(MAX) = NULL,  
 --@StartDate DateTime='03/01/2019',  
 --@EndDate DateTime ='03/11/2019',  
 --@AffiliateID BIGint=0,  
 --@IsOneHR int=0  
 DECLARE @EduOpenedList TABLE (clno int, Name varchar(100), Affiliate  varchar(100),ReportCreatedDate datetime,School  varchar(100),EducatID bigint,APNO bigint)  
  
 IF (@IsOneHR=1 AND @AffiliateID='4')  
 BEGIN  
   insert INTO @EduOpenedList  
     SELECT a.CLNO, c.Name ,r.[Affiliate] as Affiliate, apdate ReportCreatedDate,  
    e.School , E.EducatID, E.apno   
    FROM dbo.Educat AS E WITH(NOLOCK)  
        INNER JOIN dbo.Appl AS A WITH(NOLOCK) ON E.APNO = A.APNO  
        INNER JOIN [HEVN].[dbo].[Facility] f ON a.deptcode=f.FacilityNum   
        INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO  
        INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = E.SectStat  
        INNER JOIN refAffiliate AS R  WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID  
    WHERE  
      E.IsHidden = 0  
       AND E.IsOnReport = 1   
       AND   
       e.sectstat IN ('0','9' )  
	    AND (@AffiliateID IS NULL OR R.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
		--AND (isnull(@AffiliateID,0)=0 OR  R.AffiliateID= @AffiliateID) 							-- Comnt for HDT #54480	  
        
       AND (Isnull(@CLNO,0) =0 OR C.CLNO =@CLNO )  -- IN (SELECT VALUE FROM fn_Split(@CLNO,':')))  --removed '7814:7838:7873:7885  
       AND (isnull(@IsOneHR,0)=0 OR f.IsOneHR=@IsOneHR)  
       AND apdate >=@StartDate and apdate <DateAdd(d,1,@EndDate)  
 END  
 ELSE  
 BEGIN  
    insert INTO @EduOpenedList  
    SELECT a.CLNO, c.Name ,r.[Affiliate] as Affiliate, apdate ReportCreatedDate,  
    e.School , E.EducatID, E.apno    
    FROM dbo.Educat AS E WITH(NOLOCK)  
        INNER JOIN dbo.Appl AS A WITH(NOLOCK) ON E.APNO = A.APNO  
      --  left JOIN [HEVN].[dbo].[Facility] f ON a.deptcode=f.FacilityNum   
        INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO  
        INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = E.SectStat  
        INNER JOIN refAffiliate AS R  WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID  
    WHERE  
      E.IsHidden = 0  
       AND E.IsOnReport = 1   
       AND  e.sectstat IN ('0','9' )  
       AND (@AffiliateID IS NULL OR R.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
		--AND (isnull(@AffiliateID,0)=0 OR  R.AffiliateID= @AffiliateID) 							-- Comnt for HDT #54480	
       AND (Isnull(@CLNO,0) =0 OR C.CLNO =@CLNO )  -- IN (SELECT VALUE FROM fn_Split(@CLNO,':')))  --removed '7814:7838:7873:7885  
      -- AND (isnull(@IsOneHR,0)=0 OR f.IsOneHR=@IsOneHR)  
       AND apdate >=@StartDate and apdate <DateAdd(d,1,@EndDate)  
 END   
  
   SELECT * into #EduOpenedWithOpenedDateList   -- drop table #EduOpenedWithOpenedDateList  
   FROM  
   (  
    SELECT eol.*, lg.changeDate 'ReopenDate', row_number() over (partition by eol.apno, lg.ID order by eol.apno,  lg.changeDate DESC) hlrow   
     FROM @EduOpenedList eol    
    INNER JOIN dbo.changelog lg  ON eol.EducatID= lg.ID AND lg.tableName ='Educat.SectStat'  
    WHERE lg.newvalue IN  ('0','9' )  --('4','5')  
    --AND lg.ID=3228454  
   )x   
    where x.hlrow=1    
 SELECT eodl.apno,eodl.clno, eodl.Name, eodl.Affiliate,eodl.ReportCreatedDate, eodl.School AS [School Name], eodl.EducatID, y.closeDate AS [Original Verification Close Date], eodl.ReopenDate AS [Date of Reopen], y.UserID  
 FROM  
 (  
  SELECT eol.*,lg.changeDate AS 'CloseDate', lg.UserID, row_number() over (partition by eol.apno, lg.ID order by eol.apno,  lg.changeDate DESC) hlrow     
  FROM @EduOpenedList eol    
  INNER JOIN dbo.changelog lg  ON eol.EducatID= lg.ID AND lg.tableName ='Educat.SectStat'  
  WHERE lg.newvalue IN ('4','5') --OR lg.oldvalue IN ('4','5')  
 ) y   
 inner join #EduOpenedWithOpenedDateList eodl on y.EducatID=eodl.educatID --and y.apno= eodl.apno  
 WHERE y.hlrow=1  
  
  
 IF OBJECT_ID('tempdb..#EduOpenedWithOpenedDateList') IS NOT NULL  
  drop table #EduOpenedWithOpenedDateList  
   
  
 SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
 SET NOCOUNT OFF   
  
  
 END