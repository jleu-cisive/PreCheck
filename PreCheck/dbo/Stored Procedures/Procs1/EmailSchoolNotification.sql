





--School Notification: execute daily. Will send notification for yesterday's activity only(not today's)
--as we dont have a time stamp on DateStatusSet col of applstudentaction.
--We should pull the history of the app as well.


CREATE   PROCEDURE [dbo].[EmailSchoolNotification] AS

(SELECT q1.CLNO_School, count(*) as appCount, q1.School, q1.SchoolEmail
FROM ( 
SELECT  asa.APNO, asa.CLNO_Hospital, app.CLNO AS CLNO_School, cl.Name as 'School',
		cc.email as 'SchoolEmail',cc.ContactID
FROM    applstudentaction asa WITH (NOLOCK)
		INNER JOIN appl app WITH (NOLOCK) ON app.apno =  asa.apno
		INNER JOIN client cl WITH (NOLOCK) ON cl.CLNO = app.CLNO
		INNER JOIN clientContacts cc WITH (NOLOCK) ON app.CLNO = cc.clno--school
WHERE  asa.APNO in (
SELECT  DISTINCT(asa1.APNO) FROM applstudentaction asa1
WHERE 	datediff(day, Convert(VarChar, asa1.DateStatusSet,101),Convert(VarChar, GetDate(), 101)) = 1 -- we dont have actual time stamp on this DateStatusSet.so ignoring the time for now. else it should be getdate() -1
		--OR datediff(day, Convert(VarChar, asa1.DateStatusSet,101),Convert(VarChar, GetDate(), 101)) = 0--dont use it else this record will be repeated for two notifications.
		--asa1.DateStatusSet >=(DATEADD(d,-2,GETDATE()) )
		--AND asa1.DateStatusSet <= GETDATE() 
		AND asa1.CLNO_Hospital <> 0) 
		AND asa.DateStatusSet is not NULL
		AND asa.DateStatusSet >= DateAdd(d,-180,getdate())
		AND asa.StudentactionID <> 0
		--AND app.CLNO = 3668

) q1
--WHERE q1.CLNO_School =3668
GROUP BY q1.CLNO_School, q1.School,q1.ContactID, q1.SchoolEmail)


SELECT	app.APNO,
		SUBSTRING((app.First + ' ' + app.Last ),1,20) as 'ApplicantName',
		app.CLNO as 'CLNO_School',
		--, cl1.Name as 'School',
		SUBSTRING(cp.Name, 1,25) as 'SchoolProgram',
		asa.CLNO_Hospital,
		SUBSTRING(cl.Name ,1,35) as 'Hospital',
		(CASE  asa.StudentactionID
			WHEN 0 THEN 'Not Reviewed'
			WHEN 1 THEN 'Accepted'
			WHEN 2 THEN 'Possible Reject'
			WHEN 3 THEN 'Rejected'
		END) as 'Status',
		CONVERT(VarChar(2),MONTH(asa.DateStatusSet)) + '/' + CONVERT(VarChar(2), DAY(asa.DateStatusSet)) + '/' + CONVERT(VarChar(4), YEAR(asa.DateStatusSet)) 
		As 'Date'
		
FROM    applstudentaction asa WITH (NOLOCK)
		INNER JOIN appl app WITH (NOLOCK) on app.apno =  asa.apno
	
		INNER JOIN client cl WITH (NOLOCK) ON cl.CLNO = asa.CLNO_Hospital
		LEFT OUTER JOIN clientprogram cp WITH (NOLOCK) ON cp.clientprogramid = app.clientprogramid

WHERE asa.APNO in (
SELECT  DISTINCT(asa1.APNO) FROM applstudentaction asa1
WHERE 	datediff(day, Convert(VarChar, asa1.DateStatusSet,101),Convert(VarChar, GetDate(), 101)) = 1 -- we dont have actual time stamp on this DateStatusSet.so ignoring the time for now. else it should be getdate() -1
		--OR datediff(day, Convert(VarChar, asa1.DateStatusSet,101),Convert(VarChar, GetDate(), 101)) = 0--dont use it else this record will be repeated for two notifications.
		--asa1.DateStatusSet >=(DATEADD(d,-2,GETDATE()) )
		--AND asa1.DateStatusSet <= GETDATE() 
		
		AND asa1.CLNO_Hospital <> 0 ) 
		AND asa.DateStatusSet is not NULL
		AND asa.DateStatusSet >= DateAdd(d,-180,getdate())
		AND asa.StudentactionID <> 0
		--AND app.CLNO =3668
ORDER BY app.apno,asa.DateStatusSet DESC



















