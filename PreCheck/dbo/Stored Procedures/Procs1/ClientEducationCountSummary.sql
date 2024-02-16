--dbo.ClientEducationCountSummary '01/14/2018','01/16/2018'
CREATE PROCEDURE [dbo].[ClientEducationCountSummary] 
(@StartDate Date,@EnDate Date,@ReportStatus char(1)='',@CAM varchar(20)='')
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION	ISOLATION LEVEL	READ UNCOMMITTED

	SELECT A.Apno ReportNumber,A.ApStatus [Report Status],A.UserID CAM,A.CLNO,C.[Name] [Client Name],
	EnteredVia,Replace(Replace(cast(R.Request.query('<E>{count(/Application/NewApplicant/Education)}</E>') AS varchar),'<E>',''),'</E>','')  [XML Education Count],
	(SELECT count(1) FROM dbo.Educat WHERE Apno = A.Apno ) [Total Educations Count],
	(SELECT count(1) FROM dbo.Educat WHERE Apno = A.Apno AND dbo.Educat.IsOnReport	=1) [Internal Education Ordered Count],
	A.Priv_Notes,Case when isnull(InProgressReviewed,0) =0 THEN 'No' ELSE 'Yes' END [In Progress Reviewed]
	 FROM Appl A inner join client c 
	ON a.CLNO = c.CLNO
	LEFT JOIN dbo.PrecheckServiceLog R  ON A.APNO = R.APNO AND R.ServiceName='PrecheckWebService'
	WHERE cast(a.apdate as Date) BETWEEN @StartDate AND @EnDate
	AND ApStatus <> 'M' AND (ApStatus = @ReportStatus OR @ReportStatus = '')
	AND (A.UserID = @CAM OR @CAM = '')


	SET TRANSACTION	ISOLATION LEVEL	READ COMMITTED
	SET NOCOUNT OFF
END



 