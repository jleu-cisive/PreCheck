-- Alter Procedure IRIS_Measurement_Rpt
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[IRIS_Measurement_Rpt] @StartDate = '07/21/2015',@EndDate='07/21/2015'
--[IRIS_Measurement_Rpt] null,null,0,0,null,null,null,null

CREATE PROCEDURE [dbo].[IRIS_Measurement_Rpt]
	-- Add the parameters for the stored procedure here
  @Investigator varchar(8) = null, 
  @Category varchar(20) = null,
  @CategoryID int = 0,
  @CLNO int = 0,
  @State varchar(20) = null,
  @County varchar(50) = null,
  -- @APNO int = null,
  @StartDate datetime = null,
  @EndDate datetime = null

  
AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @StartDate = CAST(getdate() as date)
	SET @EndDate = @StartDate
    

	SELECT @CategoryID = ResultLogCategoryID FROM dbo.IRIS_ResultLogCategory WHERE ResultLogCategory = @Category
	SET @CategoryID = ISNULL(@CategoryID, 0)

	SELECT '' FileType,i.Investigator
	,(SELECT ResultLogCategory FROM dbo.IRIS_ResultLogCategory with (nolock) WHERE ResultLogCategoryID = i.ResultLogCategoryID) AS Category
	,CASE	WHEN i.Clear = 'T' THEN 'Clear'
			WHEN i.Clear = 'F' THEN 'Record Found'
			WHEN i.Clear = 'P' THEN 'Possible Record'
			WHEN i.Clear = 'Q' THEN 'Needs QA'
			WHEN i.Clear = 'I' THEN 'Needs Research'
			ELSE 'Ordered' 
	END AS Status
	,COUNT(ResultLogID) AS RecordCount--, i.Apno as APNO 
	FROM dbo.IRIS_ResultLog i with (NOLOCK) inner join crim c with (nolock) on i.crimid = c.crimid 
	inner join dbo.TblCounties cc with (nolock) on cc.cnty_no = c.cnty_no 
	left join appl a with (nolock) on i.apno = a.apno
	WHERE i.Clear IN ('T','F','Q','I','P') AND i.LogDate >= @StartDate AND i.LogDate < DATEADD(day, 1,@EndDate)
	AND i.Investigator =  isnull(@Investigator,i.Investigator)
	AND i.ResultLogCategoryID = iif(@CategoryID = 0,i.ResultLogCategoryID,@CategoryID)
	AND a.clno = iif(@CLNO = 0,a.clno,@CLNO)
	AND cc.state = isnull(@State,cc.state)
	AND c.county = isnull(@County,c.county)
	GROUP BY i.Investigator, i.ResultLogCategoryID, i.Clear



End
