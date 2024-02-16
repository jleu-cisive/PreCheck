-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 4/28/2020
-- Description:	<Description,,>
-- SELECT * FROM [Job].[GetHistoricalSalesData]('1/1/2020', '1/10/2020' , 'I')
-- SELECT * FROM [Job].[GetHistoricalSalesData]('1/1/2020', '1/10/2020' , 'R')
-- SELECT * FROM [Job].[GetHistoricalSalesData]('1/1/2020', '1/10/2020' , 'C')
-- SELECT * FROM [Job].[GetHistoricalSalesData]('1/1/2020', '2/1/2020' , NULL)
-- =============================================
CREATE PROC [Job].[GetHistoricalSalesData](@StartDate DATE, @EndDate DATE, @DataType varchar(1) NULL)
	--RETURNS @Result TABLE(OrderDate DATE, ClientId INT, EnteredVia VARCHAR(10), PackageId INT NULL, PackageName VARCHAR(200) NULL, PackagePrice MONEY NULL, 
	--OrderReceiveCount INT NULL, OrderCloseCount INT NULL, OrderInviteCount INT NULL, Sales SMALLMONEY null)
AS
BEGIN
	DECLARE @Result TABLE(OrderDate DATE, ClientId INT, EnteredVia VARCHAR(10), PackageId INT NULL, PackageName VARCHAR(200) NULL, PackagePrice MONEY NULL, 
	OrderReceiveCount INT NULL, OrderCloseCount INT NULL, OrderInviteCount INT NULL, Sales SMALLMONEY null)

	--IF(@StartDate IS NULL)
	--	SET @StartDate = (SELECT MIN(createdDate) FROM [ala-db-01].Precheck.dbo.Appl)
	--IF(@EndDate IS NULL)
	--	SET @EndDate = (SELECT max(createdDate) FROM [ala-db-01].Precheck.dbo.Appl)
    DECLARE @OrdersReceived TABLE(OrderDate DATE, ClientId INT, EnteredVia VARCHAR(10), PackageId INT NULL, PackageName VARCHAR(200) NULL, PackagePrice MONEY NULL, 
	OrderReceiveCount INT NULL, OrderCloseCount INT NULL, OrderInviteCount INT NULL, Sales SMALLMONEY null)

	DECLARE @OrdersClosed TABLE(OrderDate DATE, ClientId INT, EnteredVia VARCHAR(10), PackageId INT NULL, PackageName VARCHAR(200) NULL, PackagePrice MONEY NULL, 
	OrderReceiveCount INT NULL, OrderCloseCount INT NULL, OrderInviteCount INT NULL, Sales SMALLMONEY null)

	/*
	IF(@DataType IS NULL OR @DataType='I')
	INSERT INTO @Result
	(
	    OrderDate,
	    ClientId,
	    EnteredVia,
	    PackageId,
	    PackageName,
	    PackagePrice,
	    OrderInviteCount,
		OrderReceiveCount,
	    OrderCloseCount,
	    Sales
	)
	SELECT
		OrderDate=CAST(o.CreateDate AS DATE),
		ClientId=o.FacilityId,
		EnteredVia=CASE WHEN o.BatchOrderDetailId IS NULL THEN 'CIC' ELSE 'MCIC' END,
		--JSON_VALUE(o.JsonContent,'$.Services[0].BusinessPackageId'),
		--pkg.[PackageDesc],
		PackageId=NULL,
		PackageName=NULL,
		PackagePrice=null,
		Invitations=COUNT(o.stagingorderid),
		OrderReceived=NULL,
		OrderClose=NULL,
		Sales=NULL
	FROM
	[ALA-DB-01].Enterprise.staging.OrderStage o WITH(NOLOCK)
		--INNER JOIN [ALA-DB-01].PreCheck.dbo.PackageMain pkg WITH(NOLOCK) ON JSON_VALUE(o.JsonContent,'$.Services[0].BusinessPackageId')=pkg.PackageId 
			WHERE o.CreateDate BETWEEN @StartDate AND @EndDate
			AND o.DASourceId=2
--		AND o.Facilityid=3468
     GROUP BY CAST(o.CreateDate AS DATE), O.FacilityId
	 --, JSON_VALUE(o.JsonContent,'$.Services[0].BusinessPackageId'),
	 ,o.BatchOrderDetailId--, pkg.[PackageDesc]
	 --Orders received
	 
	 */

	 IF(@DataType IS NULL OR @DataType='R')
	 BEGIN
	 INSERT INTO @OrdersReceived
	 (
	     OrderDate,
	     ClientId,
	     EnteredVia,
	     PackageId,
	     PackageName,
	     PackagePrice,
		 OrderInviteCount,
	     OrderReceiveCount,
	     OrderCloseCount,
	     Sales
	 )
	 
		SELECT
		OrderDate=CAST(r.CreatedDate AS DATE),
		ClientId=R.CLNO,
		EnteredVia=ISNULL(LTRIM(RTRIM(r.EnteredVia)),''),
		PackageId=R.PackageID,
		PackageName=r.DefaultPackageName,
		PackagePrice=r.PackagePrice,
		Invitations=null,
		OrderReceived=COUNT(R.APNO),
		OrderClose=NULL,
		Sales=NULL
	FROM
	Report.vwApplSale R WITH(NOLOCK)
	WHERE CAST(R.CreatedDate AS DATE) BETWEEN @StartDate AND @EndDate
	AND r.clno NOT IN (3468,2135,3079)
	GROUP BY CAST(R.CreatedDate AS DATE), R.CLNO, 
	R.EnteredVia, R.PackageID, R.DefaultPackageName, r.PackagePrice
	
	 MERGE @Result R USING @OrdersReceived O ON R.OrderDate=O.OrderDate AND R.ClientId=O.ClientId AND ISNULL(LTRIM(RTRIM(r.EnteredVia)),'')=ISNULL(LTRIM(RTRIM(o.EnteredVia)),'') 
	 AND ISNULL(r.PackageId,0)=ISNULL(O.PackageId,0)
	WHEN MATCHED
		THEN UPDATE SET
			r.OrderReceiveCount=O.OrderReceiveCount
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (OrderDate, ClientId, EnteredVia, PackageId, PackageName, PackagePrice, OrderReceiveCount)
		VALUES(O.OrderDate, O.ClientId, o.EnteredVia, o.PackageId, O.PackageName, O.PackagePrice, o.OrderReceiveCount);
	
	END

	IF(@DataType IS NULL OR @DataType='C')
	BEGIN
	INSERT INTO @OrdersClosed
	(
	    OrderDate,
	    ClientId,
	    EnteredVia,
	    PackageId,
	    PackageName,
	    PackagePrice,
		OrderInviteCount,
	    OrderReceiveCount,
	    OrderCloseCount,
	    Sales
	)
	
	--Closed Apps
	SELECT
		OrderDate=CAST(r.OrigCompDate AS DATE),
		ClientId=R.CLNO,
		EnteredVia=ISNULL(LTRIM(RTRIM(r.EnteredVia)),''),
		PackageId=R.PackageID,
		PackageName=r.DefaultPackageName,
		PackagePrice=r.PackagePrice,
		Invitations=NULL,
		OrderReceived=NULL,
		OrderClose=COUNT(R.APNO),
		Sales=SUM(id.FinalSales)
	FROM
	Report.vwApplSale R WITH(NOLOCK)
		inner JOIN 
		(SELECT APNO, FinalSales=SUM(Amount) from dbo.InvDetail WITH(NOLOCK) GROUP BY apno) ID
		--(SELECT APNO, FinalSales=SUM(Amount) from [ALA-DB-01].Precheck.dbo.InvDetailsParallel WITH(NOLOCK) GROUP BY apno) ID
		ON R.APNO=ID.APNO
	WHERE CAST(R.OrigCompDate AS DATE) BETWEEN @StartDate AND @EndDate
	AND r.clno NOT IN (3468,2135,3079)
	GROUP BY CAST(R.OrigCompDate AS DATE), R.CLNO, 
	R.EnteredVia, R.PackageID, R.DefaultPackageName, r.PackagePrice

	 MERGE @Result R USING @OrdersClosed O ON R.OrderDate=O.OrderDate AND R.ClientId=O.ClientId AND ISNULL(LTRIM(RTRIM(r.EnteredVia)),'')=ISNULL(LTRIM(RTRIM(o.EnteredVia)),'') 
	  AND ISNULL(r.PackageId,0)=ISNULL(O.PackageId,0)
	WHEN MATCHED
		THEN UPDATE SET
			r.OrderCloseCount=O.OrderCloseCount,
			r.Sales=o.Sales
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (OrderDate, ClientId, EnteredVia, PackageId, PackageName, PackagePrice, OrderCloseCount, Sales)
		VALUES(O.OrderDate, O.ClientId, o.EnteredVia, o.PackageId, O.PackageName, O.PackagePrice, o.OrderCloseCount, o.Sales);
	END

	SELECT * INTO Stage.SalesHistory FROM @Result
END


