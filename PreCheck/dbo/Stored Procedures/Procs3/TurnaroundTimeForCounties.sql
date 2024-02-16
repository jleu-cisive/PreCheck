-- Alter Procedure TurnaroundTimeForCounties
-- =============================================
-- Author:		Kiran Miryala
-- Requester: Julie Foxworth
-- Create date: 01/07/2015
-- Description:	To know the longest amount of time searches took within the past year and how many days
-- Execution: EXEC [dbo].[TurnaroundTimeForCounties] '1/1/2015','1/1/2016','HAMPDEN','MA'
-- =============================================
CREATE PROCEDURE [dbo].[TurnaroundTimeForCounties]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@County varchar(100),
	@State varchar(2)
AS
SET NOCOUNT ON

	DECLARE @CrimTable TABLE 
	( 
		section varchar(10), 
		turnaround int 
	) 

	-- Get the number of Working days for a given date range when the App is in ['T' - Clear, 'F' - Record Found, 'P'- Possible]
	insert into @CrimTable (section, turnaround)
	select 'Crim' as section,
		case when dbo.elapsedbusinessdays_2( Crim.crimenteredtime, Crim.last_updated ) < 29 then dbo.elapsedbusinessdays_2( Crim.crimenteredtime, Crim.last_updated ) 
		else 29 end as turnaround 
	from Crim with (nolock) 
	inner join Appl on Appl.Apno = Crim.Apno
	INNER JOIN dbo.TblCounties c on Crim.CNTY_NO = c.CNTY_NO
	where Crim.crimenteredtime >= @StartDate
	and Crim.last_updated < @EndDate
	and c.A_County like '%' + @County + '%' 
	AND c.State = @state
	and Crim.Clear in ('T','F','P')

	-- Capture number of Records per day and their percentages
	DECLARE @CrimTableSum TABLE 
	( 
		section varchar(10), 
		turnaround int, 
		total int,
		percentage decimal(16,4),
		grandtotal int
	) 

	insert into @CrimTableSum (section, turnaround, total, percentage, grandtotal)
	select 'Crim' as section, 
			case when grouping(turnaround) = 1 then 30
			else turnaround end as turnaround,
			sum(count(*)) over(partition by turnaround ) as total,
			sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
			sum(count(*)) over()/2 as grandtotal
	from @CrimTable
	group by turnaround

	with cube

	Select 
	case when A.turnaround = 30 then 'Total'
		 else A.section 
	end as [Type],
	case when A.total/cast(A.grandtotal as decimal) = 1 then ''
		else 
		  case when A.turnaround = 29 then  cast(A.turnaround as varchar(8)) + '+ days' 
			   else cast(A.turnaround as varchar(8)) + ' days' 
		  end 
	end as Days,
	A.total as [Count],
	(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
	(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
						  FROM
						  @CrimTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
	from
	@CrimTableSum A
	group by A.section, A.turnaround, A.total, A.grandtotal 


SET NOCOUNT OFF
