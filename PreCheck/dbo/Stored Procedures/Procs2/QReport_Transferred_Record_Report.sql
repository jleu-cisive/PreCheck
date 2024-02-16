-- =============================================
-- Author:		Humera ahmed
-- Create date: 11/20/2018
-- Description:	A Queue report that tells us if there is a transferred record(status I) on a report without a corresponding active crim.
--EXEC QReport_Transferred_Record_Report
-- Modified by Radhika Dereddy on 1/14/2019 - HDT 45246
-- Modified reason -I am requesting a change for the Transferred Record Report. I need the functionality of the report to stay exactly the same. 
-- However, I only want the report to show APNO's that are In-Progress and not any other status. Please see below for a screenshot that came directly out of Oasis. 
-- =============================================
CREATE PROCEDURE [dbo].[QReport_Transferred_Record_Report]
	-- Add the parameters for the stored procedure here
	--No Parameters
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @NumberRecords int, @RowCount int
	DECLARE @cnty_no int, @apno int, @clear varchar(2),@createddate datetime

    -- Insert statements for procedure here
	CREATE table #temp(RowID int IDENTITY(1, 1), cnty_no int, apno int, clear varchar(2), createddate datetime)
	INSERT INTO #temp
	SELECT distinct c.cnty_no, c.apno, c.clear, CONVERT(date,c.CreatedDate)FROM dbo.Crim c WHERE c.clear in('I')
	ORDER BY c.apno 
	--SELECT * FROM #temp ORDER BY apno

	-- Get the number of records in the temporary table
	SET @NumberRecords = @@ROWCOUNT
	SET @RowCount = 1
	WHILE @RowCount <= @NumberRecords
	BEGIN
		SELECT @cnty_no = cnty_no,@apno = apno
		FROM #temp WHERE RowID = @RowCount
		if (select count(*) from crim where apno=@apno and cnty_no=@cnty_no and clear <>'I')>=1
		begin 
			delete from #temp WHERE RowID = @RowCount
			set @cnty_no = ''
			set @apno = ''
		end
		set @RowCount = @RowCount +1
	END
	--SELECT * FROM #temp ORDER BY apno desc
	select  distinct c.apno as [APNO], c.county as [County], c.clear as [Transferred Record], convert(date,c.createddate) as [Created Date] from crim c 
	inner join #temp t on c.apno=t.apno and c.cnty_no=t.cnty_no and c.clear = t.clear
	inner join Appl a(nolock) on c.Apno = a.Apno
	Where a.Apstatus ='P'
	ORDER BY c.apno desc
	DROP TABLE #temp

	
END
