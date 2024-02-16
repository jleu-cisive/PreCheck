-- =============================================    
-- Author:  YSharma    
-- Create date: 07/11/2022    
-- Description: As HDT #56320 required Affiliate IDs in Qreport,So I am making changes in the same.

-- Modify Date: 2/2/2023
-- Modify By : YSharma
-- Description: Condition added after requestor's Review. When CLNO is 0 then it should give result for all.
-- Execution:     
/*    
EXEC dbo.QReport_BackgroundCompletionPriorToStartDate '0','1/01/2013','1/31/2013','4:257'    
*/    
-- =============================================    
CREATE Procedure dbo.QReport_BackgroundCompletionPriorToStartDate  
(  
@CLNO int,   
  @StartDate date,    
  @EndDate date,  
  @AffiliateID  Varchar(Max)=''   -- Added on the behalf for HDT #56320   ;   
)  
AS   
BEGIN  
   
   IF @CLNO=''  OR @CLNO=0					-- Condition Added after Requestor's Review
    BEGIN
        SET @CLNO=NULL
    END

  IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320    
  BEGIN        
   SET @AffiliateID = NULL        
  END    
  
Declare @ShowDetails int;    
declare @totalapps int;    
declare @totalwithdate int;    
declare @totalwithoutdate int;    
declare @totalcompbystartcount int;    
declare @totalcompperc decimal(2);    
declare @nodatecount int;    
declare @percnodate decimal(2);    
declare @nocompcount int;    
declare @percnocomp decimal(2);      
Declare @Details table  (  
      ReportCreatedDate date,  
      ReportNumber int,  
      ReportCompletionDate date,  
      ApplicantStartDate date,  
      ReportsCompletedbyStartDate int,  
      Percentage1 varchar(100),  
      ReportsWithNoStartDate int,  
      Percentage2 varchar(100),  
      ReportsNotCompletedByStartDate int,  
      Percentage3 varchar(100),  
      TotalReports int  )      
  
  
set @totalwithdate = (  
SELECT COUNT(*) AS [value] FROM [Appl] AS [t0]   
INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO         -- Join For Affilate ID  
WHERE ([t0].[StartDate] IS NOT NULL)   
    AND ([t0].[CLNO] =ISNULL(@CLNO,[t0].[CLNO]))   
    AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320   
    AND (convert(date, [t0].[ApDate]) >= @StartDate)   
    AND (convert(date, [t0].[ApDate]) <= @EndDate));       
      
set @totalcompbystartcount = (SELECT COUNT(*) AS [value] FROM [Appl] AS [t0]  
      INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
      WHERE ([t0].[CompDate] <= [t0].[StartDate])   
      AND ([t0].[StartDate] IS NOT NULL AND [t0].[CompDate] IS NOT NULL)         
      AND ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
      AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
      AND (convert(date, [t0].[ApDate]) >= @StartDate)   
      AND (convert(date, [t0].[ApDate]) <= @EndDate));          
set @nodatecount = (SELECT COUNT(*) AS [value]      FROM [Appl] AS [t0]    
    INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
    WHERE ([t0].[StartDate] IS NULL)        
    AND ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
    AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
    AND (convert(date, [t0].[ApDate]) >= @StartDate)   
    AND (convert(date, [t0].[ApDate]) <= @EndDate))          
set @nocompcount =  (SELECT COUNT(*) AS [value] FROM [Appl] AS [t0]   
    INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
    WHERE ([t0].[CompDate] > [t0].[StartDate] or [t0].[CompDate] IS NULL)   
    AND ([t0].[StartDate] IS NOT NULL)         
    AND ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
    AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
    AND (convert(date, [t0].[ApDate]) >= @StartDate)   
    AND (convert(date, [t0].[ApDate]) <= @EndDate));          
set @totalapps = (SELECT COUNT(*) AS [value]      FROM [Appl] AS [t0]    
    INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
    WHERE ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
    AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
    AND (convert(date, [t0].[ApDate]) >= @StartDate)   
    AND (convert(date, [t0].[ApDate]) <= @EndDate)     
    AND (convert(date, [t0].[CompDate]) >= @StartDate)   
    AND (convert(date, [t0].[CompDate]) <= @EndDate)   )            
