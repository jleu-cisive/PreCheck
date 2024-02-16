-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PR_AppCounts]
	@SPMODE int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @myMonth int,@myYear int,@StartDate datetime,@Enddate datetime;
	
	
if @SPMODE = 0
BEGIN
select top 25 c.name, count(*) as appcount from appl a with (nolock) inner join client c with (nolock) on 
a.clno = c.clno
where a.apdate >= convert(varchar,getdate(),101)
group by c.clno,c.name
order by appcount desc
END
ELSE
if @SPMODE = 1
BEGIN


SET @myMonth = datepart(mm,getdate());
SET @myYear = datepart(yyyy,getdate());
SET @StartDate = '' + cast(@myMonth as varchar) + '/1/' + cast(@myYear as varchar);
SET @EndDate = dateadd(m,1,@StartDate);

select top 25 c.name, count(*) as appcount from appl a with (nolock) inner join client c with (nolock) on 
a.clno = c.clno
where a.apdate >= @StartDate and a.apdate < @EndDate
group by c.clno,c.name
order by appcount desc
END
ELSE
if @SPMODE = 2
BEGIN


SET @myMonth = datepart(mm,getdate());
SET @myYear = datepart(yyyy,getdate());
SET @StartDate = '1/1/' + cast(@myYear as varchar);
SET @EndDate = dateadd(yy,1,@StartDate);

select top 25 c.name, count(*) as appcount from appl a with (nolock) inner join client c with (nolock) on 
a.clno = c.clno
where a.apdate >= @StartDate and a.apdate < @EndDate
group by c.clno,c.name
order by appcount desc
END
END
