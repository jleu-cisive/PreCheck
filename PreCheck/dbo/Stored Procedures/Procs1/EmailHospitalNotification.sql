
/* Modified by : Dongmei
 Modification reason: New StudentCheck - Excluding reports assigned to clinic but not completed for configured school/clinics only.
 Old StudentCheck - Schools assign to the clinics only once report becomes available. Holding at clinic level was not applicable/required.
 Modify Date: 09/12/2017
 Modified by Dongmei and Doug 01/06/2020
*/
CREATE   PROCEDURE [dbo].[EmailHospitalNotification] AS
--list of hospitals to send emails

Declare @MigrateToNewStudentCheck BIT
--key changed to point to Enterprise - Gaurav (1/8/2017)
--Select @MigrateToNewStudentCheck = value From ClientConfiguration Where ConfigurationKey = 'MigrateToNewStudentCheck'
Select @MigrateToNewStudentCheck = KeyValue FROM Enterprise.Config.Configuration Where KeyName = 'MigrateToNewStudentCheck'

If(@MigrateToNewStudentCheck = 1)
Begin 
    Declare @tempClientList table(Clno int)
Insert Into @tempClientList Exec [ListClientMigrateToNewStudentCheck]
  
  --Modified by Dongmei and Doug 01/06/2020
	Declare @tempStatus table(Apno int, orderStatus char(1))
	 Insert Into @tempStatus
	 SELECT distinct asa.APNO, vw.OrderStatus
	   FROM ApplStudentAction asa WITH (NOLOCK)   
 INNER JOIN [PreCheck].[Enterprise].[vwReportStatus] vw ON asa.APNO = vw.OrderNumber
	  WHERE vw.OrderStatus IN ('C', 'F')
	    AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
	    AND asa.DateHospitalAssigned <= GETDATE() )

	    DECLARE @temp1 table(APNO int, CLNO_Hospital int, CLNO_School int, SchoolName varchar(100), HospitalEmail varchar(50), ContactID int)
    INSERT INTO @temp1
		 SELECT asa.APNO, asa.CLNO_Hospital, app.CLNO AS CLNO_School, cl.Name as 'School', cc.email as 'HospitalEmail',cc.ContactID
		   FROM ApplStudentAction asa 
	 INNER JOIN Appl app WITH (NOLOCK) ON  asa.APNO = app.APNO  
	 INNER JOIN Client cl WITH (NOLOCK) ON  app.CLNO = cl.CLNO  --school
	 INNER JOIN clientcontacts cc ON cc.CLNO = asa.CLNO_Hospital --hospital
	 INNER JOIN @tempStatus ts on app.APNO = ts.Apno
	 INNER JOIN @tempClientList t on cl.CLNO = t.Clno
	      WHERE asa.StudentActionID = 0
			AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
			AND asa.DateHospitalAssigned <= GETDATE() )
			AND asa.CLNO_Hospital<>0 

		DECLARE @temp2 table(APNO int, CLNO_Hospital int, CLNO_School int, SchoolName varchar(100), HospitalEmail varchar(50), ContactID int)
	INSERT INTO @temp2
		 SELECT asa.APNO, asa.CLNO_Hospital, app.CLNO AS CLNO_School, cl.Name as 'School', cc.email as 'HospitalEmail',cc.ContactID
           FROM ApplStudentAction asa 
	 INNER JOIN Appl app WITH (NOLOCK) ON  asa.APNO = app.APNO  
	 INNER JOIN Client cl WITH (NOLOCK) ON  app.CLNO = cl.CLNO  --school
	 INNER JOIN clientcontacts cc ON cc.CLNO = asa.CLNO_Hospital --hospital
LEFT OUTER JOIN @tempClientList t ON cl.CLNO = t.Clno
          WHERE asa.StudentActionID = 0
		    AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
		    AND asa.DateHospitalAssigned <= GETDATE() )
		    AND asa.CLNO_Hospital<>0 AND t.Clno IS NULL 
	

SELECT q1.clno_hospital, count(*) as appCount, q1.HospitalEmail
FROM ( 

SELECT  *
FROM    @temp1
UNION 
SELECT  *
FROM    @temp2

	) q1
GROUP BY q1.clno_hospital, q1.contactid,q1.HospitalEmail


-- include the list
	 

