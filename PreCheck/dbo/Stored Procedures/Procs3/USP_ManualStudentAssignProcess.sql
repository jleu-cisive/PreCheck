




CREATE  PROCEDURE [dbo].[USP_ManualStudentAssignProcess]
 @clno int = 10651  
	
AS
begin

declare @ClientCnt int,@AppCount int,@APNO int, @CLNO_Hospital int,@clientLoopcnt int


Create Table #tempClnoHospital(RowID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,CLNO_Hospital int)
Insert Into #tempClnoHospital(CLNO_Hospital)
SELECT       CLNO_Hospital
FROM            ClientSchoolHospital
WHERE        (CLNO_School = @clno) and IsActive = 1
SET @ClientCnt = @@ROWCOUNT
set @clientLoopcnt = @ClientCnt


Create Table #tempApno(AppID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,Apno int)


Insert Into #tempApno(Apno)
SELECT       APNO
FROM            Appl
WHERE        (CLNO = @clno) and ApStatus = 'F' and Apdate > '1/1/2015' and APNO not in (
SELECT       APNO
FROM            Appl
WHERE        (CLNO = @clno) and ApStatus = 'F' and Apdate > '1/1/2015'
and Apno  in (SELECT         APNO
FROM            ApplStudentAction))
order by Apdate
SET @AppCount = @@ROWCOUNT


Select @AppCount,@ClientCnt

WHILE @AppCount > 0
	begin
			 Select @APNO =APNO from #tempApno where AppID = @AppCount

			 WHILE @clientLoopcnt > 0
				begin
				 Select @CLNO_Hospital =CLNO_Hospital from #tempClnoHospital where RowID = @clientLoopcnt	

				 INSERT INTO [dbo].[ApplStudentAction]
						([APNO]	,[CLNO_Hospital],[StudentActionID],[DateHospitalAssigned],[DateStatusSet],[SSN],[LastName],[FirstName],[IsActive])
						Select @APNO,@CLNO_Hospital,0,CURRENT_TIMESTAMP,Null,Null,Null,Null,Null

--UPDATE [ApplStudentAction] SET [APNO] = @APNO, [CLNO_Hospital] = @CLNO_Hospital, [StudentActionID] = @StudentActionID, [DateHospitalAssigned] = @DateHospitalAssigned,
-- [DateStatusSet] = @DateStatusSet, [SSN] = @SSN, [LastName] = @LastName, [FirstName] = @FirstName, [IsActive] = @IsActive WHERE (([ApplStudentActionID] = @Original_ApplStudentActionID))

--SELECT     ApplStudentActionID, APNO, CLNO_Hospital, StudentActionID, DateHospitalAssigned, DateStatusSet, SSN, LastName, FirstName, IsActive
--FROM         ApplStudentAction
						SET @clientLoopcnt  = @clientLoopcnt  - 1
				End
				SET @clientLoopcnt  = @ClientCnt
	SET @AppCount  = @AppCount  - 1

End

--Select * from #tempApno
--Select * from #tempClnoHospital

drop table #tempApno
drop table #tempClnoHospital

End
