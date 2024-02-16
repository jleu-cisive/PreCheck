

--[Integration_USON_ClientReport] 6977,1,'04/14/2014'





-- =============================================

-- Author:		<Kiran miryala>

-- Create date: <2/21/2013>

-- Description:	This is used to send informatin back to client using the clientfileuploader. This is called from table clientschedule in HEVN Db

--schapyala - 10/9/2013 - modified the update to be done based on the result table and not within the loop. This way, only those apps that are spit out are updated accordingly/

-- =============================================

CREATE PROCEDURE [dbo].[Integration_USON_ClientReport_Old]

	-- Add the parameters for the stored procedure here

	@CLNO int, @SPMode int, @DATEREF datetime

AS

BEGIN

SET ARITHABORT ON;

--



--This is used only to send for APPS with an effective date of 03/01/2013



--Field						Char Type	Length	Values				Comments				

--Request ID 				alpha		10		Precheck unique ID	PreCheck will generate this # when they key in the BGC applicant information.				

--Overall Vendor Status 	alpha		4		10,20,30,40			The status that PreCheck will return on the Request. See values below.				

--Applicant First Name		alpha		30							Will be included in fax from USON.				

--Applicant Middle Name		alpha		30							Will be included in fax from USON.				

--Applicant Last Name		alpha		30							Will be included in fax from USON.				

--Applicant SSN#			numeric		11		No '-'  or  '/'		Will be included in fax from USON.				

--Applicant Birthdate		date		11		DD-MON-YYYY			Will be included in fax from USON.				

--Requestor ID				alpha		11		Usually 6 digit#	This is the Peoplesoft Employee ID for the requestor. Will be included in fax from USON.				

--Business Unit				alpha		5		e.g. HR090			Will be included in fax from USON.				

--Location Code				alpha		10		e.g AZ041, FL10		Will be included in fax from USON.				

--USON Sent Date			date		11		DD-MON-YYYY			Date the fax was sent to PreCheck.				

--Vendor Entry Date			date		11		DD-MON-YYYY			Date the Request was entered into PreCheck.				

--Vendor Close Date			date		11		DD-MON-YYYY			Date the Request was closed.				

-- PackageID				alpha		6						    3 digit Codes from Precheck




--CODE	TEXT (FOR REFERENCE)

--10	Clear			Final status when item is actually clear from PreCheck. This will result in Automatic Closure in Peoplesoft.		

--20	Pending Review	If item cannot be verified by PreCheck or item has been Pending for an extended amount of time.		

--30	In Progress		When PreCheck has started working on the request. 		

--40	Sent (Acknowledgement)			When PreCheck first enters the request into their system and we get back the information. This is the initial status.		

--50    UNKNOWN



--Data Points from applclientdata

--Requestor ID		ClientData1

--Business Unit		ClientData2

--Location Code		ClientData3



