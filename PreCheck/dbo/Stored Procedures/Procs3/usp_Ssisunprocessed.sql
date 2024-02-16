-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec usp_Ssisunprocessed 'cc','08/10/2019','08/15/2019'
CREATE PROCEDURE [dbo].[usp_Ssisunprocessed] 
@section varchar(10),
@startdate datetime,
@enddate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DataXtract_Loggingid ,Section,SectionKeyID,processflag,processdate,Total_Records,Total_Clears,Total_Exceptions,Total_NotFound from DataXtract_Logging 
	 where section =@section
	 and response is not null 
	 and processflag is  null 
	 and ProcessDate is null
	and DateLogResponse between @Startdate and DateAdd(d,1,@Enddate) order by 1 desc
END
