

--EXEC [StudentHospitalAction]  '257-95-7775', '04/02/1996'
Create PROCEDURE [dbo].[studentHospitalAction_org]
@SSN varchar(11),
@DOB varchar(50)
AS
IF(@SSN != '' and @DOB != '')
BEGIN

    SET @SSN = REPLACE(@SSN,'-','')
	Declare @Query Varchar(2000)

	SET @Query = 'SELECT Appl.APNO, isnull(Appl.apdate,Appl.CreatedDate) as ''Apdate'',Appl.ApStatus,Appl.First,Appl.Last,
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
	AND (Appl.Enteredvia = ''StuWeb''  or cl.clienttypeid in (6,8,9,11,12,13)) '

	--print @Query
	Exec( @Query)
END

















