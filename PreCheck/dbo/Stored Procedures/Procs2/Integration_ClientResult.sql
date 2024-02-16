



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Integration_ClientResult]
	-- Add the parameters for the stored procedure here
	@APNO int,@SPMode int
AS
BEGIN


--*CHC FORMAT
--Date
--ClientApplicationNumber
--CheckType
--Status
--Number of References Checked
--PDF file (or separate file per our last conference call)


--checktype
--01 – Applicant demographic Information.
--02 – Applicant school information.
--03 – Applicant employment information.
--04 – Applicants reference information.
--05 – Applicant Licensure Information
--06 – Criminal History Optional
--07 – Previous Address Optional
--08 – Credit Check Optional
--20 - Sex Offender
--21 -- Nurse Abuse Aide Registry
--22 -- Med Integ
--23 -- MVR


--grab clientapno
DECLARE @CLIENTAPNO varchar(50),@CompletedDate datetime;

select @CLIENTAPNO = clientapno, @CompletedDate =Compdate from appl where apno = @APNO;
	--verify application is finaled
IF( (SELECT ISNULL(apstatus,'') from appl (NOLOCK) where apno = @APNO) = 'F')
BEGIN

if(@SPMode = 1)
BEGIN
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
	CASE WHEN (SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE ISNULL(lic_type,'') = 'NURSE AIDE ABUSE REGISTRY' AND isonreport = 1 and ishidden = 0 and apno = @apno AND sectstat NOT IN ('3','5')) >0
			THEN 1 ELSE 0 END AS 'Status',
		(SELECT count(apno) FROM proflic  WITH (NOLOCK) WHERE ISNULL(lic_type,'') = 'NURSE AIDE ABUSE REGISTRY' AND isonreport = 1 and ishidden = 0 and apno = @apno) as 'SectionCount'
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


END



END




