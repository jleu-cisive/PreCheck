-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 03/08/2017
-- Description:	----295--,--'01/01/2011'--
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_PublicRecords_Log] 
	-- Add the parameters for the stored procedure here
	@countyid varchar(10),
	@datefrom varchar(20),
	@dateto varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select [DataXtract_LoggingId] LogId,ResponseError, ResponseStatus, DateLogRequest,DateLogResponse,LogUser,cast(Request as xml).value('(count(//Item))[1]','int') Total_Request_Items,cast(Response as xml).value('(count(//Item))[1]','int') Total_Response_Items,Total_Records, Total_Clears, Total_Exceptions, cast(Response as xml).value('count(//NoRecord[not(text())])', 'int') Total_Hits From dbo.DataXtract_Logging (Nolock) 
	Where Section = 'Crim' and SectionKeyID = @countyid and DateLogRequest between @datefrom and DateAdd(d,1,@dateto)
	order by DateLogRequest asc
END
