CREATE PROCEDURE [dbo].[Iris_Calculate_Last_30Day_Average] @Vendorid int AS  
  
 
  
SELECT round((avg(CONVERT(numeric(7,2),  
 (dbo.GetBusinessDays(c.irisordered,c.last_updated) + ((case when datediff(hh,c.irisordered,c.last_updated) < 24 then datediff(hh,c.irisordered,c.last_updated) else 0 end)/24.0)))) * 24),0) as average  
FROM    Crim c  with (nolock) where irisordered is not null and last_updated is not null and   
irisordered between Dateadd(Day,-30,CURRENT_TIMESTAMP) and CURRENT_TIMESTAMP  
and c.vendorid =  @Vendorid  