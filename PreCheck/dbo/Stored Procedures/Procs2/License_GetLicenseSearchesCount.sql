-- =============================================
-- Author:		An Vo
-- Create date: 4/13/2018
-- Description:	This returns how many public record searches that go through Mozenda given a date range.
-- =============================================
CREATE PROCEDURE [dbo].[License_GetLicenseSearchesCount]--'2017-09-10 05:00:00','2018-09-10 05:00:00','Nursys'
	 @StartDate datetime,
	 @EndDate datetime,
	 @section varchar(100) 

AS
BEGIN	
	SET NOCOUNT ON;



	Select l.SectionKeyId,sum(l.Total_Records) as Total_Records
	From dbo.DataXtract_Logging l (Nolock)
	inner join Dataxtract_RequestMapping dm on l.SectionKeyId = dm.SectionKeyID 
	Where l.Section =@Section
	and DateLogRequest between @StartDate and DateAdd(d,1, @EndDate)
	and Total_Records > 0

	group by l.SectionKeyId
END
