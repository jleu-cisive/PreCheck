-- Alter Procedure County_Avg_Turnaround_International








-- [County_Avg_Turnaround_International] '1/1/2015','1/1/2015','HARRIS'


CREATE PROCEDURE [dbo].[County_Avg_Turnaround_International]
	@StartDate datetime 
, @EndDate datetime 
--, @County varchar(100)
, @Country varchar(30) 
AS



----
--DECLARE @StartDate datetime,@EndDate datetime,@County varchar(100),@State varchar(10);
--SET @StartDate = '--1/1/2010--';
--SET @EndDate = '--2/1/2010--';
--SET @County = '--HARRIS--';
--SET @Country = '--USA--';

if DATEDIFF(m,@StartDate,@EndDate) >= 13
	BEGIN
		select 'Date range is equal or larger than 13 months.'
		END
		ELSE
		BEGIN
		select p.average,cc.county,cc.a_county,cc.Country
		from dbo.TblCounties cc with (nolock) 
		inner join 
		(SELECT round((avg(CONVERT(numeric(7,2), 
		(dbo.GetBusinessDays(c.irisordered,c.last_updated) + ((case when datediff(hh,c.irisordered,c.last_updated) < 24 then datediff(hh,c.irisordered,c.last_updated) else 0 end)/24.0)))) * 24),0) as average,
		c.cnty_no
		FROM    Crim c  with (nolock) 
		inner join dbo.TblCounties cc  with (nolock) on c.cnty_no = cc.cnty_no
		where c.irisordered is not null and c.last_updated is not null 
		and irisordered between @StartDate and @EndDate
		--and cc.a_county like '%' + @County + '%' 
and cc.Country = @Country
		group by c.cnty_no) p
		on p.cnty_no = cc.cnty_no
	END
