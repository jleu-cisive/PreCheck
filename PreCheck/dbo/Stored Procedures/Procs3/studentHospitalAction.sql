CREATE PROCEDURE [dbo].[studentHospitalAction] 
@SSN varchar(11) = null,
@DOB varchar(50),
@APNO varchar(10) = null
AS
IF(@DOB != '' and @DOB IS NOT NULL and @SSN != '' and @SSN IS NOT NULL and (@APNO IS NULL or @APNO = ''))
BEGIN
	Declare @Query Varchar(2000)
    SET @SSN = REPLACE(@SSN,'-','')

	SET @Query = 'SELECT Top 1 Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',
	CASE WHEN (Appl.ReopenDate IS NOT NULL  and Appl.ApStatus != ''F'') THEN  ''F'' ELSE Appl.ApStatus END as ''ApStatus'',
	Appl.First,Appl.Last,
    ''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,BackgroundReportID
	, Appl.ReopenDate
	FROM Appl 
	LEFT JOIN backgroundreports..backgroundreport br ON br.apno= Appl.apno
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	appl.clno not in (16022,16023,16024) and
	((REPLACE(Appl.SSN,''-'','''') = '''+@SSN+''')
    OR (REPLACE(Appl.i94,''-'','''') = '''+@SSN+'''))
	
	AND (Appl.DOB = '''+@DOB+''')	
	Order by (br.BackgroundReportID) DESC' 
		--AND (Appl.Enteredvia = ''StuWeb''  or cl.clienttypeid in (6,8,9,11,12,13))
	Exec( @Query)
END

ELSE IF(@DOB != '' and @DOB IS NOT NULL and @APNO != '' and @APNO IS NOT NULL  and ( @SSN = '' or @SSN IS NULL))
BEGIN
	Declare @Query2 Varchar(2000)

SET @Query2 = 'SELECT Top 1 Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',
CASE WHEN (Appl.ReopenDate IS NOT NULL  and Appl.ApStatus != ''F'') THEN  ''F'' ELSE Appl.ApStatus END as ''ApStatus'',
Appl.First,Appl.Last,
 ''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,BackgroundReportID
	, Appl.ReopenDate
	FROM Appl 
	Left JOIN backgroundreports..backgroundreport br ON br.apno= Appl.apno
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	appl.clno not in (16022,16023,16024) and
	(Appl.DOB = '''+@DOB+''')	
		AND  (Appl.APNO ='''+@APNO+''')
			Order by (br.BackgroundReportID) DESC' 
		--AND (Appl.Enteredvia = ''StuWeb'' 
	Exec( @Query2)

END
ELSE IF((@DOB != '' and @DOB IS NOT NULL) and (@APNO != '' and @APNO IS NOT NULL)  and  (@SSN != '' and @SSN IS NOT NULL))
BEGIN
	Declare @Query3 Varchar(2000)
    SET @SSN = REPLACE(@SSN,'-','')

	SET @Query3 = 'SELECT Top 1 Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',
	CASE WHEN (Appl.ReopenDate IS NOT NULL  and Appl.ApStatus != ''F'') THEN  ''F'' ELSE Appl.ApStatus END as ''ApStatus'',Appl.First,Appl.Last,
	''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,BackgroundReportID
	, Appl.ReopenDate
	FROM Appl 
	Left JOIN backgroundreports..backgroundreport br ON br.apno= Appl.apno
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	appl.clno not in (16022,16023,16024) and
	((REPLACE(Appl.SSN,''-'','''') = '''+@SSN+''')
    OR (REPLACE(Appl.i94,''-'','''') = '''+@SSN+'''))
	AND (Appl.DOB = '''+@DOB+''')	
		AND  (Appl.APNO ='''+@APNO+''')
		Order by (br.BackgroundReportID) DESC' 
		--AND (Appl.Enteredvia = ''StuWeb'' 
	Exec( @Query3)
END
