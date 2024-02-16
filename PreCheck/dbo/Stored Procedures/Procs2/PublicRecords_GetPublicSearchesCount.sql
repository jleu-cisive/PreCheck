-- Alter Procedure PublicRecords_GetPublicSearchesCount
-- =============================================
-- Author:		An Vo
-- Create date: 4/13/2018
-- Description:	This returns how many public record searches that go through Mozenda given a date range.
-- =============================================
CREATE PROCEDURE [dbo].[PublicRecords_GetPublicSearchesCount]
	 @StartDate datetime,
	 @EndDate datetime
AS
BEGIN	
	SET NOCOUNT ON;

	Select l.SectionKeyId,c.County,sum(l.Total_Records) as Total_Records, sum(l.Total_Exceptions) as Total_Exceptions, sum(l.Total_Clears) as Total_Clears
	From dbo.DataXtract_Logging l (Nolock)
	inner join dbo.TblCounties c on l.SectionKeyId = c.CNTY_NO
	Where SectionKeyID in (select SectionKeyId from Dataxtract_RequestMapping where Section ='Crim') 
	and DateLogRequest between @StartDate and DateAdd(d,1, @EndDate)
	and Total_Records > 0
	and Response is not null
--	and ResponseStatus = 'Completed'
	group by l.SectionKeyId, c.County
END
