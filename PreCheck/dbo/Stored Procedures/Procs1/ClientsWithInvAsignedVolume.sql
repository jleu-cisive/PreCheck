
--[ClientsWithInvAsignedVolume] '06/1/2014','06/02/2014'

CREATE PROCEDURE [dbo].[ClientsWithInvAsignedVolume]  
@StartDate DateTime ='06/01/2014', 
@EndDate DateTime='06/02/2014' 

AS
BEGIN

drop table #vars
create table #vars (p0 date, p1 date)
insert #vars values (@StartDate,@EndDate)


-- EndRegion
SELECT [t4].[Investigator1] AS [I1], [t9].[Investigator2] AS [I2], [t4].[value] AS [c1], [t9].[value] AS [c2], [t9].[CLNO]
FROM (
    SELECT [t3].[CLNO], [t3].[Investigator1], [t3].[value]
    FROM (
        SELECT COUNT(*) AS [value], [t0].[UserID], [t2].[CLNO], [t2].[Investigator1]
        FROM [ChangeLog] AS [t0], [Appl] AS [t1], [Client] AS [t2]
        WHERE (cast( [t0].[ChangeDate] as date) >= (select p0 from #vars)) AND (cast( [t0].[ChangeDate] as date) <= (select p1 from #vars)) 
		AND (([t1].[APNO]) = [t0].[ID]) AND ([t2].[CLNO] = [t1].[CLNO]) AND (([t2].[Investigator1] = [t0].[UserID]) OR ([t2].[Investigator2] = [t0].[UserID])) 
		AND (([t2].[Investigator1] IS NOT NULL) OR ([t2].[Investigator2] IS NOT NULL))
        GROUP BY [t0].[UserID], [t2].[CLNO], [t2].[Investigator1], [t2].[Investigator2], [t2].[Name]
        ) AS [t3]
    WHERE [t3].[UserID] = [t3].[Investigator1]
    GROUP BY [t3].[CLNO], [t3].[Investigator1], [t3].[value]
    ) AS [t4]
CROSS JOIN (
    SELECT [t8].[CLNO], [t8].[Investigator2], [t8].[value]
    FROM (
        SELECT COUNT(*) AS [value], [t5].[UserID], [t7].[CLNO], [t7].[Investigator2]
        FROM [ChangeLog] AS [t5], [Appl] AS [t6], [Client] AS [t7]
        WHERE (cast( [t5].[ChangeDate] as date) >= (select p0 from #vars)) AND (cast( [t5].[ChangeDate] as date) <= (select p1 from #vars)) AND (([t6].[APNO]) = [t5].[ID]) AND ([t7].[CLNO] = [t6].[CLNO]) AND (([t7].[Investigator1] = [t5].[UserID]) OR ([t7].[Investigator2] = [t5].[UserID])) AND (([t7].[Investigator1] IS NOT NULL) OR ([t7].[Investigator2] IS NOT NULL))
        GROUP BY [t5].[UserID], [t7].[CLNO], [t7].[Investigator1], [t7].[Investigator2], [t7].[Name]
        ) AS [t8]
    WHERE [t8].[UserID] = [t8].[Investigator2]
    GROUP BY [t8].[CLNO], [t8].[Investigator2], [t8].[value]
    ) AS [t9]
WHERE [t9].[CLNO] = [t4].[CLNO]


DECLARE @p2 Int = 1
DECLARE @p5 Int = 2
-- EndRegion
SELECT [t10].[Investigator1] AS [Investigator], [t10].[CLNO], [t10].[value2] AS [id]
FROM (
    SELECT [t4].[Investigator1], [t4].[CLNO], [t4].[value], @p2 AS [value2]
    FROM (
        SELECT [t3].[CLNO], [t3].[Investigator1], [t3].[value]
        FROM (
            SELECT COUNT(*) AS [value], [t0].[UserID], [t2].[CLNO], [t2].[Investigator1]
            FROM [ChangeLog] AS [t0], [Appl] AS [t1], [Client] AS [t2]
            WHERE (cast( [t0].[ChangeDate] as date) >= (select p0 from #vars)) AND (cast( [t0].[ChangeDate] as date) <= (select p1 from #vars)) AND (([t1].[APNO]) = [t0].[ID]) AND ([t2].[CLNO] = [t1].[CLNO]) AND (([t2].[Investigator1] = [t0].[UserID]) OR ([t2].[Investigator2] = [t0].[UserID])) AND (([t2].[Investigator1] IS NOT NULL) OR ([t2].[Investigator2] IS NOT NULL))
            GROUP BY [t0].[UserID], [t2].[CLNO], [t2].[Investigator1], [t2].[Investigator2], [t2].[Name]
            ) AS [t3]
        WHERE [t3].[UserID] = [t3].[Investigator1]
        GROUP BY [t3].[CLNO], [t3].[Investigator1], [t3].[value]
        ) AS [t4]
    UNION
    SELECT [t9].[Investigator2], [t9].[CLNO], [t9].[value], @p5 AS [value2]
    FROM (
        SELECT [t8].[CLNO], [t8].[Investigator2], [t8].[value]
        FROM (
            SELECT COUNT(*) AS [value], [t5].[UserID], [t7].[CLNO], [t7].[Investigator2]
            FROM [ChangeLog] AS [t5], [Appl] AS [t6], [Client] AS [t7]
            WHERE (cast( [t5].[ChangeDate] as date) >= (select p0 from #vars)) AND (cast( [t5].[ChangeDate] as date) <= (select p1 from #vars)) AND (([t6].[APNO]) = [t5].[ID]) AND ([t7].[CLNO] = [t6].[CLNO]) AND (([t7].[Investigator1] = [t5].[UserID]) OR ([t7].[Investigator2] = [t5].[UserID])) AND (([t7].[Investigator1] IS NOT NULL) OR ([t7].[Investigator2] IS NOT NULL))
            GROUP BY [t5].[UserID], [t7].[CLNO], [t7].[Investigator1], [t7].[Investigator2], [t7].[Name]
            ) AS [t8]
        WHERE [t8].[UserID] = [t8].[Investigator2]
        GROUP BY [t8].[CLNO], [t8].[Investigator2], [t8].[value]
        ) AS [t9]
    ) AS [t10]


-- Region Parameters

-- EndRegion
SELECT SUM([t3].[value]) AS [Count], [t3].[CLNO], [t3].[Investigator1], [t3].[Investigator2], [t3].[Name]
FROM (
    SELECT COUNT(*) AS [value], [t2].[CLNO], [t2].[Investigator1], [t2].[Investigator2], [t2].[Name]
    FROM [ChangeLog] AS [t0], [Appl] AS [t1], [Client] AS [t2]
    WHERE (cast( [t0].[ChangeDate] as date) >= (select p0 from #vars)) AND (cast( [t0].[ChangeDate] as date) <= (select p1 from #vars)) AND (([t1].[APNO]) = [t0].[ID]) AND ([t2].[CLNO] = [t1].[CLNO]) AND (([t2].[Investigator1] = [t0].[UserID]) OR ([t2].[Investigator2] = [t0].[UserID])) AND (([t2].[Investigator1] IS NOT NULL) OR ([t2].[Investigator2] IS NOT NULL))
    GROUP BY [t0].[UserID], [t2].[CLNO], [t2].[Investigator1], [t2].[Investigator2], [t2].[Name]
    ) AS [t3]
GROUP BY [t3].[CLNO], [t3].[Investigator1], [t3].[Investigator2], [t3].[Name]




--Select c.CLNO as CLNO, c.Name As ClientName, c.CAM as CAM, c.Investigator1 as Investigator1,
--c.Investigator2 as Investigator2, 
--(Select Count(Apno) from Appl Where c.Investigator1 = a.USERID ) as AssignedInvestigator1, 
--(Select Count(Apno) from Appl Where c.Investigator2 = a.USERID ) as AssignedInvestigator2, 
--(Select Count(Apno) from Appl Where c.Investigator1 <> a.USERID  AND c.Investigator2 <> a.USERID) as AssignOthers
--From Client C
--Inner join Appl a on C.CLNO = a.CLNO and c.CAM = a.UserID
--Where (a.Apdate Between @StartDate and DATEADD(d, 1, @EndDate))
--Group by c.CLNO, c.Name, c.CAm,c.Investigator1, c.Investigator2, a.UserID


END