DECLARE @ResultTABLE TABLE  ([Request ID] varchar(10),[Overall Vendor Status] varchar(4),[Applicant First Name] varchar(30), [Applicant Middle Name] varchar(30),[Applicant Last Name] varchar(30),

[Applicant SSN#] varchar(11),[Applicant Birthdate] char(11),[Requestor ID] varchar(11),[Business Unit] varchar(5),[Location Code] varchar(10),

[USON Sent Date	] char(11),[Vendor Entry Date] char(11),[Vendor Close Date] char(11),[PackageID] varchar(6))









DECLARE @TABLE TABLE  ( RecordType varchar(2), RequestID varchar(10), Status varchar(2))

--DECLARE @CLIENTAPNO varchar(50),@RequestID varchar(6),@DATESTART datetime,@PackageCode varchar(10);

DECLARE @EffectiveDate DateTime,@APNO int



Set @EffectiveDate = '03/18/2013'



--allow 10 min of delay

--SET @DATEREF =   DATEADD(mi,-10,@DATEREF);



--SET @DATESTART = DATEADD(mi,-60,@DATEREF);

--push forward one hour to compensate nm time

--SET @DATEREF =   DATEADD(mi,60,@DATEREF);

--SET @DATESTART = DATEADD(mi,60,@DATESTART);



--select @DATEREF,@DATESTART



DECLARE RESULT_CURSOR CURSOR FOR

SELECT a.APNO FROM appl a (NOLOCK) inner join applclientdata CD on a.APNO = CD.apno 

where a.apstatus = 'F' and a.clno = @CLNO and ApDate >= @EffectiveDate and lastsyncutc is null and DateAcknowledged is not null

--and a.compdate >= @DATESTART and a.compdate < @DATEREF

--and ( a.apno in (2111373,2107349)) --comment this after done



--(select count(*) from reportuploadlog (NOLOCK) where reportid = a.apno and clno = @CLNO and reporttype = 3) = 0

OPEN RESULT_CURSOR;

FETCH NEXT FROM RESULT_CURSOR INTO @APNO;

WHILE @@FETCH_STATUS = 0

	BEGIN

		--------------------------------



--set @apno = 2106458



--update applclientdata set lastsyncutc = getutcdate() where apno = @apno;



	

if(@SPMode = 1)

BEGIN

INSERT INTO @TABLE

( RecordType , RequestID , Status)

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus	

		FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno

UNION

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus

	FROM educat  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno

--UNION

--SELECT '02' As RecordType,@apno as ReequestID,@PackageCode As PackageCode,'WIPANS' As 'SectionType','000' As Sequence,2

--	FROM applclientdatahistory  WITH (NOLOCK) WHERE apno = @apno and clientnote like '%WIPANS%'

UNION

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus

	FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno

UNION

--SELECT '02' As RecordType,@RequestID as ReequestID,@PackageCode As PackageCode,4 As 'SectionType',

--	FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'

--UNION

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus

	FROM medinteg   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno

UNION

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus

	FROM Credit   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and reptype = 'S'

UNION

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus

	FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no = 2480

UNION

SELECT '02' As RecordType,@apno as ReequestID,clientadjudicationstatus

	FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no = 3519





--add criminal if count > 0

IF((select count(*) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519) > 0)

BEGIN

INSERT INTO @TABLE

( RecordType , RequestID , Status)

SELECT '02' As RecordType,@apno as RequestID,

CASE WHEN ((select count(*) from crim WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519 and clientadjudicationstatus = 4) > 0 )

THEN 4

WHEN ((select count(*) from crim WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519 and clientadjudicationstatus = 3) > 0 )

THEN 3

WHEN ((select count(*) from crim WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519and clientadjudicationstatus = 2) > 0 )

THEN 2 ELSE 0 END As clientadjudicationstatus

	--FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480 and cnty_no <> 3519

END



--Select RecordType , RequestID , Status from @TABLE



INSERT INTO @ResultTABLE 

([Request ID] ,[Overall Vendor Status],[Applicant First Name] , [Applicant Middle Name] ,[Applicant Last Name] ,

[Applicant SSN#] ,[Applicant Birthdate] ,[Requestor ID] ,[Business Unit] ,[Location Code],

[USON Sent Date	] ,[Vendor Entry Date] ,[Vendor Close Date] ,[PackageID] )

Select cast(a.Apno as varchar),

Case

  WHEN ((select count(*) from @TABLE where Status = 4 AND RequestID = @apno) > 0) THEN '30' 

WHEN ((select count(*) from @TABLE where Status = 3 AND RequestID = @apno) > 0) THEN '20'

WHEN ((select count(*) from @TABLE where Status = 2 AND RequestID = @apno) > 0) THEN '10' ELSE '50'  End  ,

a.First ,a.Middle ,a.Last ,replace(a.SSN,'-','')  ,

cast(REPLACE(CONVERT(VARCHAR,A.DOB,106),' ','-') as char), CONVERT(varchar, R.ClientData1) ,CONVERT(varchar, R.ClientData2) ,CONVERT(varchar, R.ClientData3)

,cast(REPLACE(CONVERT(VARCHAR,a.ApDate,106),' ','-') as char)  ,cast(REPLACE(CONVERT(VARCHAR,a.ApDate,106),' ','-') as char) ,

cast(REPLACE(CONVERT(VARCHAR,a.CompDate,106),' ','-') as char)  ,cast(a.PackageID as varchar)

 from Appl a  inner join

(SELECT APNO, NewTable.RequestXML.query('data(ClientData1)') AS ClientData1,NewTable.RequestXML.query('data(ClientData2)') AS ClientData2, NewTable.RequestXML.query('data(ClientData3)') AS  ClientData3

FROM applclientdata CROSS APPLY XMLD.nodes('//CustomClientData') AS NewTable(RequestXML)) R on a.apno =R.apno



Where a.APNO = @apno 



End

		--------------------------------

		FETCH NEXT FROM RESULT_CURSOR INTO @APNO;

	END

CLOSE RESULT_CURSOR;

DEALLOCATE RESULT_CURSOR;



--This block is used to send 40 status (ACKNOWLEDGEMENT EMAIL)



DECLARE @XMLD XML,@msg nvarchar(400),@SSN varchar(11),@DOB Datetime, @PackageID int 

DECLARE RESULT_CURSOR CURSOR FOR

--SELECT a.APNO FROM dbo.applclientdata a (NOLOCK) where updated >= @EffectiveDate and DateAcknowledged is null and a.clno = @CLNO 


SELECT a.APNO,XMLD,rtrim(ltrim(a.SSN)) SSN,a.DOB,a.PackageID FROM dbo.Appl a (NOLOCK) left join dbo.applclientdata acd (NOLOCK) on a.apno = acd.apno
 where apdate >= @EffectiveDate and DateAcknowledged is null and a.clno = @CLNO 
 



--(select count(*) from reportuploadlog (NOLOCK) where reportid = a.apno and clno = @CLNO and reporttype = 3) = 0

OPEN RESULT_CURSOR;

FETCH NEXT FROM RESULT_CURSOR INTO @APNO,@XMLD,@SSN,@DOB,@PackageID;

WHILE @@FETCH_STATUS = 0

	BEGIN

		--IF @XMLD IS NOT NULL --If ClientData is available
		--IF (SELECT  count(1)  FROM applclientdata (nolock) Where APNO = @apno and XMLD.value('(//CustomClientData/ClientData1/node())[1]', 'VARCHAR(100)') is  not null) > 0
		--Select @XMLD
		IF  (@XMLD.value('(//CustomClientData/ClientData1/node())[1]', 'VARCHAR(100)') IS NOT NULL) AND (ISNULL(@SSN,'')<>'') AND (ISNULL(@DOB,'')<>'') and (@PackageID IS NOT NULL)-- do not send without SSN And DOB as per client - 05062013
			BEGIN

				--update dbo.applclientdata set DateAcknowledged = Current_timeStamp where apno = @apno;
				BEGIN TRY
					INSERT INTO @ResultTABLE 

					([Request ID] ,[Overall Vendor Status],[Applicant First Name] , [Applicant Middle Name] ,[Applicant Last Name] ,

					[Applicant SSN#] ,[Applicant Birthdate] ,[Requestor ID] ,[Business Unit] ,[Location Code],

					[USON Sent Date	] ,[Vendor Entry Date] ,[Vendor Close Date] ,[PackageID] )

					Select cast(a.Apno as varchar),

					'40'  ,a.First ,a.Middle ,a.Last ,replace(a.SSN,'-','')  ,

					cast(REPLACE(CONVERT(VARCHAR,A.DOB,106),' ','-') as char), CONVERT(varchar, R.ClientData1) ,CONVERT(varchar, R.ClientData2) ,CONVERT(varchar, R.ClientData3)

					,cast(REPLACE(CONVERT(VARCHAR,a.ApDate,106),' ','-') as char)  ,cast(REPLACE(CONVERT(VARCHAR,a.ApDate,106),' ','-') as char) ,

					null, --a.CompDate 

					cast(a.PackageID as varchar)

					 from Appl a  inner join

					(SELECT APNO, NewTable.RequestXML.query('data(ClientData1)') AS ClientData1,NewTable.RequestXML.query('data(ClientData2)') AS ClientData2, NewTable.RequestXML.query('data(ClientData3)') AS  ClientData3

					FROM applclientdata CROSS APPLY XMLD.nodes('//CustomClientData') AS NewTable(RequestXML)) R on a.apno =R.apno

					Where a.APNO = @apno 
				END TRY
				BEGIN CATCH
					set @msg = 'This is to inform you that the US Oncology Report# ' + cast(@apno as nvarchar)+ ' entered, has Bad/Incorrect Data. ' + char(9) + char(13)+ char(9) + char(13)

					set @msg = @msg + ' Requestor ID (11 characters max - usually 6 characters): ' + @XMLD.value('(//CustomClientData/ClientData1/node())[1]', 'VARCHAR(100)') + char(9) + char(13)

					set @msg = @msg + ' Business Unit ( 5 characters max - usually 5 characters): ' + @XMLD.value('(//CustomClientData/ClientData2/node())[1]', 'VARCHAR(100)') + char(9) + char(13)

					set @msg = @msg + ' Location Code (10 characters max - usually 2 characters): ' + @XMLD.value('(//CustomClientData/ClientData3/node())[1]', 'VARCHAR(100)') + char(9) + char(13) + char(9) + char(13)

					set @msg = @msg + ' Please update the report with the corrected information for the system to send the data file to the client. ' 

					EXEC msdb.dbo.sp_send_dbmail   @from_address = 'USON Custom Data Capture <DoNotReply@PreCheck.com>',@subject=N'US Oncology Data Error Notification', @recipients=N'santoshchapyala@Precheck.com;Jeandriskahawkins@precheck.com;MiaMallory@precheck.com',    @body=@msg ;
					
				END CATCH
			END
		ELSE --If ClientData is not available, warn the AI/CAM group
			BEGIN
				set @msg = 'This is to inform you that the US Oncology Report# ' + cast(@apno as nvarchar)+ ' entered, has missing Data. ' + char(9) + char(13)+ char(9) + char(13)

				IF @XMLD.value('(//CustomClientData/ClientData1/node())[1]', 'VARCHAR(100)') IS  NULL
					set @msg = @msg + ' Client Data is missing. ' + char(9) + char(13)

				IF (ISNULL(@SSN,'') = '') 
					set @msg = @msg + ' SSN is missing. ' + char(9) + char(13)

				IF ( ISNULL(@DOB,'') = '')
					set @msg = @msg + ' DOB is missing. ' + char(9) + char(13)

				IF (@PackageID IS  NULL)
					set @msg = @msg + ' Package is missing. ' + char(9) + char(13)+ char(9) + char(13)

					set @msg = @msg + ' Please update the report with the missing information for the system to send the data file to the client. ' 

				EXEC msdb.dbo.sp_send_dbmail   @from_address = 'USON Custom Data Capture <DoNotReply@PreCheck.com>',@subject=N'US Oncology Data Error Notification', @recipients=N'santoshchapyala@Precheck.com;Jeandriskahawkins@precheck.com;MiaMallory@precheck.com',    @body=@msg ;
			END

	--------------------------------
		FETCH NEXT FROM RESULT_CURSOR INTO @APNO,@XMLD,@SSN,@DOB,@PackageID;

	END

CLOSE RESULT_CURSOR;

DEALLOCATE RESULT_CURSOR;

----Update Completed Status
----update applclientdata set lastsyncutc = getutcdate() where apno = @apno;
--update A set lastsyncutc = getutcdate() 
--From dbo.applclientdata A inner Join @ResultTABLE R ON cast(A.Apno as varchar) = [Request ID]
--Where [Overall Vendor Status] <> '40'

--------Update acknowledgements
--update A set DateAcknowledged = Current_timeStamp 
--From dbo.applclientdata A inner Join @ResultTABLE R ON cast(A.Apno as varchar) = [Request ID]
--Where [Overall Vendor Status] = '40'

select [Request ID] ,[Overall Vendor Status],[Applicant First Name] , [Applicant Middle Name] ,[Applicant Last Name] ,

		[Applicant SSN#] ,[Applicant Birthdate] ,[Requestor ID] ,[Business Unit] ,[Location Code],

		[USON Sent Date	] ,[Vendor Entry Date] ,[Vendor Close Date] ,[PackageID]

		from @ResultTABLE


End
















































