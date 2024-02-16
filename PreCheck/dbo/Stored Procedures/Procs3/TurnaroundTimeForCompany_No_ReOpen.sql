/*
Author: DEEPAK VODETHELA
Requested by: Dana Sangerhausen
Description: Please create new qreport that only calculates using the first close date
Execcution: EXEC [dbo].[TurnaroundTimeForCompany_No_ReOpen] '06/01/2020','06/30/2020',3			
Modified by Humera Ahmed on 2/11/2020 for HDT#67152 - Display reports that have an original closed date during the date parameters entered.  
It should not matter what the App Created date is, and it should not include details for reopened items. 
-- Modified By Radhika Dereddy on 08/25/2020 to add AffiliateId for the parameter to exclude the Affiliates
/* Modified By: Vairavan A
-- Modified Date: 07/05/2022
-- Description: Ticketno-53763 
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
EXEC TurnaroundTimeForCompany_No_ReOpen '03/01/2020','06/25/2020','0'
EXEC TurnaroundTimeForCompany_No_ReOpen '03/01/2020','06/25/2020','4'
EXEC TurnaroundTimeForCompany_No_ReOpen '03/01/2020','06/25/2020','4:8'
*/
*/

CREATE PROCEDURE [dbo].[TurnaroundTimeForCompany_No_ReOpen]
(
  @StartDate datetime,
  @EndDate datetime,
 -- @AffiliateID int--code commented by vairavan for ticket id -53763
  @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763
)
as

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

    -- Insert statements for procedure here
DECLARE @TempTable TABLE 
( 
    turnaround int 
) 

insert into @TempTable (turnaround)
select dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) 
			+ dbo.elapsedbusinessdays_2( Appl.ReopenDate, Appl.Origcompdate )  
   from Appl with (nolock)
   inner join CLient c with (nolock) on appl.clno = c.clno
   inner join refAffiliate rf with (nolock) on c.AffiliateId = rf.AffiliateId
  where 
   OrigCompDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) --By Humera Ahmed on 2/11/2020 for HDT#67152
   and apstatus in ('W','F')
   and c.clno NOT IN (2135, 3468)
   --and c.AffiliateId Not IN (@AffiliateID)--code commented by vairavan for ticket id -53763
     and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763


DECLARE @TempTableSum TABLE 
( 
    turnaround int, 
    total int,
    percentage decimal(16,2),
    grandtotal int
) 

insert into @TempTableSum (turnaround, total, percentage, grandtotal)

select  case when grouping(turnaround) = 1 then max(turnaround) + 1
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
from @TempTable
group by turnaround
with CUBE


	Select	case when A.total/cast(A.grandtotal as decimal) = 1 then ''
				else cast(A.turnaround as varchar(8))
			end as [Days],
			A.total as [Count],
			(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,2))) as Percentage,
			(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
																		FROM @TempTableSum B 
																		WHERE B.turnaround < A.turnaround 
																		  and A.turnaround <= max(TA.turnaround)),0))*100)as decimal(16,2))) AS [Cumulative Percentage],
			0 as apno, 0 as CLNO, null as 'ClientName' , null as 'Affilaite', null as 'AffiliateId', 
			null as 'App Created Date', null as 'Original Closed Date'
	from @TempTableSum A, @TempTable TA
	group by A.turnaround, A.total, A.grandtotal 

	union all

	select	dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate) + dbo.elapsedbusinessdays_2( Appl.ReopenDate, Appl.Origcompdate ) as [Days],
			0 as totalcount,
			0 as percentage, 
			0 as [Cumulative Percentage],
			apno, c.CLNO, c.Name as 'ClientName', rf.Affiliate, rf.Affiliateid, apdate as 'App Created Date', origcompdate as 'Original Closed Date'
	from appl with (nolock) 
	inner join CLient c with (nolock) on appl.clno = c.clno
	inner join refAffiliate rf with (nolock) on c.AffiliateId = rf.AffiliateId
	where  appl.OrigCompDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) --By Humera Ahmed on 2/11/2020 for HDT#67152
	  and (c.CLNO not in (2135, 3468)) 
	  and appl.apstatus in ('W','F')
	  --and c.AffiliateId Not IN (@AffiliateID)--code added by vairavan for ticket id -53763
	    and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
END
