




















--[Integration_ClientAdjResultBatch] 6977,1,'8/27/2012 4:01:23 PM'


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Integration_ClientAdjResultBatch_USON]
	-- Add the parameters for the stored procedure here
	@CLNO int, @SPMode int, @DATEREF datetime
AS
BEGIN
SET ARITHABORT ON;
--
--RECORD TYPE - 01
--REQUEST ID
--VENDOR ID
--OVERALL ADJUDICATION

--
--RECORD TYPE - 02
--REQUEST ID
--PACKAGE CODE
--WORK ITEM CODE
--SEQUENCE NUMBER
--VENDOR IMPACT STATUS

--CODE	TEXT (FOR REFERENCE)
--10	Clear
--20	Pending Review
--30	Adverse
--40	Unknown


DECLARE @TABLE TABLE  ( RecordType varchar(2), RequestID varchar(6),PackageCode varchar(10),WorkItemCode varchar(6),
 SequenceNumber int, Status varchar(2))
DECLARE @CLIENTAPNO varchar(50),@APNO int,@RequestID varchar(6),@DATESTART datetime,@PackageCode varchar(10);

--allow 10 min of delay
SET @DATEREF =   DATEADD(mi,-10,@DATEREF);

SET @DATESTART = DATEADD(mi,-60,@DATEREF);
--push forward one hour to compensate nm time
--SET @DATEREF =   DATEADD(mi,60,@DATEREF);
--SET @DATESTART = DATEADD(mi,60,@DATESTART);

--select @DATEREF,@DATESTART

DECLARE RESULT_CURSOR CURSOR FOR
SELECT a.APNO FROM appl a (NOLOCK) where a.apstatus = 'F' and a.clno = @CLNO and 
ISNULL(clientapno,'') <> '' 
and a.compdate >= @DATESTART and a.compdate < @DATEREF
--and ((a.compdate >= @DATESTART and a.compdate < @DATEREF) or (a.apno in (1560814))) --comment this after done

--(select count(*) from reportuploadlog (NOLOCK) where reportid = a.apno and clno = @CLNO and reporttype = 3) = 0
OPEN RESULT_CURSOR;
FETCH NEXT FROM RESULT_CURSOR INTO @APNO;
WHILE @@FETCH_STATUS = 0
	BEGIN
		--------------------------------



update applclientdata set lastsyncutc = getutcdate() where apno = @apno;
-----------------------
SET @PackageCode = null;
SET @RequestID = null;
--pull meta data
SET @CLIENTAPNO = (select clientapno from appl where apno = @APNO);
SET @RequestID = (select top 1 xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(6)') FROM applclientdata
where clientapno = @CLIENTAPNO and CLNO = @CLNO);
--won't work if client updates meta
--@PackageCode = xmld.value('(/ClientMeta/Package_Code)[1]', 'varchar(6)'),
SET @PackageCode = (select packagecode from applclientdatahistory where apno = @APNO);
	
if(@SPMode = 1)
BEGIN
INSERT INTO @TABLE
( RecordType , RequestID ,PackageCode ,WorkItemCode, SequenceNumber, Status)
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPEMV' As 'SectionType',clientrefID As Sequence,clientadjudicationstatus	
		FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno
UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPEDV' As 'SectionType',clientrefID As Sequence,clientadjudicationstatus
	FROM educat  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno
UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPANS' As 'SectionType','000' As Sequence,2
	FROM applclientdatahistory  WITH (NOLOCK) WHERE apno = @apno and clientnote like '%WIPANS%'
UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPLIC' As 'SectionType',clientrefID As Sequence,clientadjudicationstatus
	FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno
UNION
--SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,4 As 'SectionType',
--	FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
--UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPSS3' As 'SectionType','000' As Sequence,clientadjudicationstatus
	FROM medinteg   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno
UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPSSN' As 'SectionType','000' As Sequence,clientadjudicationstatus
	FROM Credit   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and reptype = 'S'
UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPSOR' As 'SectionType','000' As Sequence,clientadjudicationstatus
	FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no = 2480
UNION
SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,'WIPNCR' As 'SectionType','000' As Sequence,clientadjudicationstatus
	FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no = 3519

--add criminal if count > 0
IF((select count(*) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519) > 0)
BEGIN
INSERT INTO @TABLE
( RecordType , RequestID ,PackageCode ,WorkItemCode, SequenceNumber, Status)
SELECT '02' As RecordType,@RequestID as RequestID,@PackageCode As PackageCode,'WIPCCR' As 'SectionType','000' As Sequence,
CASE WHEN ((select count(*) from crim WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519 and clientadjudicationstatus = 4) > 0 )
THEN 4
WHEN ((select count(*) from crim WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519 and clientadjudicationstatus = 3) > 0 )
THEN 3
WHEN ((select count(*) from crim WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519and clientadjudicationstatus = 2) > 0 )
THEN 2 ELSE 0 END As clientadjudicationstatus
	--FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519
END
--insert main status
--start with main cient meta data
--recordtype/requestid/vendorid/overallStatus
INSERT INTO @TABLE
( RecordType , RequestID ,PackageCode ,WorkItemCode, SequenceNumber, Status)
SELECT '01' AS RecordType,@RequestID as RequestID,@APNO AS PackageCode,Case
 WHEN ((select count(*) from @TABLE where Status = 4 AND RequestID = @RequestID) > 0) THEN '30'
WHEN ((select count(*) from @TABLE where Status = 3 AND RequestID = @RequestID) > 0) THEN '20'
WHEN ((select count(*) from @TABLE where Status = 2 AND RequestID = @RequestID) > 0) THEN '10'
ELSE '40' END AS WorkItemCode,null,null

END
		--------------------------------
		FETCH NEXT FROM RESULT_CURSOR INTO @APNO;
	END
CLOSE RESULT_CURSOR;
DEALLOCATE RESULT_CURSOR;

--CODE	TEXT (FOR REFERENCE)
--10	Clear
--20	Pending Review
--30	Adverse
--40	Unknown


--IF((select count(*) FROM @TABLE) > 0)
--BEGIN


SELECT  RecordType , RequestID,PackageCode,WorkItemCode, SequenceNumber, 
CASE When (Status = 4) Then '30'
WHEN (Status = 3) Then '20'
WHEN (Status = 2) Then '10'
WHEN (Status is null) Then null
ELSE '40' END As Status FROM @TABLE
ORDER BY RequestID,RecordType

--SELECT  RecordType , RequestID,PackageCode,WorkItemCode, SequenceNumber, 
--CASE When (Status = 4) Then '30'
--WHEN (Status = 3) Then '20'
--WHEN (Status = 2) Then '10'
--ELSE '40' END As Status FROM @TABLE

--END

END
























