
CREATE PROCEDURE [dbo].[Service_AutoPrintUpdate] @MyApno int  AS
BEGIN
	if (Select count(1) FROM BackgroundReports.DBO.BackgroundReport WHERE apno = @MyApno and cast(createdate as varchar(12)) = cast(getdate() as varchar(12))) >= 1
		update dbo.appl
		set isautoprinted = '1',AutoPrintedDate = getdate(),
		InUse = null
		where apno = @MyApno
	else
		Insert into BackgroundReports.DBO.BackgroundErrorLog (apno,error) values (@MyApno,'Report not generated')

END