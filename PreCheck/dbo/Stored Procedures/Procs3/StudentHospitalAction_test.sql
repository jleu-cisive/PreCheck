
--EXEC [StudentHospitalAction_test] '590-82-3580', '02/21/1989'
CREATE PROCEDURE [dbo].[StudentHospitalAction_test]
@SSN varchar(11) = null,
@DOB varchar(50),
@APNO varchar(10) = null

AS



IF(@DOB != '' and @DOB IS NOT NULL and @SSN != '' and @SSN IS NOT NULL and (@APNO IS NULL or @APNO = ''))
BEGIN
	Declare @Query Varchar(2000)
    SET @SSN = REPLACE(@SSN,'-','')

	SET @Query = 'SELECT Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',
	CASE WHEN (Appl.ReopenDate IS NOT NULL  and Appl.ApStatus != ''F'') THEN  ''F'' ELSE Appl.ApStatus END as ''ApStatus'',Appl.First,Appl.Last,
    ''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,(select max(BackgroundReportID) from backgroundreports..backgroundreport where apno = Appl.apno ) as BackgroundReportID
	, Appl.ReopenDate
	FROM Appl 
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	((REPLACE(Appl.SSN,''-'','''') = '''+@SSN+''')
    OR (REPLACE(Appl.i94,''-'','''') = '''+@SSN+'''))	
	AND (Appl.DOB = '''+@DOB+''')	
	and (Apdate >= DATEADD(yy,-8,getDate()) AND Apdate <= getDate())
	order by Appl.APNO desc'
	Exec( @Query)
END

ELSE IF(@DOB != '' and @DOB IS NOT NULL and @APNO != '' and @APNO IS NOT NULL  and ( @SSN = '' or @SSN IS NULL))
BEGIN
	Declare @Query2 Varchar(2000)

SET @Query2 = 'SELECT Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',
CASE WHEN (Appl.ReopenDate IS NOT NULL and Appl.ApStatus != ''F'') THEN  ''F'' ELSE Appl.ApStatus END as ''ApStatus'',
Appl.First,Appl.Last,
 ''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,(select max(BackgroundReportID) from backgroundreports..backgroundreport where apno = Appl.apno ) as BackgroundReportID
	, Appl.ReopenDate
	FROM Appl 
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	(Appl.DOB = '''+@DOB+''')	
		AND  (Appl.APNO ='''+@APNO+''')
		and (Apdate >= DATEADD(yy,-8,getDate()) AND Apdate <= getDate())
			Order by (Appl.Apno) DESC' 
	
	Exec( @Query2)

END
ELSE IF((@DOB != '' and @DOB IS NOT NULL) and (@APNO != '' and @APNO IS NOT NULL)  and  (@SSN != '' and @SSN IS NOT NULL))
BEGIN
	Declare @Query3 Varchar(2000)
    SET @SSN = REPLACE(@SSN,'-','')

	SET @Query3 = 'SELECT Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',
	CASE WHEN (Appl.ReopenDate IS NOT NULL and Appl.ApStatus != ''F'') THEN  ''F'' ELSE Appl.ApStatus END as ''ApStatus'',Appl.First,Appl.Last,
	''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,(select max(BackgroundReportID) from backgroundreports..backgroundreport where apno = Appl.apno ) as BackgroundReportID
	, Appl.ReopenDate
	FROM Appl 	
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	((REPLACE(Appl.SSN,''-'','''') = '''+@SSN+''')
    OR (REPLACE(Appl.i94,''-'','''') = '''+@SSN+'''))
	AND (Appl.DOB = '''+@DOB+''')	
		AND  (Appl.APNO ='''+@APNO+''')
		and (Apdate >= DATEADD(yy,-8,getDate()) AND Apdate <= getDate())
		Order by (Appl.Apno) DESC' 
	
	Exec( @Query3)
END