
--[M_edu_zlist_test] 'JEmbry ','C.Name'


CREATE PROCEDURE [dbo].[M_edu_zlist_test]
(
	@investigator varchar(30)
	, @t_sortby varchar(20)
)
AS
SET NOCOUNT ON
--Modified by Santosh on 050907 to fix a sorting issue


-- online education module JS
--DECLARE @SearchSQL varchar(5000)
--IF (select @t_sortby) = 'no'
--BEGIN
--	SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator
--		, CASE WHEN a.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
--		, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last
--		, E.SectStat, C.Name
--	FROM dbo.Educat E
--		INNER JOIN dbo.Appl A ON E.APNO = A.APNO
--		INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
--	WHERE A.ApStatus IN ('P','W')
--		--AND E.IsOnReport = 1
--		AND E.SectStat = '9'
--		AND E.Investigator = @investigator
--	ORDER BY A.ApDate ASC
--END
--
--IF (select @t_sortby) <> 'no'
--BEGIN
--	SET @searchsql = '' +
--		'SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator ' +
--		'	, CASE WHEN a.special_instructions IS NULL THEN ''No'' ELSE ''Yes'' END AS ''SI'' ' +
--		'	, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last ' +
--		'	, E.SectStat, C.Name ' +
--		'FROM dbo.Educat E ' +
--		'	INNER JOIN dbo.Appl A ON E.APNO = A.APNO ' +
--		'	INNER JOIN dbo.Client C ON A.CLNO = C.CLNO ' + 
--		'WHERE A.ApStatus IN (''P'',''W'') ' + 
--		'	AND E.SectStat = ''9'' ' + 
--		'	AND E.Investigator = ''' + @investigator + ''''+
--		' ORDER BY ' + @t_sortby
--
--		--'	AND E.IsOnReport = 1 ' + 
--print @searchsql
--	EXEC(@SearchSQL)
--END

--GO


--SET NOCOUNT ON



Select a.* into #Educat_temp from
	(SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator
		, CASE WHEN a.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
		, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last
		, E.SectStat, C.Name
	--INTO #Educat_temp
	FROM dbo.Educat E
		INNER JOIN dbo.Appl A ON E.APNO = A.APNO
		INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
		--LEFT JOIN dbo.ApplSections_Followup af ON e.EducatID = af.ApplSectionID and e.APNO = af.Apno
	WHERE A.ApStatus IN ('P','W')
		AND E.IsOnReport = 1
		AND E.SectStat = '9'
		AND E.Investigator = @investigator
		--AND --((af.IsCompleted is null and af.Repeat_Followup is null) or 
		--(af.IsCompleted = 0 and af.Repeat_Followup = 0)
		union
		SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator
		, CASE WHEN a.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
		, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last
		, E.SectStat, C.Name
	--INTO #Educat_temp
	FROM dbo.Educat E
		INNER JOIN dbo.Appl A ON E.APNO = A.APNO
		INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
		LEFT JOIN dbo.ApplSections_Followup af ON e.EducatID = af.ApplSectionID and e.APNO = af.Apno
	WHERE --A.ApStatus IN ('P','W')
		--AND 
E.IsOnReport = 1
		--AND E.SectStat = '9'
		AND E.Investigator = @investigator
		AND --((af.IsCompleted is null and af.Repeat_Followup is null) or 
		(af.IsCompleted = 0 and af.Repeat_Followup = 0)
		and (FollowupOn < DATEADD(d,1,getdate()))) a
	

IF @t_sortby = 'no'

	Set @t_sortby = ' ApDate ASC'
else
begin
if charindex('.',@t_sortby)>1

Set @t_sortby = 'a.' + substring(@t_sortby,3,len(@t_sortby))
End
select @t_sortby

Exec ('select * from #Educat_temp a order by ' + @t_sortby)

Drop Table #Educat_temp

SET NOCOUNT OFF




