-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmplAutoFaxPending]
(@type int,@search varchar(50))
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if @type = 0 
BEGIN
SELECT (SELECT TOP 1 recordStatus FROM LightningFaxStatus 
WHERE Subject = Convert(varchar(50),a.APNO) + '-' + Convert(varchar(50),a.EmplID) order by CreatedDate DESC) as CurrentStatus,a.FaxID,a.APNO,a.EmplID,a.Employer,a.First,a.Last,a.Fax,a.Phone,a.Completed,a.DateSent,a.DateExpected,a.CurrentExpected,a.Note,a.LastUpdate,a.UserName,a.Client,a.ClientEmployerID
FROM EmplAutoFaxLog a inner join Empl b on a.EmplID = b.EmplID
WHERE Completed = 0 AND (b.SectStat = '0' OR b.SectStat = '9') ORDER BY DateSent DESC
END

if @type = 1
BEGIN

SELECT (SELECT TOP 1 recordStatus FROM LightningFaxStatus WHERE Subject = Convert(varchar(50),a.APNO) + '-' + Convert(varchar(50),a.EmplID) order by CreatedDate DESC) as CurrentStatus,a.FaxID,a.APNO,a.EmplID,a.Employer,a.First,a.Last,a.Fax,a.Phone,a.Completed,a.DateSent,a.DateExpected,a.CurrentExpected,a.Note,a.LastUpdate,a.UserName,a.Client,a.ClientEmployerID 
FROM EmplAutoFaxLog a inner join Empl b on a.EmplID = b.EmplID 
WHERE Completed = 0 AND (b.SectStat = '0' OR b.SectStat = '9') 
AND a.APNO = @search  ORDER BY DateSent DESC
				



END

if @type = 2
BEGIN

SELECT (SELECT TOP 1 recordStatus FROM LightningFaxStatus WHERE Subject = Convert(varchar(50),a.APNO) + '-' + Convert(varchar(50),a.EmplID) order by CreatedDate DESC) as CurrentStatus,a.FaxID,a.APNO,a.EmplID,a.Employer,a.First,a.Last,a.Fax,a.Phone,a.Completed,a.DateSent,a.DateExpected,a.CurrentExpected,a.Note,a.LastUpdate,a.UserName,a.Client,a.ClientEmployerID 
FROM EmplAutoFaxLog a inner join Empl b on a.EmplID = b.EmplID 
WHERE Completed = 0 AND (b.SectStat = '0' OR b.SectStat = '9') 
AND a.Last like @search + '%'  ORDER BY DateSent DESC



END

if @type = 3
BEGIN

SELECT (SELECT TOP 1 recordStatus FROM LightningFaxStatus WHERE Subject = Convert(varchar(50),a.APNO) + '-' + Convert(varchar(50),a.EmplID) order by CreatedDate DESC) as CurrentStatus,a.FaxID,a.APNO,a.EmplID,a.Employer,a.First,a.Last,a.Fax,a.Phone,a.Completed,a.DateSent,a.DateExpected,a.CurrentExpected,a.Note,a.LastUpdate,a.UserName,a.Client,a.ClientEmployerID 
FROM EmplAutoFaxLog a inner join Empl b on a.EmplID = b.EmplID 
WHERE Completed = 0 AND (b.SectStat = '0' OR b.SectStat = '9') 
AND a.Employer like @search + '%'  ORDER BY DateSent DESC



END
		
END
