-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- EXEC IdentifySJVMissingNotes'03/04/2020','03/05/2020',NULL
CREATE PROCEDURE [dbo].[IdentifySJVMissingNotes] 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime=NULL,
	@EndDate DateTime=NULL,
	@OrderId NVARCHAR(MAX)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SET @StartDate=ISNULL(@StartDate,GETDATE());
   SET @EndDate=ISNULL(@EndDate,GETDATE());
   DECLARE @VendorName NVARCHAR(100)='SJV';
   DECLARE @TempTotalResult TABLE(VendorOrderId BIGINT,OrderId NVARCHAR(max),Operation NVARCHAR(100),CreationDate DateTime);

   INSERT INTO @TempTotalResult(VendorOrderId,OrderId,Operation,CreationDate)
   Select Integration_VendorOrderId,
		  Response.value('(//SubjectCtyID)[1]','varchar(max)'),
		  VendorOperation,
		  CreatedDate from dbo.Integration_VendorOrder
	 where VendorName='SJV' and 
	 VendorOperation IN('InProgress','Acknowledgement','Completed') and
	 CONVERT(Date,CreatedDate)>=CONVERT(Date,@StartDate) and
	 CONVERT(Date,CreatedDate)<=CONVERT(Date,@EndDate);

	DECLARE @TempCount TABLE(OrderId NVARCHAR(max),Operation NVARCHAR(100),RequestCount BIGINT);

	INSERT INTO @TempCount
	SELECT OrderId, Operation,Count(OrderId) As RequestCount FROM @TempTotalResult 	
	where OrderId Is NOT NULL
	GROUP BY Operation, OrderId;

	SELECT  T.OrderId,T.TotalInProgress,T.TotalCompleted,T.TotalAcknowledgement from(
	SELECT DISTINCT
	t1.OrderId,
	ISNULL((Select RequestCount from @TempCount t2 where t2.OrderId=t1.OrderId and Operation='Acknowledgement'),0) AS TotalAcknowledgement,
	ISNULL((Select RequestCount from @TempCount t2 where t2.OrderId=t1.OrderId and Operation='Completed'),0) AS TotalCompleted,
	ISNULL((Select RequestCount from @TempCount t2 where t2.OrderId=t1.OrderId and Operation='InProgress'),0) AS TotalInProgress
	 from @TempCount t1
	 Group By t1.OrderId) AS T
	 WHERE (T.TotalInProgress+T.TotalCompleted)!=T.TotalAcknowledgement

--	IF(@OrderId IS NOT NULL)
--	BEGIN
--		SELECT * FROM @ResultTemp;
--	END
--	ELSE
--	BEGIN
--		SELECT * FROM @ResultTemp WHERE OrderId=@OrderId;
--	END
END
