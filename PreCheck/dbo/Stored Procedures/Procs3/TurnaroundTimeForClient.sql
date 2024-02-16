-- =============================================
/* Modified By: Vairavan A
-- Modified Date: 06/28/2022
-- Description: Main Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Subticket id -54476 Update AffiliateID Parameter 130-429
*/
---Testing
/*
EXEC TurnaroundTimeForClient 0, '01/01/2018','01/30/2018','0',0
EXEC TurnaroundTimeForClient 0, '01/01/2018','01/30/2018','4',1
*/
-- =============================================

CREATE PROCEDURE [dbo].[TurnaroundTimeForClient]
(
  @CLNO int,
  @StartDate datetime,
  @EndDate datetime,
  --@AffiliateIDs varchar(MAX) = NULL, --code commented by vairavan for ticket id -54476
  @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -54476
  @IsOneHR BIT = 1
)
as
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

	DECLARE @EmplTable TABLE 
	( 
		section varchar(10), 
		turnaround int 
	) 

	IF(@CLNO = 0 OR @CLNO IS NULL OR LOWER(@CLNO) = 'null' OR @CLNO='')
	BEGIN
	  SET @clno = 0
	END

	 --code commented by vairavan for ticket id -54476 starts
	--IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' ) 
	--BEGIN  
	--	SET @AffiliateIDs = NULL  
	--END
	--code commented by vairavan for ticket id -54476 starts


		--code added by vairavan for ticket id -54476 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -54476 ends


	INSERT INTO @EmplTable (section, turnaround)
	SELECT 'Empl' AS section,
		   case when dbo.elapsedbusinessdays_2(E.createddate, E.last_worked) < 11 then dbo.elapsedbusinessdays_2(E.createddate, E.last_worked) 
		   else 11 end as turnaround 
  FROM Empl AS E with(nolock) 
  INNER JOIN Appl AS A with(nolock) on E.Apno = A.Apno
  INNER JOIN CLIENT AS C with(NOLOCK) ON A.CLNO = C.CLNO
  LEFT JOIN HEVN.dbo.Facility F with (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
  INNER JOIN refAffiliate AS RA   WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
  WHERE E.createddate >= @StartDate
    AND E.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
    AND (@CLNO = 0 or A.CLNO = @CLNO)
    AND (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
    AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
    AND E.SectStat IN ('2','3','4','5','6','7','8','A')

	DECLARE @EmplTableSum TABLE 
	( 
		section varchar(10), 
		turnaround int, 
		total int,
		percentage decimal(16,4),
		grandtotal int
	) 

	insert into @EmplTableSum (section, turnaround, total, percentage, grandtotal)
	select 'Empl' as section, 
			case when grouping(turnaround) = 1 then 12
			else turnaround end as turnaround,
			sum(count(*)) over(partition by turnaround ) as total,
			sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
			sum(count(*)) over()/2 as grandtotal
	   from @EmplTable
	 group by turnaround
	 with cube

	DECLARE @EducatTable TABLE 
	( 
		section varchar(10), 
		turnaround int 
	) 

	INSERT INTO @EducatTable (section, turnaround)
	SELECT 'Educat' as section,
			case when dbo.elapsedbusinessdays_2(E.createddate, E.last_worked) < 11 then dbo.elapsedbusinessdays_2(E.createddate, E.last_worked) 
			else 11 end as turnaround 
	FROM Educat AS E with(nolock) 
	INNER JOIN Appl AS A with (nolock) on E.Apno = A.Apno
	INNER JOIN CLIENT AS C with (NOLOCK) ON A.CLNO = C.CLNO
	LEFT JOIN HEVN.dbo.Facility F with (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE E.createddate >= @StartDate
	  AND E.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
	  AND (@CLNO = 0 or A.CLNO = @CLNO)
	  AND (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
	  AND E.SectStat IN ('2','3','4','5','6','7','8','A')

	DECLARE @EducatTableSum TABLE 
	( 
		section varchar(10), 
		turnaround int, 
		total int,
		percentage decimal(16,4),
		grandtotal int
	) 

	INSERT INTO @EducatTableSum (section, turnaround, total, percentage, grandtotal)
	SELECT 'Educat' as section, 
			case when grouping(turnaround) = 1 then 12
			else turnaround end as turnaround,
			sum(count(*)) over(partition by turnaround ) as total,
			sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
			sum(count(*)) over()/2 as grandtotal
	 from @EducatTable
	 group by turnaround
	 with cube

	DECLARE @ProfLicTable TABLE 
	( 
		section varchar(10), 
		turnaround int 
	) 

	INSERT INTO @ProfLicTable (section, turnaround)
	SELECT 'ProfLic' as section,
			case when dbo.elapsedbusinessdays_2(P.createddate, P.last_worked) < 11 then dbo.elapsedbusinessdays_2(P.createddate, P.last_worked) 
			else 11 end as turnaround 
	FROM ProfLic AS P with(nolock) 
	INNER JOIN Appl AS A with(nolock) on P.Apno = A.Apno
	INNER JOIN CLIENT AS C with(NOLOCK) ON A.CLNO = C.CLNO
	LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE P.createddate >= @StartDate
	  AND P.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
	  AND (@CLNO = 0 or A.CLNO = @CLNO)
	  AND (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
	  AND P.SectStat IN ('2','3','4','5','6','7','8','A')

	DECLARE @ProfLicTableSum TABLE 
	( 
		section varchar(10), 
		turnaround int, 
		total int,
		percentage decimal(16,4),
		grandtotal int
	) 

	INSERT INTO @ProfLicTableSum (section, turnaround, total, percentage, grandtotal)
	SELECT 'ProfLic' as section, 
			case when grouping(turnaround) = 1 then 11
			else turnaround end as turnaround,
			sum(count(*)) over(partition by turnaround ) as total,
			sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
			sum(count(*)) over()/2 as grandtotal
	 from @ProfLicTable
	 group by turnaround
	 with cube

	DECLARE @PersRefTable TABLE 
	( 
		section varchar(10), 
		turnaround int 
	) 

	insert into @PersRefTable (section, turnaround)
	SELECT 'PersRef' as section,
			case when dbo.elapsedbusinessdays_2(P.createddate, P.last_worked) < 11 then dbo.elapsedbusinessdays_2(P.createddate, P.last_worked) 
			else 11 end as turnaround 
	FROM PersRef AS P with(nolock) 
	INNER JOIN Appl AS A with(nolock) on P.Apno = A.Apno
	INNER JOIN CLIENT AS C with(NOLOCK) ON A.CLNO = C.CLNO
	LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE P.createddate >= @StartDate
	  AND P.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
	  AND (@CLNO = 0 or A.CLNO = @CLNO)
	  AND (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
	  AND P.SectStat IN ('2','3','4','5','6','7','8','A')

	DECLARE @PersRefTableSum TABLE 
	( 
		section varchar(10), 
		turnaround int, 
		total int,
		percentage decimal(16,4),
		grandtotal int
	) 

	insert into @PersRefTableSum (section, turnaround, total, percentage, grandtotal)
	select 'PersRef' as section, 
			case when grouping(turnaround) = 1 then 12
			else turnaround end as turnaround,
			sum(count(*)) over(partition by turnaround ) as total,
			sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
			sum(count(*)) over()/2 as grandtotal
	   from @PersRefTable
	 group by turnaround
	 with cube

	DECLARE @CrimTable TABLE 
	( 
		section varchar(10), 
		turnaround int 
	) 

	insert into @CrimTable (section, turnaround)
	select 'Crim' as section,
		   case when dbo.elapsedbusinessdays_2(Crim.crimenteredtime, Crim.last_updated) < 11 then dbo.elapsedbusinessdays_2(Crim.crimenteredtime, Crim.last_updated) 
		   else 11 end as turnaround 
	from Crim with (nolock) 
	INNER JOIN Appl AS A with(nolock) on Crim.Apno = A.Apno
	INNER JOIN CLIENT AS C with(NOLOCK) ON A.CLNO = C.CLNO
	LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	 where Crim.crimenteredtime >= @StartDate
	   and Crim.last_updated < DATEADD(DAY, 1, @EndDate) --@EndDate
	   and (@CLNO=0 or A.CLNO = @CLNO)
	   AND (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))
	   AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
	   and Crim.Clear in ('T','F','P')

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
			case when grouping(turnaround) = 1 then 12
			else turnaround end as turnaround,
			sum(count(*)) over(partition by turnaround ) as total,
			sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
			sum(count(*)) over()/2 as grandtotal
	   from @CrimTable
	 group by turnaround
	 with cube


	Select 
		case when A.turnaround = 12 then 'Total'
			 else A.section 
		end as [Type],
		case when A.total/cast(A.grandtotal as decimal) = 1 then ''
			else 
			  case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
				   else cast(A.turnaround as varchar(8)) + ' days' 
			  end 
		end as Days,
		A.total as [Count],
		(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
		(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
							  FROM
							  @EmplTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 12),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
	from
	@EmplTableSum A
	group by A.section, A.turnaround, A.total, A.grandtotal 
	union all
	Select 
		case when A.turnaround = 12 then 'Total'
			 else A.section 
		end as [Type],
		case when A.turnaround = 12 then ''
			else 
			  case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
				   else cast(A.turnaround as varchar(8)) + ' days' 
			  end 
		end as Days,
		A.total as [Count],
		(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
		(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
							  FROM
							  @EducatTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 12),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
	from
	@EducatTableSum A
	group by A.section, A.turnaround, A.total, A.grandtotal 
	union all
	Select 
		case when A.turnaround = 12 then 'Total'
			 else A.section 
		end as [Type],
		case when A.total/cast(A.grandtotal as decimal) = 1 then ''
			else 
			  case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
				   else cast(A.turnaround as varchar(8)) + ' days' 
			  end 
		end as Days,
		A.total as [Count],
		(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
		(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
							  FROM
							  @ProfLicTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 12),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
	from
	@ProfLicTableSum A
	group by A.section, A.turnaround, A.total, A.grandtotal 
	union all
	Select 
		case when A.turnaround = 12 then 'Total'
			 else A.section 
		end as [Type],
		case when A.total/cast(A.grandtotal as decimal) = 1 then ''
			else 
			  case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
				   else cast(A.turnaround as varchar(8)) + ' days' 
			  end 
		end as Days,
		A.total as [Count],
		(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
		(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
							  FROM
							  @PersRefTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 12),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
	from
	@PersRefTableSum A
	group by A.section, A.turnaround, A.total, A.grandtotal 
	union all
		Select 
		case when A.turnaround = 12 then 'Total'
			 else A.section 
		end as [Type],
		case when A.total/cast(A.grandtotal as decimal) = 1 then ''
			else 
			  case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
				   else cast(A.turnaround as varchar(8)) + ' days' 
			  end 
		end as Days,
		A.total as [Count],
		(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
		(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
							  FROM
							  @CrimTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 12),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
		from
	@CrimTableSum A
	group by A.section, A.turnaround, A.total, A.grandtotal 

END
