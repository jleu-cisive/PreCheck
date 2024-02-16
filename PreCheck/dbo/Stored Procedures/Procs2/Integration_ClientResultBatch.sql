









-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Integration_ClientResultBatch]
	-- Add the parameters for the stored procedure here
	@CLNO int, @SPMode int, @DATEREF datetime
AS
BEGIN

DECLARE @APNO int;


DECLARE @TABLE TABLE  ( Date varchar(20), ClientApplicationNumber VARCHAR( 50 ), SectionType INT, Status INT, SectionCount INT)
DECLARE @CLIENTAPNO VARCHAR( 50 ),@CompletedDate varchar(20),@DATESTART datetime;

--set @DATEREF  = '9/7/11 4:00 PM ' 
--allow 10 min of delay
SET @DATEREF =   DATEADD(mi,-10,@DATEREF);
SET @DATESTART = DATEADD(mi,-60,@DATEREF);


DECLARE RESULT_CURSOR CURSOR FOR
SELECT a.APNO FROM appl a (NOLOCK) where a.apstatus = 'F' and a.clno = @CLNO and 
ISNULL(clientapno,'') <> ''  and a.compdate >= @DATESTART and a.compdate < @DATEREF 
--((ISNULL(clientapno,'') <> ''  and a.compdate >= @DATESTART and a.compdate < @DATEREF )
--or  ISNULL(clientapno,'') in ('10896','24671','24800','16962'))

--(select count(*) from reportuploadlog (NOLOCK) where reportid = a.apno and clno = @CLNO and reporttype = 3) = 0
OPEN RESULT_CURSOR;
FETCH NEXT FROM RESULT_CURSOR INTO @APNO;
WHILE @@FETCH_STATUS = 0
	BEGIN
		--------------------------------
	

select @CLIENTAPNO = clientapno,
--@CompletedDate = compdate
 @CompletedDate = '' + cast(DATEPART(mm,compdate) as varchar) + '-' + cast(DATEPART(dd,compdate) as varchar)+ '-' + cast(DATEPART(yyyy,compdate) as varchar) + ' ' + cast(DATEPART(hh,compdate) as varchar) + ':' + cast(DATEPART(mi,compdate) as varchar)
  from appl where apno = @APNO;
		
if(@SPMode = 1)
BEGIN
INSERT INTO @TABLE
(Date,ClientApplicationNumber,SectionType,Status,SectionCount)
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,3 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM empl  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,2 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM educat  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM educat  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,5 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE ISNULL(lic_type,'') <> 'NURSE AIDE ABUSE REGISTRY' AND isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE ISNULL(lic_type,'') <> 'NURSE AIDE ABUSE REGISTRY' AND isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,21 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE ISNULL(lic_type,'') = 'NURSE AIDE ABUSE REGISTRY' AND isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')
	AND not pub_notes like '%no record found%') >0			
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,4 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM persref  WITH (NOLOCK) WHERE isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,22 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM medinteg   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno AND sectstat NOT IN ('1','3')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM medinteg   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,6 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM crim   WITH (NOLOCK) WHERE cnty_no <> 2480 and ishidden = 0 and apno = @apno AND clear  <> 'T') >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no <> 2480) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,20 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM crim   WITH (NOLOCK) WHERE cnty_no = 2480 and ishidden = 0 and apno = @apno AND clear  <> 'T') >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM crim  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno and cnty_no = 2480) as 'SectionCount'
UNION
SELECT @CompletedDate AS Date,@CLIENTAPNO as ClientApplicationNumber,23 As 'SectionType',
	CASE WHEN (SELECT count(apno) FROM dl   WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno AND sectstat NOT IN ('1','3')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM dl  WITH (NOLOCK) WHERE ishidden = 0 and apno = @apno) as 'SectionCount'

END
		--------------------------------
		FETCH NEXT FROM RESULT_CURSOR INTO @APNO;
	END
CLOSE RESULT_CURSOR;
DEALLOCATE RESULT_CURSOR;


SELECT  cast(Date as char) as Date,cast(ClientApplicationNumber as char) as ClientApplicationNumber,
cast(SectionType as char) as SectionType,cast(Status as char) as Status,cast(SectionCount as char) as SectionCount FROM @TABLE
WHERE SectionCount > 0;


END