Select * from
(
 SELECT asa.APNO, SUBSTRING((app.First + ' ' + app.Last),1,30) as 'ApplicantName',
		asa.CLNO_Hospital, app.CLNO AS CLNO_School,
		SUBSTRING( cl.Name,1,40) AS 'School'
		, cp.Name as 'SchoolProgram',asa.DateHospitalAssigned
           FROM ApplStudentAction asa 
	 INNER JOIN Appl app WITH (NOLOCK) ON  asa.APNO = app.APNO  
		INNER JOIN Client cl WITH (NOLOCK) ON  app.CLNO = cl.CLNO  --school
		INNER JOIN @tempStatus ts on app.APNO = ts.Apno
		INNER JOIN @tempClientList t on cl.CLNO = t.Clno
		LEFT OUTER JOIN clientprogram cp WITH (NOLOCK) ON cp.clientprogramid = app.clientprogramid
WHERE   asa.StudentActionID = 0
		AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
		AND asa.DateHospitalAssigned <= GETDATE() )
		AND asa.CLNO_Hospital<>0 
UNION
 SELECT  asa.APNO, SUBSTRING((app.First + ' ' + app.Last),1,30) as 'ApplicantName',
		asa.CLNO_Hospital, app.CLNO AS CLNO_School,
		SUBSTRING( cl.Name,1,40) AS 'School'
		, cp.Name as 'SchoolProgram',asa.DateHospitalAssigned
FROM    ApplStudentAction asa 
	    INNER JOIN Appl app WITH (NOLOCK) ON  asa.APNO = app.APNO  
		INNER JOIN Client cl WITH (NOLOCK) ON  app.CLNO = cl.CLNO  --school
		LEFT OUTER JOIN clientprogram cp WITH (NOLOCK) ON cp.clientprogramid = app.clientprogramid
		LEFT OUTER JOIN @tempClientList t ON cl.Clno = t.CLNO
WHERE   asa.StudentActionID = 0
		AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
		AND asa.DateHospitalAssigned <= GETDATE() )
		AND asa.CLNO_Hospital<>0 AND t.CLNO IS NULL
	

		)S1

order by S1.apno


End

Else
Begin

SELECT q1.clno_hospital, count(*) as appCount, q1.HospitalEmail
FROM ( 
SELECT  asa.APNO, asa.CLNO_Hospital, app.CLNO AS CLNO_School, cl.Name as 'School', cc.email as 'HospitalEmail',cc.ContactID
FROM    ApplStudentAction asa 
	    INNER JOIN Appl app WITH (NOLOCK) ON  asa.APNO = app.APNO  
		INNER JOIN Client cl WITH (NOLOCK) ON  app.CLNO = cl.CLNO  --school
		INNER JOIN clientcontacts cc ON cc.CLNO = asa.CLNO_Hospital --hospital
WHERE   asa.StudentActionID = 0
		AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
		AND asa.DateHospitalAssigned <= GETDATE() )
		--AND datediff(day, Convert(VarChar, asa.DateHospitalAssigned,101),Convert(VarChar, GetDate(), 101)) = 1 
		--OR datediff(day, Convert(VarChar, asa.DateHospitalAssigned,101),Convert(VarChar, GetDate(), 101)) = 0
	    AND asa.CLNO_Hospital<>0 
	) q1
GROUP BY q1.clno_hospital, q1.contactid,q1.HospitalEmail

-- include the list
SELECT  asa.APNO, SUBSTRING((app.First + ' ' + app.Last),1,30) as 'ApplicantName',
		asa.CLNO_Hospital, app.CLNO AS CLNO_School,
		SUBSTRING( cl.Name,1,40) AS 'School'
		, cp.Name as 'SchoolProgram',asa.DateHospitalAssigned
FROM    ApplStudentAction asa 
	    INNER JOIN Appl app WITH (NOLOCK) ON  asa.APNO = app.APNO  
		INNER JOIN Client cl WITH (NOLOCK) ON  app.CLNO = cl.CLNO  --school
		LEFT OUTER JOIN clientprogram cp WITH (NOLOCK) ON cp.clientprogramid = app.clientprogramid
WHERE   asa.StudentActionID = 0
		AND (asa.DateHospitalAssigned >( DATEADD(d,-1,GETDATE())) 
		AND asa.DateHospitalAssigned <= GETDATE() )
		--AND datediff(day, Convert(VarChar, asa.DateHospitalAssigned,101),Convert(VarChar, GetDate(), 101)) = 1 
		--OR datediff(day, Convert(VarChar, asa.DateHospitalAssigned,101),Convert(VarChar, GetDate(), 101)) = 0
	    AND asa.CLNO_Hospital<>0 
order by app.apno
End
