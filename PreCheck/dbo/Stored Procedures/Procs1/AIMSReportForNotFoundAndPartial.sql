




CREATE procedure [dbo].[AIMSReportForNotFoundAndPartial] --'1/27/2017', '1/27/2017'
@StartDate DateTime,
@EndDate DateTime
as


DECLARE @MyCursor CURSOR
DECLARE @MyField int
DECLARE @Section varchar(50)
DECLARE @SectionKeyId varchar(50)
--DECLARE @StartDate DateTime
--DECLARE @EndDate DateTime;
--SET @StartDate = '01/25/2017'
--SET @EndDate = '01/26/2017'

DECLARE @tempTable TABLE
(
    Name varchar(40), 
    First varchar(20),
	Last varchar(20),
	LicenseType varchar(100),
	LicenseNumber varchar(30),
	IssueDate varchar(20),
	LicenseStatus varchar(20),
	ExpirationDate varchar(20),
	MultiStateStatus varchar(20),
    DisciplinaryAction varchar(max),
	NotFound varchar(20),
	Licenseid varchar(50),
	ProvidedFirst varchar(50),
	ProvidedLast varchar(50),
	ProvidedExpirationDate varchar(50),
	ProvidedLicenseNumber varchar(50),
	ResultStatus varchar(50)
)

DECLARE @tempTable1 TABLE
(
    Section varchar(50),
	[State Type] varchar(50),
    Name varchar(40), 
    First varchar(20),
	Last varchar(20),
	LicenseType varchar(100),
	LicenseNumber varchar(30),
	IssueDate varchar(20),
	LicenseStatus varchar(20),
	ExpirationDate varchar(20),
	MultiStateStatus varchar(20),
    DisciplinaryAction varchar(max),
	NotFound varchar(20),
	Licenseid varchar(50),
	ProvidedFirst varchar(50),
	ProvidedLast varchar(50),
	ProvidedExpirationDate varchar(50),
	ProvidedLicenseNumber varchar(50),
	ResultStatus varchar(50)
   
)
BEGIN
    SET @MyCursor = CURSOR FOR
    select DataXtract_LoggingId, SUBString(Section, 0, CHARINDEX('_', Section)) as Section, SectionKeyId from Precheck.dbo.DataXtract_Logging where (Section like '%_To_Be_Worked%' or Section like '%_Not_Found%') -- or Section like '%NotQualified%')

and DateLogResponse > @StartDate and DateLogResponse < DateAdd(day, 1, @EndDate)

--and DateLogResponse > '01/30/2017' and DateLogResponse <'01/31/2017' 
--and Section like 'SBM%' and SectionKeyId = 'NM-PHRM'
 


    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @MyField, @Section, @SectionKeyId
	
    WHILE @@FETCH_STATUS = 0
    BEGIN
	
	INSERT INTO @tempTable(Name, First, Last, LicenseType, LicenseNumber, IssueDate, LicenseStatus, ExpirationDate, 
	MultiStateStatus, DisciplinaryAction, NotFound, Licenseid, ProvidedFirst, ProvidedLast, ProvidedExpirationDate, ProvidedLicenseNumber, ResultStatus)
	 exec Precheck.dbo.[AIMS_TransformResponse] @MyField

	 INSERT INTO @tempTable1(Section, [State Type], Name, First, Last, LicenseType, LicenseNumber, IssueDate, LicenseStatus, ExpirationDate, 
	MultiStateStatus, DisciplinaryAction, NotFound, Licenseid, ProvidedFirst, ProvidedLast, ProvidedExpirationDate, ProvidedLicenseNumber, ResultStatus)
	Select @Section as Section, @SectionKeyId as [State Type], * From @tempTable
	Delete @tempTable
      FETCH NEXT FROM @MyCursor 
      INTO @MyField, @Section, @SectionKeyId
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
	SELECT distinct * FROM @tempTable1
	
END;