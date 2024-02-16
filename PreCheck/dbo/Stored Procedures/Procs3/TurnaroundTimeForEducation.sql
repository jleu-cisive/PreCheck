/*****************************************************************************************
Author: DEEPAK VODETHELA
Requested by: Dana Sangerhausen
Description: Please create a qreport that measures the turnaround time of education components from time that report is created to the time that the education component is closed.  
			 Show elapsed business days in left hand side, associated counts, as well as percentage and cumulative percentage. 
Execcution: EXEC [dbo].[TurnaroundTimeForEducation] '05/26/2017','06/30/2017'
Modified By: Amy Liu on 07/16/2018 HDT36141: remove days from cells
Modified By :Sahithi on 09/01/2020 HDT:76684, Added Education details for Apno
Modified By Radhika Dereddy on 04/21/2021 to add the affiliateid as a parameter.
/* Modified By: Vairavan A
-- Modified Date: 07/01/2022
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
EXEC TurnaroundTimeForEducation '03/01/2020','06/25/2020','0'
EXEC TurnaroundTimeForEducation '03/01/2020','06/25/2020','4'
EXEC TurnaroundTimeForEducation '03/01/2020','06/25/2020','4:8'
*/
******************************************************************************************/

CREATE PROCEDURE [dbo].[TurnaroundTimeForEducation]
(
  @StartDate datetime,
  @EndDate datetime,
  --@AffiliateID int--code added by vairavan for ticket id -53763
  @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763
)
AS
BEGIN

	--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

	       -- Get all the Education records which are closed in the given time range
       DECLARE @EducatTable TABLE 
       ( 
          Apno int,
          EducatID int,
          CreatedDate DateTime,
          SectStat char(1),
          LastUpdated DateTime,
          Turnaround int 
       ) 

       INSERT INTO @EducatTable (Apno, EducatID, CreatedDate,SectStat, LastUpdated, Turnaround)
       SELECT E.APNO, E.EducatID, E.CreatedDate, E.SectStat, E.Last_Updated, dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS Turnaround
       FROM dbo.Educat AS E with(NOLOCK)
	   INNER JOIN dbo.Appl a with(NOLOCK) on e.apno = a.apno
	   INNER JOIN dbo.CLient C with(NOLOCK) on a.clno = c.clno
	   INNER JOIN dbo.refaffiliate rf with(NOLOCK) on c.Affiliateid = rf.Affiliateid
       WHERE E.IsHidden = 0
         AND E.IsOnReport = 1
         AND E.SectStat in ('2','3','4','5')
		 AND E.CreatedDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
         --AND E.CreatedDate >= @StartDate
         --AND E.Last_Updated < @EndDate
		 --AND C.Affiliateid = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code Commented by vairavan for ticket id -53763
		 and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
       ORDER BY 1 DESC

       --SELECT * FROM @EducatTable

       DECLARE @EducatTableSum TABLE 
       ( 
             Turnaround int, 
             Total int,
             Percentage decimal(16,4),
             GrandTotal int
       ) 

       INSERT INTO @EducatTableSum (Turnaround, Total, Percentage, GrandTotal)
       SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 50 ELSE Turnaround END AS Turnaround,
                    SUM(COUNT(*)) OVER(PARTITION BY Turnaround ) AS Total,
                    SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
                 SUM(COUNT(*)) OVER()/2 AS Grandtotal
       FROM @EducatTable
       GROUP BY Turnaround
       WITH CUBE

       --SELECT * FROM @EducatTableSum

       SELECT CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
                           ELSE CASE WHEN A.Turnaround = 50 THEN CAST(A.Turnaround AS VARCHAR(8))  
                                        ELSE CAST(A.Turnaround AS VARCHAR(8)) 
                                  END 
                    END AS [Days],
                    A.Total AS [Count],
                    (CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS [Percentage],
                    (CAST(((A.Total/cast(A.GrandTotal AS decimal) + COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal as decimal)) r
                    FROM @EducatTableSum AS B WHERE B.Turnaround < A.Turnaround AND A.Turnaround <> 7),0))*100)AS DECIMAL(16,4))) AS [Cumulative Percentage],
                    0 as apno, null as 'App Created Date',null as 'Educat Created Date', null as 'Education Last Verified', null as 'Education Original Complete Date'
       FROM @EducatTableSum AS A
       GROUP BY A.Turnaround, A.Total, A.GrandTotal 

       UNION ALL

		SELECT CAST(( dbo.elapsedbusinessdays_2(Apdate, ed.Last_Worked)) AS NVARCHAR(100)) as [Days],
		0 as [Count],
		0 as [Percentage], 
		0 as [Cumulative Percentage],appl.apno, apdate as 'App Created Date', ed.CreatedDate as 'Educat Created Date',ed.Last_Updated as 'Education Last Verified',ed.Last_Worked as 'Education Original Complete Date'
		FROM dbo.Appl with (nolock) 
		INNER JOIN dbo.Educat ed with (nolock)  on Appl.apno = ed.apno
		WHERE ed.Last_Worked >= @StartDate 
		AND ed.Last_Worked < @EndDate 
		AND ed.SectStat not in ('9')
		GROUP BY appl.apno, apdate,ed.CampusName,ed.Last_Updated, ed.Last_Worked,ed.CreatedDate

END


