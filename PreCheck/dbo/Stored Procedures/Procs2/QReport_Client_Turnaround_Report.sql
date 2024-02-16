-- =============================================    
-- Author:  YSharma    
-- Create date: 07/11/2022    
-- Description: As HDT #56320 required Affiliate IDs in Qreport So I am making changes in the same.  

-- Modify Date: 2/2/2023
-- Modify By : YSharma
-- Description: Condition added after requestor's Review. When CLNO is 0 then it should give result for all.
-- Execution:     
/*    
EXEC dbo.QReport_Client_Turnaround_Report '0','1/1/2022','1/30/2022',''    
  
*/    
-- =============================================    
CREATE Procedure dbo.QReport_Client_Turnaround_Report  
(  
@CLNO int,   
  @StartDate datetime,  
  @EndDate datetime,  
  @AffiliateID  Varchar(Max)=''   -- Added on the behalf for HDT #56320   ;   
)  
AS   
BEGIN  
    
Declare @Total int;  
  BEGIN 

  IF @CLNO=''  OR @CLNO=0					-- Condition Added after Requestor's Review
    BEGIN
        SET @CLNO=NULL
    END

  IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320    
  BEGIN        
   SET @AffiliateID = NULL        
  END   
  SET @EndDate = DateAdd(d,1,@EndDate);    
  SET @Total = (select count( APNO ) from dbo.appl A with (nolock)    
  INNER JOIN dbo.Client C ON A.CLNO=C.CLNO             -- Join For Affilate ID  
  WHERE Apdate >= @StartDate and Apdate < @EndDate and C.CLNO =ISNULL(@CLNO ,C.CLNO)
  AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320   
  );   
  
  SELECT   
  0 as apno,( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) as turnaround,    
  count(*) as totalcount,count(*)/ (cast(@Total  AS NUMERIC( 10, 2 ))) as 'percentage'   
  FROM appl As A WITH (NOLOCK)    
  INNER JOIN Client C ON A.CLNO=C.CLNO               -- Join For Affilate ID  
  WHERE Apdate >= @StartDate and Apdate < @EndDate and A.CLNO =ISNULL(@CLNO ,A.CLNO) and apstatus in ('W','F')   
  AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320    
  GROUP BY ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) )  
    
  UNION ALL    
    
  SELECT apno,( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) as turnaround,  
  0 as totalcount,  0 as 'percentage'    
  FROM appl As A WITH (NOLOCK)   
  INNER JOIN Client C ON A.CLNO=C.CLNO               -- Join For Affilate ID  
  WHERE Apdate >= @StartDate and Apdate < @EndDate and A.CLNO = ISNULL(@CLNO ,A.CLNO) and apstatus in ('W','F')  
  AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320   
  
  END  
END 