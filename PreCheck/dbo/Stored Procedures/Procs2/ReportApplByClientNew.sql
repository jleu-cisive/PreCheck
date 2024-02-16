
CREATE PROCEDURE [dbo].[ReportApplByClientNew] 
@Clno int,
@StartDate DateTime, 
@EndDate DateTime,
@Client varchar(50) --4/28/06
--@DateType varchar(20) --4/28/06

AS
-- JS 7/28/2005
-- Returns list of Application per client
-- hz modified on 4/28/06, add two parameters: @Client, @DateType
-- hz modified on 5/15/06 for project# 3255

--declare @dType varchar(20)


--if (@DateType='apDate' and @Clno!=0)
if (@Clno!=0)--changed on 5/15/06
begin
	SELECT Client.CLNO
	, Appl.APNO
	, Appl.[Last]
	, Appl.[First]
	, Appl.Middle
	, Appl.SSN
	, Client.Name
	, Appl.ApStatus
	,Appl.ApDate
	
	, CASE WHEN Appl.OrigCompDate IS NULL THEN Appl.CompDate ELSE Appl.OrigCompDate END AS OriginalCompletionDate
	, DATEDIFF(dd,ApDate,CASE WHEN Appl.OrigCompDate IS NULL THEN Appl.CompDate ELSE Appl.OrigCompDate END) AS Turnaround_Original
	, CASE WHEN ((DATEDIFF(dd,Appl.OrigCompDate,Appl.CompDate)=0) OR (Appl.OrigCompDate IS NULL)) THEN NULL ELSE Appl.CompDate END AS FinalCompletionDate
	, CASE WHEN ((DATEDIFF(dd,Appl.OrigCompDate,Appl.CompDate)=0) OR (Appl.OrigCompDate IS NULL)) THEN NULL ELSE DATEDIFF(dd,ApDate,Appl.CompDate) END AS Turnaround_Final
	
	
	FROM Appl INNER JOIN Client ON Appl.CLNO = Client.CLNO
	WHERE (Client.CLNO = @Clno) AND (Appl.ApDate >= CONVERT(DATETIME, @StartDate, 102)) 
		AND (Appl.ApDate < CONVERT(DATETIME, @EndDate, 102))
	ORDER BY Appl.ApDate
end
--else if (@DateType='apDate' and @Clno=0)
else if (@Clno=0)--changed on 5/15/06
begin
	SELECT Client.CLNO
	, Appl.APNO
	, Appl.[Last]
	, Appl.[First]
	, Appl.Middle
	, Appl.SSN
	, Client.Name
	, Appl.ApStatus
	,Appl.ApDate

	, CASE WHEN Appl.OrigCompDate IS NULL THEN Appl.CompDate ELSE Appl.OrigCompDate END AS OriginalCompletionDate
	, DATEDIFF(dd,ApDate,CASE WHEN Appl.OrigCompDate IS NULL THEN Appl.CompDate ELSE Appl.OrigCompDate END) AS Turnaround_Original
	, CASE WHEN ((Appl.OrigCompDate = Appl.CompDate) OR (Appl.OrigCompDate IS NULL)) THEN NULL ELSE Appl.CompDate END AS FinalCompletionDate
	, CASE WHEN ((Appl.OrigCompDate = Appl.CompDate) OR (Appl.OrigCompDate IS NULL)) THEN NULL ELSE DATEDIFF(dd,ApDate,Appl.CompDate) END AS Turnaround_Final
	
	FROM Appl INNER JOIN Client ON Appl.CLNO = Client.CLNO
	WHERE (Client.Name LIKE @Client+'%') AND (Appl.ApDate >= CONVERT(DATETIME, @StartDate, 102)) 
		AND (Appl.ApDate < CONVERT(DATETIME, @EndDate, 102))
	ORDER BY Appl.ApDate
end
--commented out on 5/15/06
--else if (@DateType='cDate' and @Clno!=0)
--begin
--	SELECT Client.CLNO, Appl.ApStatus,Appl.ApDate, Appl.APNO, Appl.[Last], 
--		Appl.[First], Appl.Middle, Appl.SSN
--	FROM Appl INNER JOIN Client ON Appl.CLNO = Client.CLNO
--	WHERE (Client.CLNO = @Clno) AND (Appl.CompDate >= CONVERT(DATETIME, @StartDate, 102)) 
--		AND (Appl.CompDate < CONVERT(DATETIME, @EndDate, 102))
--	ORDER BY Appl.CompDate
--end
--else if (@DateType='cDate' and @Clno=0)
--begin
--	SELECT Client.CLNO, Appl.ApStatus,Appl.ApDate, Appl.APNO, Appl.[Last], 
--		Appl.[First], Appl.Middle, Appl.SSN
--	FROM Appl INNER JOIN Client ON Appl.CLNO = Client.CLNO
--	WHERE (Client.Name LIKE @Client+'%') AND (Appl.CompDate >= CONVERT(DATETIME, @StartDate, 102)) 
--		AND (Appl.CompDate < CONVERT(DATETIME, @EndDate, 102))
--	ORDER BY Appl.CompDate
--end
