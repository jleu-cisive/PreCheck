

--[Integration_USON_ClientReport] 6977,1,'08/18/2014 11:30'





-- =============================================

-- Author:		<Kiran miryala>

-- Create date: <2/21/2013>

-- Description:	This is used to send informatin back to client using the clientfileuploader. This is called from table clientschedule in HEVN Db

--schapyala - 10/9/2013 - modified the update to be done based on the result table and not within the loop. This way, only those apps that are spit out are updated accordingly/

-- =============================================

CREATE PROCEDURE [dbo].[Integration_USON_ClientReport]

	-- Add the parameters for the stored procedure here

	@CLNO int, @SPMode int, @DATEREF datetime

AS

BEGIN

SET ARITHABORT ON;

--*



--This is used only to send for APPS with an effective date of 03/01/2013



--Field						Char Type	Length	Values				Comments				

--Request ID 				alpha		11		Precheck unique ID	PreCheck will generate this # when they key in the BGC applicant information.				

--Overall Vendor Status 	alpha		50		10,20,30,40			The status that PreCheck will return on the Request. See values below.				

--Applicant First Name		alpha		30							Will be included in fax from USON.				

--Applicant Middle Name		alpha		30							Will be included in fax from USON.				

--Applicant Last Name		alpha		30							Will be included in fax from USON.				

--Applicant SSN#			numeric		11		No '-'  or  '/'		Will be included in fax from USON.				

--Applicant Birthdate		date		11		YYYY-MM-DD			Will be included in fax from USON.				

--Requestor ID				alpha		11		Usually 6 digit#	This is the Peoplesoft Employee ID for the requestor. Will be included in fax from USON.				

--Position ID				alpha		7		e.g. P234567		Will be included in fax from USON.	

--Applicant Email Address   alphanum	100							Will be included in fax from USON.		

--Applicant Phone			numeric		12      123-456-7890	    Will be included in fax from USON.										

--Overall Status Date 		date		11		YYYY-MM-DD			Last Status and Corresponding Date				

-- PackageID				alpha		6						    3 digit Codes from Precheck



--Overall Status 	ALPHA 50		
--In Progress with Vendor 	Pending	The BGC request packet has been received by PreCheck, entered into their database and work has begun. The data feed contains initial load to Workday. 
--							This triggers the Notification of Submission email to the Requestor with copy to BGC Team.
	
--Provisional Clear		    Pending	Sanction screenings passed, OIG Criminal passed, licensure passed, pending education and employment	--Currently Not supported - Smart status

--Needs Review 				Pending	PreCheck has done as much work as possible on the request and is sending back to MSH for further "work" and may contain discrepancies or possible adverse action. 
--							The data feed does NOT close the request in Workday. The BGC Team handles discrepancies and adverse actions as appropriate using processes currently in place.	

--Clear						Passed	All items have been cleared by PreCheck or BCG Team has cleared the request manually, Individual is cleared to work.  
--							Notification of Closure email will be sent to the Requestor with copy to BGC team. No further work required. 	




--Data Points from applclientdata

--Requestor ID		ClientData1

--Position ID		ClientData2



