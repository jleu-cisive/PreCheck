-- =============================================
-- Author:		Suchitra Yellapantula
-- Create Date: 01/10/2017
-- Description: To provide an Education Audit Trail of the Investigator for a given date range (based on the Empl_AuditReport stored procedure)
-- Execution : EXEC [dbo].[Educat_AuditReport]  'CCooper','02/03/2020','02/03/2020'
-- Modified by Humera Ahmed on 5/14/2019 for HDT#52179
-- Modified by Humera Ahmed on 2/3/2020 for HDT#66710
-- Modified by Amy Liu on 09/04/2020 for phase3 of project: IntranetModule: Status-substatus
-- =============================================
CREATE PROCEDURE [dbo].[Educat_AuditReport] 
	-- Add the parameters for the stored procedure here
	@Userid varchar(50),
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--declare 	@Userid varchar(50) = 'rjones',
	--			@StartDate DateTime = '09/01/2020',
	--			@EndDate DateTime = '09/01/2020'

			DROP TABLE IF EXISTS #tmp

	SELECT * INTO #tmp FROM 
	(
		SELECT DISTINCT e.Apno, e.School, l.TableName, l.NewValue, l.ChangeDate,l.UserID ,l.ID
		FROM changelog l WITH (NOLOCK) 
		INNER JOIN Educat E ON E.EducatID = l.ID 
		WHERE Tablename LIKE 'Educat.%'
		 AND UserID like '%-Educat'
		 AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
		 AND CASE WHEN CHARINDEX('-',Userid) > 0 THEN LEFT(Userid,CHARINDEX('-',Userid)-1) ELSE Userid END = @Userid
	) AS t

--	SELECT '#tmp',* FROM #tmp

	DECLARE @EducationWebStatus TABLE
	(
		EducatID INT,
		APNO INT,
		School nvarchar(200),
		WebStatus INT,
		ChangeDate datetime,
		UserID nvarchar(25),
		RowNumber INT
	)

	DECLARE @EducationSectStatus TABLE
	(
		EducatID INT,
		APNO INT,
		School nvarchar(200),
		--[Status] INT,
		[Status] char(1), --Modified By Humera Ahmed on 2/3/2020 to fix error on HDT#66710
		ChangeDate datetime,
		UserID nvarchar(25),
		RowNumber INT
	)

	;WITH EducationWebStatus AS 
	(
	SELECT DISTINCT e.EducatID,	(e.APNO) AS APNO, e.School AS School,
			T.NewValue AS WebStatus, 
			T.ChangeDate AS ChangeDate,
			T.UserID,
			ROW_NUMBER() OVER (PARTITION BY (T.ID) ORDER BY (T.ChangeDate) DESC) AS RowNumber
	FROM #tmp AS T
	INNER JOIN dbo.Educat e(NOLOCK) ON T.ID = E.EducatID
	WHERE T.TableName IN ('Educat.web_status')
	)
	INSERT INTO @EducationWebStatus
	SELECT * FROM EducationWebStatus E WHERE E.RowNumber = 1 


	;WITH EducationSectStatus AS 
	(
	SELECT DISTINCT e.EducatID,	(e.APNO) AS APNO, e.School AS School,
			T.NewValue AS [Status], 
			T.ChangeDate AS ChangeDate,
			T.UserID,
			ROW_NUMBER() OVER (PARTITION BY (T.ID) ORDER BY (T.ChangeDate) DESC) AS RowNumber
	FROM #tmp AS T
	INNER JOIN dbo.Educat e(NOLOCK) ON T.ID = E.EducatID
	WHERE  T.TableName IN ('Educat.SectStat')
	)
	INSERT INTO @EducationSectStatus
	SELECT * FROM EducationSectStatus E WHERE E.RowNumber = 1 

	DECLARE @EducationSectSubStatus TABLE
	(
		EducatID INT,
		APNO INT,
		SectSubStatusID INT NULL,
		SectSubStatus varchar(100) NULL,
		ChangeDate datetime,
		UserID nvarchar(25),
		RowNumber INT
	)

	;WITH EducationSectSubStatus AS 
	(
	select t.ID as EducatID,t.APNO, t.NewValue as SectSubStatusID, sss.SectSubStatus ,t.ChangeDate, t.UserID, ROW_NUMBER() over (Partition by (t.ID) Order by (t.changeDate) Desc) as RowNumber
	from #tmp t
	inner join @EducationSectStatus lgss on t.ID = lgss.EducatID
	left join dbo.SectSubStatus sss (nolock) on t.NewValue = sss.SectSubStatusID
	where t.TableName in  ('Educat.SectSubStatus','Educat.SectSubStatusID') --and t.ID in  (3941621,3944852,3949186) 
	)

	insert into @EducationSectSubStatus
	select * from EducationSectSubStatus esss where esss.RowNumber =1


	--SELECT DISTINCT W.APNO, W.School, W.WebStatus, S.[Status], ISNULL(W.ChangeDate,S.ChangeDate) AS ChangeDate
	SELECT DISTINCT t.APNO, t.School, W.WebStatus, S.[Status], esss.SectSubStatus,ISNULL(W.ChangeDate,S.ChangeDate) AS ChangeDate --HAhmed on 5/14/2019 for HDT#52179
	FROM #tmp t
	Left JOIN @EducationWebStatus AS W ON T.ID = W.EducatID -- HAhmed on 5/14/2019 for HDT#52179
	LEFT OUTER JOIN @EducationSectStatus AS S ON T.ID = S.EducatID
	Left Join @EducationSectSubStatus esss on T.ID = esss.EducatID

	DROP TABLE #tmp


END


