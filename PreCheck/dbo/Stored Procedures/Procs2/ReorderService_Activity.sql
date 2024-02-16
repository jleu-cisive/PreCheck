-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE DBO.ReorderService_Activity 
	-- Add the parameters for the stored procedure here
@StartDate DATE =null,@EndDate DATE=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF @StartDate IS NULL AND @EndDate IS NULL
		Begin
			SET @StartDate = CAST(CURRENT_TIMESTAMP AS DATE)
			SET @EndDate = DATEADD(DAY,1,@StartDate)
		END
    ELSE
		SET @EndDate = DATEADD(DAY,1,@EndDate)



    -- Insert statements for procedure here
	SELECT APNO,County,S.crimdescription OldStatus,S1.crimdescription NewStatus,L.Createddate [Updated On]  
	FROM [Crim_Review_ReOrderService_Log] L INNER JOIN dbo.Crimsectstat S ON L.OldStatus = S.crimsect
											INNER JOIN dbo.Crimsectstat S1 ON L.NewStatus = S1.crimsect
	WHERE Createddate BETWEEN @StartDate AND @EndDate

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
END