DECLARE @ResultTABLE TABLE  ([Request ID] varchar(11),[Overall Vendor Status] varchar(50),[Applicant First Name] varchar(30), [Applicant Middle Name] varchar(30),[Applicant Last Name] varchar(30),

[Applicant SSN#] varchar(11),[Applicant Birthdate] char(10),[Requestor ID] varchar(11),[Position ID] varchar(7), [Applicant Email Address] varchar(100),[Applicant Phone] varchar(20),

[Overall Status Date] char(10),[PackageID] varchar(6))









DECLARE @TABLE TABLE  ( RecordType varchar(2), RequestID varchar(10), Status varchar(2))

--DECLARE @CLIENTAPNO varchar(50),@RequestID varchar(6),@DATESTART datetime,@PackageCode varchar(10);

DECLARE @EffectiveDate DateTime,@APNO int,@msg nvarchar(600)



Set @EffectiveDate = '05/13/2014'



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


--and ( a.apno in (2242836,
--2299911,
--2501038,
--2501388

--)) --comment this after done



OPEN RESULT_CURSOR;

FETCH NEXT FROM RESULT_CURSOR INTO @APNO;

WHILE @@FETCH_STATUS = 0

	BEGIN


	

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

	BEGIN TRY

		INSERT INTO @ResultTABLE 

		([Request ID] ,[Overall Vendor Status],[Applicant First Name] , [Applicant Middle Name] ,[Applicant Last Name] ,

		[Applicant SSN#] ,[Applicant Birthdate] ,[Requestor ID] ,[Position ID] , [Applicant Email Address] ,[Applicant Phone] ,

		[Overall Status Date] ,[PackageID] )

		Select cast(a.Apno as varchar),

		Case

		  WHEN ((select count(*) from @TABLE where Status = 4 AND RequestID = @apno) > 0) THEN 'Needs Review' --check again

		WHEN ((select count(*) from @TABLE where Status = 3 AND RequestID = @apno) > 0) THEN 'Needs Review'

		WHEN ((select count(*) from @TABLE where Status = 2 AND RequestID = @apno) > 0) THEN 'Clear' ELSE 'Needs Review. '  End  ,

		a.First ,a.Middle ,a.Last ,replace(a.SSN,'-','')  ,

		cast(REPLACE(CONVERT(VARCHAR,A.DOB,102),'.','-') as char), CONVERT(varchar, R.ClientData1) ,left(CONVERT(varchar, R.ClientData2),7) , a.Email, a.phone,

		cast(REPLACE(CONVERT(VARCHAR,a.CompDate,102),'.','-') as char)  ,cast(a.PackageID as varchar)

		 from DBO.Appl a  inner join

		(SELECT APNO, NewTable.RequestXML.query('data(ClientData1)') AS ClientData1,NewTable.RequestXML.query('data(ClientData2)') AS ClientData2

		FROM applclientdata CROSS APPLY XMLD.nodes('//CustomClientData') AS NewTable(RequestXML)) R on a.apno =R.apno

		Where a.APNO = @apno 
	END TRY
	BEGIN CATCH
		set @msg = 'This is to inform you that the US Oncology Report# ' + cast(@apno as nvarchar)+ ' entered, has Bad/Incorrect Data. ' 

		set @msg = @msg + ' Please update the report with the corrected information for the system to send the data file to the client. ' 

		EXEC msdb.dbo.sp_send_dbmail   @from_address = 'USON Custom Data Capture <DoNotReply@PreCheck.com>',@subject=N'US Oncology Data Error Notification', @recipients=N'santoshchapyala@Precheck.com;DataEntry@PRECHECK.com;JenniferPrather@precheck.com',    @body=@msg ;
		
		Delete 	@ResultTABLE Where 	[Request ID]  = @apno	
	END CATCH


End

		--------------------------------

		FETCH NEXT FROM RESULT_CURSOR INTO @APNO;

	END

CLOSE RESULT_CURSOR;

DEALLOCATE RESULT_CURSOR;



--This block is used to send 40 status (ACKNOWLEDGEMENT EMAIL) - status sent as In Progress with Vendor 



DECLARE @XMLD XML,@SSN varchar(11),@DOB Datetime, @PackageID int,@Email varchar(100), @Phone varchar(20)

DECLARE RESULT_CURSOR CURSOR FOR


SELECT a.APNO,XMLD,rtrim(ltrim(a.SSN)) SSN,a.DOB,a.PackageID,Email,Phone FROM dbo.Appl a (NOLOCK) left join dbo.applclientdata acd (NOLOCK) on a.apno = acd.apno
 where apdate >= @EffectiveDate and DateAcknowledged is null and a.clno = @CLNO 
 --and a.apno in (0)


OPEN RESULT_CURSOR;

FETCH NEXT FROM RESULT_CURSOR INTO @APNO,@XMLD,@SSN,@DOB,@PackageID,@Email,@Phone;

WHILE @@FETCH_STATUS = 0

	BEGIN


		IF  (@XMLD.value('(//CustomClientData/ClientData1/node())[1]', 'VARCHAR(100)') IS NOT NULL) AND (ISNULL(@SSN,'')<>'') AND (ISNULL(@DOB,'')<>'')  and (@PackageID IS NOT NULL) AND ((ISNULL(@Email,'')<>'') OR (ISNULL(@Phone,'')<>''))-- do not send without SSN And DOB as per client - 05062013
			BEGIN

				--update dbo.applclientdata set DateAcknowledged = Current_timeStamp where apno = @apno;
				BEGIN TRY
					INSERT INTO @ResultTABLE 

					([Request ID] ,[Overall Vendor Status],[Applicant First Name] , [Applicant Middle Name] ,[Applicant Last Name] ,

					[Applicant SSN#] ,[Applicant Birthdate] ,[Requestor ID] ,[Position ID] , [Applicant Email Address] ,[Applicant Phone] ,

					[Overall Status Date] ,[PackageID] )

					Select cast(a.Apno as varchar),

					'In Progress with Vendor'  ,a.First ,a.Middle ,a.Last ,replace(a.SSN,'-','')  ,

					cast(REPLACE(CONVERT(VARCHAR,A.DOB,102),'.','-') as char), CONVERT(varchar, R.ClientData1) ,left(CONVERT(varchar, R.ClientData2),7) ,a.EMail, a.phone

					,cast(REPLACE(CONVERT(VARCHAR,Current_Timestamp,102),'.','-') as char) ,

					cast(a.PackageID as varchar)

					 from DBO.Appl a  inner join

					(SELECT APNO, NewTable.RequestXML.query('data(ClientData1)') AS ClientData1,NewTable.RequestXML.query('data(ClientData2)') AS ClientData2

					FROM applclientdata CROSS APPLY XMLD.nodes('//CustomClientData') AS NewTable(RequestXML)) R on a.apno =R.apno

					Where a.APNO = @apno 
				END TRY
				BEGIN CATCH
					set @msg = 'This is to inform you that the US Oncology Report# ' + cast(@apno as nvarchar)+ ' entered, has Bad/Incorrect Data. ' + char(9) + char(13)+ char(9) + char(13)

					set @msg = @msg + ' Requestor ID (11 characters max - usually 6 characters): ' + @XMLD.value('(//CustomClientData/ClientData1/node())[1]', 'VARCHAR(100)') + char(9) + char(13)

					set @msg = @msg + ' Position ID ( 7 characters max - usually 7 characters): ' + @XMLD.value('(//CustomClientData/ClientData2/node())[1]', 'VARCHAR(100)') + char(9) + char(13)

					set @msg = @msg + ' Location Code (20 characters max - usually ? characters): ' + @XMLD.value('(//CustomClientData/ClientData3/node())[1]', 'VARCHAR(100)') + char(9) + char(13) + char(9) + char(13)

					set @msg = @msg + ' Please update the report with the corrected information for the system to send the data file to the client. ' 

					EXEC msdb.dbo.sp_send_dbmail   @from_address = 'USON Custom Data Capture <DoNotReply@PreCheck.com>',@subject=N'US Oncology Data Error Notification', @recipients=N'santoshchapyala@Precheck.com;DataEntry@PRECHECK.com;JenniferPrather@precheck.com',    @body=@msg ;
					
					Delete 	@ResultTABLE Where 	[Request ID]  = @apno
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
					set @msg = @msg + ' Package is missing. ' + char(9) + char(13)

				IF (ISNULL(@Email,'')='' AND ISNULL(@Phone,'')='')
					set @msg = @msg + ' Candidate contact info is missing ' + char(9) + char(13)+ char(9) + char(13)

					set @msg = @msg + ' Please update the report with the missing information for the system to send the data file to the client. ' 

				EXEC msdb.dbo.sp_send_dbmail   @from_address = 'USON Custom Data Capture <DoNotReply@PreCheck.com>',@subject=N'US Oncology Data Error Notification', @recipients=N'santoshchapyala@Precheck.com;DataEntry@PRECHECK.com;JenniferPrather@precheck.com',    @body=@msg ;
			END

	--------------------------------
		FETCH NEXT FROM RESULT_CURSOR INTO @APNO,@XMLD,@SSN,@DOB,@PackageID,@Email,@Phone;

	END

CLOSE RESULT_CURSOR;

DEALLOCATE RESULT_CURSOR;

--uncomment the below updates

----Update Completed Status
--Print 'update completed status'
update A set lastsyncutc = getutcdate() 
From dbo.applclientdata A inner Join @ResultTABLE R ON cast(A.Apno as varchar) = [Request ID]
Where [Overall Vendor Status] <> 'In Progress with Vendor'

----Update acknowledgements
--Print 'update acknowledgements'
update A set DateAcknowledged = Current_timeStamp 
From dbo.applclientdata A inner Join @ResultTABLE R ON cast(A.Apno as varchar) = [Request ID]
Where [Overall Vendor Status] = 'In Progress with Vendor'

select [Request ID] ,[Overall Vendor Status],[Applicant First Name] , [Applicant Middle Name] ,[Applicant Last Name] ,

		[Applicant SSN#] ,[Applicant Birthdate] ,[Requestor ID] ,[Position ID] , [Applicant Email Address] , left([Applicant Phone],12) [Applicant Phone],

		[Overall Status Date] ,[PackageID]

		from @ResultTABLE


End
















































