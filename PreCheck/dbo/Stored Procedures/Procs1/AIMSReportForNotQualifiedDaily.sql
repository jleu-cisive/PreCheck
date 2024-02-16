




CREATE procedure [dbo].[AIMSReportForNotQualifiedDaily] 

as
DECLARE @MyCursor CURSOR;
DECLARE @MyField int;
DECLARE @Section varchar(50);

DECLARE @tempTable TABLE
(
    Licenseid varchar(50),
	Employerid varchar(20),
    EmployerName varchar(100),  
    First varchar(20),  
    Last varchar(20),  
    Type varchar(100),
    number varchar(30),
    IssuingState varchar(20),
	Expiresdate varchar(20),
	DOB varchar(20),
	SSN varchar(max)
   
)

DECLARE @tempTable1 TABLE
(
    Section varchar(50),
	Licenseid varchar(50),
	Employerid varchar(20),
    EmployerName varchar(100),  
    First varchar(20),  
    Last varchar(20),  
    Type varchar(100),
    number varchar(30),
    IssuingState varchar(20),
	Expiresdate varchar(20),
	DOB varchar(20),
	SSN varchar(max)
   
)
BEGIN
    SET @MyCursor = CURSOR FOR
    select DataXtract_LoggingId,  SUBString(Section, 0, CHARINDEX('_', Section)) as Section from Precheck.dbo.DataXtract_Logging where (Section like '%NotQualified%')

and DateLogRequest >CONVERT(date, getdate()) and DateLogRequest <CONVERT(date, getdate() + 1)
 

    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @MyField, @Section
	
    WHILE @@FETCH_STATUS = 0
    BEGIN
	
	INSERT INTO @tempTable(
	Licenseid,
	Employerid,
    EmployerName,  
    First,  
    Last,  
    Type,
    number,
    IssuingState,
	Expiresdate,
	DOB,
	SSN)
	 exec Precheck.dbo.[AIMS_TransformRequest]  @MyField
    INSERT INTO @tempTable1(Section,Licenseid,
	Employerid,
    EmployerName,  
    First,  
    Last,  
    Type,
    number,
    IssuingState,
	Expiresdate,
	DOB,
	SSN)
	Select @Section as Section, * From @tempTable
	Delete @tempTable
      FETCH NEXT FROM @MyCursor 
      INTO @MyField, @Section
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
	SELECT * FROM @tempTable1
	
END;

