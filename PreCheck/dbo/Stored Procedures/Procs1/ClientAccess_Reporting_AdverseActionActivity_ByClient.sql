-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/24/2018
-- Description:	Requester - VU DO
-- Create new report based on existing Q-Report titled "Adverse Action Activity Report by Client." 
-- This should provide the following fields pulled by client number per date range:
-- Report number,Background request date and time,Completed background report date and time,Applicant Name,
-- Pre-Adverse Requested by (client email address),Date and time executed (refers to the action in the field below),
-- Status (pre-adverse requested, pre-adverse emailed, adverse requested, adverse emailed, etc.), Applicant email
-- EXEC ClientAccess_Reporting_AdverseActionActivity_ByClient 3115, '02/01/2018','03/01/2018'
--Modified by Radhika Dereddy on 05/25/2018 - requested by Carla to implement permission based configuration
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Reporting_AdverseActionActivity_ByClient]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@Username varchar(50),
	@StartDate Datetime,
	@EndDate Datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--commented this section on 05/25/2018 by radhika dereddy
    -- Insert statements for procedure here
	--SELECT A.APNO [ReportNumber], A.APDATE [Background Request Datetime], 
	--A.CompDate [Completed Background Report Datetime],
	--A.First + ' ' + A.Middle +  ' '+ A.Last [Applicant Name], 
	--AA.ClientEmail [Pre-Adverse RequestedBy], AH.Date [Datetime Executed], s.[Status],
	--AA.ApplicantEmail [Applicant Email] 
	--FROM precheck..AdverseAction AA 
	--INNER JOIN precheck..AdverseActionhistory AH ON AH.AdverseActionID = AA.AdverseActionID
	--INNER JOIN precheck..APPL A ON A.APNO = AA.APNO
	--INNER JOIN precheck..refAdverseStatus S ON AH.StatusID=s.refAdverseStatusID
	--WHERE (A.Clno = @CLNO) AND AH.StatusID IN (1,5,30,16,18,31) AND CAST(AH.Date AS DATE) BETWEEN @StartDate AND @EndDate
	--ORDER BY A.APNO, AH.Date


	
DECLARE @ClientUserID int
DECLARE @ConfigKey varchar(10)

SET @ClientUserID = (SELECT CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @Username)	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') ) 
   
IF(LOWER(@ConfigKey) = 'true')
		BEGIN 
			SELECT A.APNO ReportNumber, A.APDATE [Background Request Date],A.CompDate [Final Background Report Date],
			A.Last,First,AA.ClientEmail RequestedBy,AH.Date DateExecuted,s.[Status],AA.ApplicantEmail,
			AA.Address1,AA.Address2,AA.City,AA.State,AA.Zip FROM precheck..AdverseAction AA 
			INNER JOIN precheck..AdverseActionhistory AH ON AH.AdverseActionID = AA.AdverseActionID
			INNER JOIN precheck..APPL A ON A.APNO = AA.APNO
			INNER JOIN precheck..refAdverseStatus S ON AH.StatusID=s.refAdverseStatusID
			WHERE  a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
			AND AH.StatusID IN (1,5,30,16,18,31) 
			AND CAST(AH.Date AS DATE) BETWEEN @StartDate AND @EndDate
			ORDER BY A.APNO,AH.Date
		END
ELSE
		BEGIN
			SELECT A.APNO ReportNumber, A.APDATE [Background Request Date],A.CompDate [Final Background Report Date],
			A.Last,First,AA.ClientEmail RequestedBy,AH.Date DateExecuted,s.[Status],AA.ApplicantEmail,
			AA.Address1,AA.Address2,AA.City,AA.State,AA.Zip FROM precheck..AdverseAction AA 
			INNER JOIN precheck..AdverseActionhistory AH ON AH.AdverseActionID = AA.AdverseActionID
			INNER JOIN precheck..APPL A ON A.APNO = AA.APNO
			INNER JOIN precheck..refAdverseStatus S ON AH.StatusID=s.refAdverseStatusID
			WHERE  a.CLNO in (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno)
			AND AH.StatusID IN (1,5,30,16,18,31) 
			AND CAST(AH.Date AS DATE) BETWEEN @StartDate AND @EndDate
			ORDER BY A.APNO,AH.Date
		END
END
