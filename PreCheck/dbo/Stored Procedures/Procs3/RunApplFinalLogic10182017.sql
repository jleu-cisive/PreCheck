




-- =============================================
-- Author:		<Bhavana Bakshi>
-- Create date: <04/25/2008>
-- Description:	<To update applicaton's flag status from OASIS when the application in finaled>
--  Flag  Description
--  1      Clear
--  2      Needs Review
-- =============================================
-- =============================================
--
-- Edit By:-	Kiran Miryala	
-- Edit Date :- 02/02/2009
-- Description:- To update FreeReport table for Client US Oncology(6977) that a free report need to be sent 
--					to the applicant if they currently live in any of below states
--					CA, OK, NY, MN
--				07-27-2010
--					To update FreeReport table for applicants who marked  that a free report need to be sent 
--					
--
--===================================================
-- Edit By:-	Kiran Miryala	
-- Edit Date :- 1/4/2011
-- Description:-  updated "sectstat NOT IN ('3','4','5')" from sectstat NOT IN ('3','5')
--					
--
--===================================================
--===================================================
-- Edit By:-	Kiran Miryala	
-- Edit Date :- 6/20/2013
-- Description:-  updated "max(isnull(clientadjudicationstatus,0))
--					
--
--===================================================

Create PROCEDURE [dbo].[RunApplFinalLogic10182017]
	@apno int
AS
BEGIN
	SET NOCOUNT OFF;

DECLARE @ApStatus char(1),@Flag int,@CLNO int,@adjreview varchar(50),@tmpFlag int,@ReopenDate date;
Declare @cnt int
Declare @AAID int

--SET @CLNO = (select clno from appl where apno = @apno);
SET @adjreview = (select value from clientconfiguration where configurationkey = 'AdjudicationProcess' and clno = @CLNO);

select @CLNO = clno,@ReopenDate = ReopenDate  from appl where apno = @apno




--SET @apno =  @apno
SELECT @ApStatus = Apstatus FROM appl WHERE apno = @apno

--1-CLEAR
--2-NEEDS REVIEW
--3-ADVERSE
set @Flag = 1;--DEFAULT
set @tmpFlag = 0;--default
IF( @ApStatus = 'F')
BEGIN


IF (@adjreview = 'True')
BEGIN
--------ADJREVIEW-----------------------------------
SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno)
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag	
	
SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM educat  WITH (NOLOCK)WHERE isonreport = 1 and ishidden = 0 and apno = @apno)
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno)
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno)
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM medinteg  WITH (NOLOCK )WHERE ishidden = 0 and apno = @apno)
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM dl  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno)
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag =(SELECT max(isnull(clientadjudicationstatus,0)) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno)
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag

SET @tmpFlag = (SELECT max(isnull(clientadjudicationstatus,0)) FROM credit WITH (NOLOCK )WHERE ishidden = 0 and apno = @apno)
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag

--USONC client adjudication mapping
IF (@Flag = 4)
		set @Flag = 4--adverse
else IF (@Flag = 3)
		set @Flag = 3--pending review
else IF (@Flag = 2)
		set @Flag = 1--clear
else IF (@Flag = 1)
		set @Flag = 0--pending review should not happen

