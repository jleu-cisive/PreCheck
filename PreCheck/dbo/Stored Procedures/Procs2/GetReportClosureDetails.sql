-- =============================================
-- Author:		Liel Alimole
-- Create date: 08/26/2013
-- Description:	Determines who was assigned a report and who actually closed it
-- Modified By radhika Dereddy on 07/19/2019 for HDT 55000 and changed the logic to use inner joins
-- =============================================
CREATE PROCEDURE  [dbo].[GetReportClosureDetails]
	-- Add the parameters for the stored procedure here
@ReportNumber varchar(200) = '',
@CAM VarChar(1000) = '',
@StartDate Datetime = null,
@EndDate Datetime = null
AS
BEGIN

DECLARE @charint Int = 70
DECLARE @status VarChar(1000) = 'F'
DECLARE @tablename VarChar(1000) = 'Appl.ApStatus'
DECLARE @space NVarChar(1000) = ' '
DEclare @ReportNumberConv int = 0


if(ISNUMERIC(@ReportNumber) = 1 )

set @ReportNumberConv = CAST(@ReportNumber AS INT) 

if(@ReportNumberConv > 0)

SELECT a.Apdate AS [AppCreatedDate], cl.ChangeDate AS [ClosedDate], case when cl.ChangeDate = a.OrigCompDate then 'True' else 'False' end as 'Is Original completion Date',
a.OrigCompDate as 'OriginalCompletionDate', a.APNO AS [ReportNumber], (a.First + @space + a.Last) AS [ApplicantName], 
C.Name AS [ClientName], a.UserID AS [CamAssigned],cl.UserID AS [ClosedBy]
FROM Appl a
inner join Client C on a.clno = C.clno
inner join ChangeLog cl on a.apno = cl.id 
WHERE (a.APNO = @ReportNumberConv)
AND (UNICODE(a.ApStatus) = @charint)
AND (cl.NewValue = @status) 
AND (cl.TableName = @tablename) 

else

if(len(@CAM) > 0)

	if(@StartDate is not null and @EndDate is not null)

		SELECT a.Apdate AS [AppCreatedDate], cl.ChangeDate AS [ClosedDate], case when cl.ChangeDate = a.OrigCompDate then 'True' else 'False' end as 'Is Original completion Date',
		a.OrigCompDate as 'OriginalCompletionDate', a.APNO AS [ReportNumber], (a.First + @space + a.Last) AS [ApplicantName], 		
		C.Name AS [ClientName], a.UserID AS [CamAssigned],cl.UserID AS [ClosedBy]
		FROM Appl a
		inner join Client C on a.clno = C.clno
		inner join ChangeLog cl on a.apno = cl.id 
		where a.UserID =@CAM
		AND UNICODE(a.ApStatus) = @charint
		AND cl.NewValue =@status
		AND cl.TableName =@tablename
		AND (Convert(date, cl.ChangeDate) >= @StartDate) AND (Convert(date, cl.ChangeDate) <= @EndDate)	
	else
		Select '*Error: please enter a valid date range'
else

if(@StartDate is not null and @EndDate is not null)
	
	if(len(@CAM) <= 0)

		SELECT a.Apdate AS [AppCreatedDate], cl.ChangeDate AS [ClosedDate],case when cl.ChangeDate = a.OrigCompDate then 'True' else 'False' end as 'Is Original completion Date', 
		a.OrigCompDate as 'OriginalCompletionDate', a.APNO AS [ReportNumber], (a.First + @space + a.Last) AS [ApplicantName],		
		C.Name AS [ClientName], a.UserID AS [CamAssigned],cl.UserID AS [ClosedBy]
		FROM Appl a
		inner join Client C on a.clno = C.clno
		inner join ChangeLog cl on a.apno = cl.id 
		where UNICODE(a.ApStatus) = @charint
		AND cl.NewValue =@status
		AND cl.TableName =@tablename
		AND (Convert(date, cl.ChangeDate) >= @StartDate) AND (Convert(date, cl.ChangeDate) <= @EndDate)	

END
