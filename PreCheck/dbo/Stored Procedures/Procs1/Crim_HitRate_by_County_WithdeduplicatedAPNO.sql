-- Alter Procedure Crim_HitRate_by_County_WithdeduplicatedAPNO
-- =============================================
-- Author:		Prasanna
-- Create date: 5/19/2020
-- Description:	<Description,,>
-- EXEC Crim_HitRate_by_County_WithdeduplicatedAPNO '01/01/2019','12/31/2019',''
-- EXEC Crim_HitRate_by_County_WithdeduplicatedAPNO '01/01/2019','12/31/2019','**STATEWIDE CAREGIVER**,W'
-- EXEC Crim_HitRate_by_County_WithdeduplicatedAPNO '01/01/2019','12/31/2019','**STATEWIDE**, NJ'
-- =============================================
CREATE PROCEDURE [dbo].[Crim_HitRate_by_County_WithdeduplicatedAPNO] 
	@StartDate datetime = null,
	@EndDate datetime = null,
	@County varchar(100) = null
AS
BEGIN

   Select county [County],Sum(OrderedCount) OrderedCount, sum(HitCount) HitCount, ((100 * Sum(HitCount))/Sum(OrderedCount)) 'HitRate %', sum(ClearCount) ClearCount, ((100 * sum(ClearCount))/Sum(OrderedCount)) 'ClearRate %'
    From  (  
			select (case when cty.County = '' then A_County else cty.County end) County, count(1) OrderedCount,0 HitCount ,0 ClearCount 
			from Appl A (nolock) 
			inner join crim c (nolock) on A.Apno =c.Apno                      
			inner join dbo.TblCounties  cty (nolock) on c.cnty_no = cty.cnty_no   
			where 
				c.IsHidden = 0
				And Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
				And  (Case When @County = 'All'  or @County = '' then @County else (case when cty.County = '' then A_County else cty.County end) end) like @County + '%'  
			group by (case when cty.County = '' then A_County else cty.County end)  
	
			UNION ALL  

			SELECT (case when cty.County = '' then A_County else cty.County end) County, 0 OrderedCount,count(DISTINCT c.Apno) HitCount, 0 ClearCount 			
			from Appl A (nolock) 
			inner join crim c (nolock) on A.Apno =c.Apno                      
			inner join dbo.TblCounties  cty (nolock) on c.cnty_no = cty.cnty_no   
			where 
				Clear = 'F' 
				AND c.IsHidden = 0
				and Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
				And  (Case When @County = 'All' or @County = '' then @County else (case when cty.County = '' then A_County else cty.County end) end) like @County + '%'  
			group by (case when cty.County = '' then A_County else cty.County end)

			UNION ALL  
			SELECT (case when cty.County = '' then A_County else cty.County end) County, 0 OrderedCount,0 HitCount, count(1) ClearCount 
			from Appl A (nolock) inner join crim c (nolock) on A.Apno =c.Apno                      
				inner join dbo.TblCounties  cty (nolock) on c.cnty_no = cty.cnty_no   
			where 
				Clear = 'T' 
				AND c.IsHidden = 0
				and Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
				And  (Case When @County = 'All' or @County = '' then @County else (case when cty.County = '' then A_County else cty.County end) end) like @County + '%'  
			group by (case when cty.County = '' then A_County else cty.County end)
 
	) Query  
	group by county  
	order by County  

END