set @totalcompperc = (convert(decimal, @totalcompbystartcount)/ convert(decimal, @totalwithdate)) * 100          
set @percnocomp = (convert(decimal, @nocompcount)/convert(decimal, @totalwithdate)) * 100          
set @percnodate = ( convert(decimal, @nodatecount)/convert(decimal, @totalapps)) * 100        
insert into @Details(Percentage1)      
Select 'Percentages:'      
insert into @Details(Percentage1)      
Select ''          
insert into @Details(ReportsCompletedbyStartDate, Percentage1, ReportsWithNoStartDate, Percentage2, ReportsNotCompletedByStartDate, Percentage3, TotalReports)  
select @totalcompbystartcount as 'Reports Completed by Start Date ',   
 convert(varchar, @totalcompperc) + '%' as 'Percentage',           
 @nodatecount as 'Reports with no Start Date ',   
 convert(varchar, @percnodate ) + '%' as 'Percentage ' ,           
 @nocompcount as 'Reports Not Completed by Start Date',   
 convert(varchar, @percnocomp) + '%' as 'Percentage  ',           
 @totalapps as 'Total Reports'          
insert into @Details(Percentage1)      
Select ''        
insert into @Details(Percentage1)      
Select 'Details:'        
insert into @Details(Percentage1)      
Select ''        
insert into @Details(Percentage1)      
Select 'Reports Completed by Start Date '    --comp by start      
insert into @Details(ReportCreatedDate, ReportNumber, ReportCompletionDate, ApplicantStartDate)      
(SELECT [t0].ApDate as 'Report Created Date',  
 [t0].APNO as 'Report Number',   
 [t0].CompDate as 'Report Completion Date',   
 [t0].StartDate as 'Applicant Start Date'        
 FROM [Appl] AS [t0]    
 INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
 WHERE ([t0].[CompDate] <= [t0].[StartDate]) AND ([t0].[StartDate] IS NOT NULL AND [t0].[CompDate] IS NOT NULL)         
 AND ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
 AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
 AND (convert(date, [t0].[ApDate]) >= @StartDate) AND (convert(date, [t0].[ApDate]) <= @EndDate));      
   
insert into @Details(Percentage1)    Select ''         
insert into @Details(Percentage1)    Select 'Reports with no Start Date '     --no start date     
insert into @Details(ReportCreatedDate, ReportNumber, ReportCompletionDate, ApplicantStartDate)      
(SELECT [t0].ApDate as 'Report Created Date',  
 [t0].APNO as 'Report Number',  
 [t0].CompDate as 'Report Completion Date',   
 [t0].StartDate as 'Applicant Start Date'        
 FROM [Appl] AS [t0]    
 INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
 WHERE ([t0].[StartDate] IS NULL)       AND ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
 AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
 AND (convert(date, [t0].[ApDate]) >= @StartDate)   
 AND (convert(date, [t0].[ApDate]) <= @EndDate))       
insert into @Details(Percentage1)    Select ''           
insert into @Details(Percentage1)    Select 'Reports Not Completed by Start Date'     --not comp by start      
insert into @Details(ReportCreatedDate, ReportNumber, ReportCompletionDate, ApplicantStartDate)      
(SELECT [t0].ApDate as 'Report Created Date', [t0].APNO as 'Report Number', [t0].CompDate as 'Report Completion Date', [t0].StartDate as 'Applicant Start Date'        
 FROM [Appl] AS [t0]   
 INNER JOIN dbo.Client AS C ON [t0].CLNO=C.CLNO   -- Join For Affilate ID  
 WHERE ([t0].[CompDate] > [t0].[StartDate] or [t0].[CompDate] IS NULL) AND ([t0].[StartDate] IS NOT NULL)        
 AND ([t0].[CLNO] = ISNULL(@CLNO,[t0].[CLNO]))   
 AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
 AND (convert(date, [t0].[ApDate]) >= @StartDate) AND (convert(date, [t0].[ApDate]) <= @EndDate));      
insert into @Details(Percentage1)    Select ''              
SELECT * FROM @Details  
  
END