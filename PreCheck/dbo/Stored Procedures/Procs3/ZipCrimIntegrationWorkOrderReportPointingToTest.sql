-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 04/02/2020
-- Description:	/*Q-Report for the business to identify zipcrim work orders */
--Execute [ZipCrimIntegrationWorkOrderReport] 4516563
--Execute [ZipCrimIntegrationWorkOrderReport] 0,'07/22/2019',null
-- Execute [ZipCrimIntegrationWorkOrderReportPointingToTest] 0,'04/09/2020','05/27/2020'
-- Modified by Humera Ahmed on 3/16/2020 for HDT#70025 - Please add Client Name after the CLNO column
-- =============================================
CREATE PROCEDURE [dbo].[ZipCrimIntegrationWorkOrderReportPointingToTest]
	@orderNumber int = 0,
	@startDate date = '1/1/1900',
	@endDate date = '1/1/1900'
AS
BEGIN

	SELECT 
		zcwo.APNO,Apstatus,Apdate,Investigator, 
		--LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(Priv_notes,CHAR(9),''),CHAR(10),''),CHAR(13),''))) as Priv_notes,
		zcwo.WorkOrderID,
		zcwos.PartnerReference AS 'Case Number', 
		a.CLNO [Client Number], 
		c.Name [Client Name], --Humera Ahmed on 3/16/2020 for HDT#70025 - Please add Client Name after the CLNO column
		c.ZipCrimClientID AS 'ZipCrim Client Code', 
		a.PackageID,
		cp.ZipCrimClientPackageID AS 'ZipCrim Case Type',
		rwos.ItemName AS 'Integration Status',
		zcwo.SubmitWorkOrderAttempts,
		zcwo.GetLeadsAttempts,
		zcwo.CreateDate,
		zcwo.ModifyDate
	FROM [Hou-SQLTEST-01].[PreCheck_PreProd].dbo.ZipCrimWorkOrders zcwo with (NOLOCK)
	INNER JOIN [Hou-SQLTEST-01].[PreCheck_PreProd].dbo.refWorkOrderStatus rwos ON zcwo.refWorkOrderStatusID = rwos.refWorkOrderStatusID
	INNER JOIN [Hou-SQLTEST-01].[PreCheck_PreProd].dbo.Appl a with (NOLOCK) ON zcwo.APNO = a.APNO
	INNER JOIN [Hou-SQLTEST-01].[PreCheck_PreProd].dbo.Client c with (NOLOCK) ON a.CLNO = c.CLNO
	LEFT JOIN [Hou-SQLTEST-01].[PreCheck_PreProd].dbo.ClientPackages cp with (NOLOCK) ON a.CLNO = cp.CLNO AND a.PackageID = cp.PackageID
	INNER JOIN [Hou-SQLTEST-01].[PreCheck_PreProd].dbo.ZipCrimWorkOrdersStaging zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
	WHERE (@orderNumber =0 OR zcwo.APNO = @orderNumber OR zcwo.WorkOrderID = @orderNumber OR cast(zcwos.PartnerReference AS int) = @orderNumber)
	AND (@startDate ='1/1/1900' OR cast(zcwo.CreateDate AS Date)  >= @startDate)
	AND (@endDate ='1/1/1900' OR cast(zcwo.CreateDate AS Date)  <= @endDate)
	ORDER BY a.APNO DESC
END
