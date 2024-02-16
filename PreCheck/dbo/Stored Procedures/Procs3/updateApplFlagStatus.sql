






-- =============================================
-- Author:		<Bhavana Bakshi>
-- Create date: <04/25/2008>
-- Description:	<To update applicaton's flag status from OASIS when the application in finaled>
--  Flag  Description
--  1      Clear
--  2      Needs Review
-- =============================================
CREATE PROCEDURE [dbo].[updateApplFlagStatus]
	@apno int
AS
BEGIN
	SET NOCOUNT OFF;

DECLARE @ApStatus char(1),@Flag int,@CLNO int,@adjreview varchar(50),@tmpFlag int;

SET @CLNO = (select clno from appl where apno = @apno);
SET @adjreview = (select value from clientconfiguration where configurationkey = 'AdjudicationProcess' and clno = @CLNO);






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
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno),0)
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag	
	
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM educat  WITH (NOLOCK)WHERE isonreport = 1 and ishidden = 0 and apno = @apno),0)
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno),0) 
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno),0) 
	IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM medinteg  WITH (NOLOCK )WHERE ishidden = 0 and apno = @apno),0)
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM dl  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno),0) 
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag
	
SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno),0)
IF @tmpFlag > @Flag
		set @Flag =  @tmpFlag

SET @tmpFlag = ISNULL((SELECT max(clientadjudicationstatus) FROM credit WITH (NOLOCK )WHERE ishidden = 0 and apno = @apno),0)
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
	IF(SELECT count(apno) FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
	BEGIN
		set @Flag =  2 --Needs review
	END
	
	IF(SELECT count(apno) FROM educat  WITH (NOLOCK)WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
	BEGIN
		set @Flag =  2
	END
	
	IF(SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0 
	BEGIN
		set @Flag =  2
	END 
	
	IF(SELECT count(apno) FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0 
	BEGIN
		set @Flag =  2
	END
	
	IF(SELECT count(apno) FROM medinteg  WITH (NOLOCK )WHERE ishidden = 0 and apno = @apno AND sectstat NOT IN ('1', '3') )>0
	BEGIN
		set @Flag =  2
	END 
	
	IF(SELECT count(apno) FROM dl  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0 
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
		INSERT INTO ApplFlagStatus(APNO,FlagStatus) 
		VALUES (@apno,@Flag)
	END
ELSE
	BEGIN
	   UPDATE ApplFlagStatus SET FlagStatus = @Flag WHERE APNO=@apno
	END
END
	
END








