
/*=============================================
Author		:	Shashank Bhoi
Create date	:	02/02/2024
Description	:	Taken reference of procedure [dbo].[GetReportClosureDetails] and removed/Renamed few columns and created this procedure.
SP Call		:	EXEC [dbo].[QReport_InProgress_Review_Details] @ReportNumber = '',@CAM = '',@StartDate = '2023-10-01',@EndDate ='2023-10-31'
=============================================*/
CREATE PROCEDURE  [dbo].[QReport_InProgress_Review_Details]
@ReportNumber varchar(200) = '',
@CAM VarChar(1000) = '',
@StartDate Datetime = null,
@EndDate Datetime = null
AS
BEGIN

DECLARE @charint Int = 70
DECLARE @status VarChar(1000) = 'True'
DECLARE @tablename VarChar(1000) = 'Appl.InProgressReviewed'
DECLARE @space NVarChar(1000) = ' '
DEclare @ReportNumberConv int = 0


if(ISNUMERIC(@ReportNumber) = 1 )
	SET @ReportNumberConv = CAST(@ReportNumber AS INT) 

if(@ReportNumberConv > 0)
	SELECT	A.Apdate AS [AppCreatedDate], CL.ChangeDate AS [IPRDate], 
			A.APNO AS [ReportNumber], (A.First + @space + A.Last) AS [ApplicantName], 
			A.UserID AS [CamAssigned],CL.UserID AS [ReviewedBy]
	FROM	dbo.Appl		AS A WITH (NOLOCK)
			JOIN Client		AS C WITH (NOLOCK) ON A.clno = C.clno
			JOIN ChangeLog	AS CL WITH (NOLOCK) ON A.apno = CL.id 
	WHERE	A.APNO = @ReportNumberConv
			AND CL.NewValue = @status
			AND CL.TableName = @tablename

else

if(len(@CAM) > 0)

	if(@StartDate is not null and @EndDate is not null)

		SELECT	A.Apdate AS [AppCreatedDate], CL.ChangeDate AS [IPRDate], 
				A.APNO AS [ReportNumber], (A.First + @space + A.Last) AS [ApplicantName], 		
				A.UserID AS [CamAssigned],CL.UserID AS [ReviewedBy]
		FROM	dbo.Appl		AS A WITH (NOLOCK)
				JOIN Client		AS C WITH (NOLOCK) ON A.clno = C.clno
				JOIN ChangeLog	AS CL WITH (NOLOCK) ON A.apno = CL.id 
		where	A.UserID =@CAM
				AND CL.NewValue =@status
				AND CL.TableName =@tablename
				AND (Convert(date, CL.ChangeDate) >= @StartDate) AND (Convert(date, CL.ChangeDate) <= @EndDate)	
	else
		Select '*Error: please enter a valid date range'
else

if(@StartDate IS NOT NULL AND @EndDate IS NOT NULL)
	
	if(len(@CAM) <= 0)

		SELECT	A.Apdate AS [AppCreatedDate], CL.ChangeDate AS [IPRDate],
				A.APNO AS [ReportNumber], (A.First + @space + A.Last) AS [ApplicantName],		
				A.UserID AS [CamAssigned],CL.UserID AS [ReviewedBy]
		FROM	dbo.Appl		AS A WITH (NOLOCK)
				JOIN Client		AS C WITH (NOLOCK) ON A.clno = C.clno
				JOIN ChangeLog	AS CL WITH (NOLOCK) ON A.apno = CL.id 
				AND CL.NewValue =@status
				AND CL.TableName =@tablename
				AND (Convert(date, CL.ChangeDate) >= @StartDate) AND (Convert(date, CL.ChangeDate) <= @EndDate)	

END
