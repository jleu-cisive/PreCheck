
--EXEC [StudentHospitalAction_SSN]  '154-96-3602', '11/07/1994'

--EXEC [StudentHospitalAction_SSN]  null,'11/07/1994', 3080840

CREATE PROCEDURE [dbo].[studentHospitalAction_SSN]
@SSN varchar(11) = null,
@DOB varchar(50),
@APNO varchar(10) = null

AS



IF(@DOB != '' and @DOB IS NOT NULL and @SSN != '' and @SSN IS NOT NULL and (@APNO IS NULL or @APNO = ''))
BEGIN
	Declare @Query Varchar(2000)
    SET @SSN = REPLACE(@SSN,'-','')

	SET @Query = 'SELECT Top 1 Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',Appl.ApStatus,Appl.First,Appl.Last,
    ''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,BackgroundReportID
	--, BackgroundReport
	FROM Appl 
	LEFT JOIN backgroundreports..backgroundreport br ON br.apno= Appl.apno
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	((REPLACE(Appl.SSN,''-'','''') = '''+@SSN+''')
    OR (REPLACE(Appl.i94,''-'','''') = '''+@SSN+'''))
	
	AND (Appl.DOB = '''+@DOB+''')
	AND (Appl.Enteredvia = ''StuWeb''  or cl.clienttypeid in (6,8,9,11,12,13))
	Order by (Appl.CreatedDate) DESC' 
		
	Exec( @Query)
END

ELSE IF(@DOB != '' and @DOB IS NOT NULL and @APNO != '' and @APNO IS NOT NULL  and ( @SSN = '' or @SSN IS NULL))
BEGIN
	Declare @Query2 Varchar(2000)

SET @Query2 = 'SELECT Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',Appl.ApStatus,Appl.First,Appl.Last,
 ''SSN'' = CASE WHEN i94 <> ''''  THEN i94
		ELSE ''' + 'xxx-xx-' + '''  + SUBSTRING(Appl.SSN ,8,4) END
	,BackgroundReportID
	FROM Appl 
	Left JOIN backgroundreports..backgroundreport br ON br.apno= Appl.apno
	INNER JOIN client cl ON  Appl.clno = cl.clno
	WHERE
	(Appl.DOB = '''+@DOB+''')
	AND (Appl.Enteredvia = ''StuWeb'' 
		AND  (Appl.APNO ='''+@APNO+'''))'

	Exec( @Query2)

END