END
ELSE
---------STANDARD--------------------------------
BEGIN
	IF(SELECT count(apno) FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','4','5')) >0
	BEGIN
		set @Flag =  2 --Needs review
	END
	
	IF(SELECT count(apno) FROM educat  WITH (NOLOCK)WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','4','5')) >0
	BEGIN
		set @Flag =  2
	END
	
	IF(SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','4','5')) >0 
	BEGIN
		set @Flag =  2
	END 
	
	IF(SELECT count(apno) FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','4','5')) >0 
	BEGIN
		set @Flag =  2
	END
	
	IF(SELECT count(apno) FROM medinteg  WITH (NOLOCK )WHERE ishidden = 0 and apno = @apno AND sectstat NOT IN ('1','2', '3') )>0
	BEGIN
		set @Flag =  2
	END 
	
	IF(SELECT count(apno) FROM dl  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','4','5')) >0 
	BEGIN
		set @Flag = 2
	END
	
	IF (SELECT count(apno) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno AND clear  <> 'T')>0
	BEGIN
		set @Flag =  2
	END
END
-----------------------------







--UPDATE/MERGE
IF(SELECT COUNT(APNO) FROM ApplFlagStatus  WHERE APNO = @apno) = 0
	BEGIN
		INSERT INTO ApplFlagStatus(APNO,FlagStatus,LastUpdatedUTC) 
		VALUES (@apno,@Flag,getutcdate())
	END
ELSE
	BEGIN
	   UPDATE ApplFlagStatus SET FlagStatus = @Flag,LastUpdatedUTC = getutcdate() WHERE APNO=@apno
	END
END




IF( @ApStatus = 'F')
BEGIN	
SELECT @cnt = count(*) FROM FreeReport WHERE Apno =  @Apno
	IF @cnt=0
		
		BEGIN
			declare @FreeReport bit
			SELECT @FreeReport = ISnull(Freereport,0) FROM Appl WHERE Apno =  @Apno

			
			if @FreeReport = 1
				BEGIN
					Insert into FreeReport(APNO,CLNO,StatusID,FreeReportLetterReturnID,[2ndLetterReturnID],Name,Address1,City,State,Zip,ApplicantEmail) 
					 SELECT a.APNO, a.CLNO, 24,0,0
						,a.[First] + ' ' + isnull(a.Middle,'')+ ' ' + isnull(a.[Last],'') as [Name]
						,LTRIM(RTRIM(isnull(a.Addr_Num,'') + ' ' + isnull(a.Addr_Apt,'') + ' ' + isnull(a.Addr_Dir,'') + ' ' + a.Addr_Street  + ' ' +  isnull(Addr_StType,'')))  as Address1
						,a.City 
						,a.State 
						,a.Zip,Email
						FROM Appl a 
						WHERE 
						a.apno =  @Apno 
--						and 
--						a.clno = 6977
--						and 
--						(a.State = 'CA' or a.State = 'OK' or a.State = 'NY' or a.State = 'MN')
				
				END

			Else
				-- for US Oncology
				BEGIN
					Insert into FreeReport(APNO,CLNO,StatusID,FreeReportLetterReturnID,[2ndLetterReturnID],Name,Address1,City,State,Zip,ApplicantEmail) 
					 SELECT a.APNO, a.CLNO, 24,0,0
						,a.[First] + ' ' + isnull(a.Middle,'')+ ' ' + isnull(a.[Last],'') as [Name]
						,isnull(a.Addr_Num,'') + ' ' + isnull(a.Addr_Apt,'') + ' ' + isnull(a.Addr_Dir,'') + ' ' + a.Addr_Street  + ' ' +  isnull(Addr_StType,'')  as Address1
						,a.City 
						,a.State 
						,a.Zip,Email
						FROM Appl a 
						WHERE 
						a.apno =  @Apno 
						and
						a.clno = 6977
						and 
						(a.State = 'CA' or a.State = 'OK' or a.State = 'NY' or a.State = 'MN')
					
				END

		SELECT @AAID = FreeReportID FROM FreeReport WHERE Apno =  @Apno
		Insert into AdverseActionHistory (AdverseActionID,StatusID,UserID,[Date],ReportID)
		values (@AAID,24,'system',getdate(),0)
						
			
		END


END
--Checks to see if an integration client needs a callback when app is finaled and marks it accordingly for winservice to callback with the link to the report
--KMiryala 11/11/2010
--if ((SELECT  isnull(URL_CallBack_Final,'') FROM ClientConfig_Integration where  CLNO  = @CLNO) <> '')
	

			update DBO.Integration_OrderMgmt_Request
			set   Process_Callback_Final = 1,
				  Callback_Final_Date = null
			where apno =  @Apno 

if (@clno in(10444,3115))
	BEGIN
		if ( @ReopenDate is null)
		begin
			--added by santosh for callbacks to Direct (1 step) integrations (TMHS, HRSOFT etc.)
			update [dbo].[Integration_PrecheckCallback]
			set   Process_Callback_Final = 1,
				  Callback_Final_Date = null			
			where apno =  @Apno 
		end
	END
	else
	begin
			--added by santosh for callbacks to Direct (1 step) integrations (TMHS, HRSOFT etc.)
			update [dbo].[Integration_PrecheckCallback]
			set   Process_Callback_Final = 1,
				  Callback_Final_Date = null			
			where apno =  @Apno 
	end
	
END














