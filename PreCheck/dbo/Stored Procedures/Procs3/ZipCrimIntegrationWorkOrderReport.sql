-- =============================================
-- Author:		/*Yves Fernandes*/
-- Create date: /*07/23/19*/
-- Description:	/*Q-Report for the business to identify zipcrim work orders */
--Execute [ZipCrimIntegrationWorkOrderReport] 4516563
--Execute [ZipCrimIntegrationWorkOrderReport] 0,'07/22/2019',null
--Execute [ZipCrimIntegrationWorkOrderReport] 0,'11/22/2019','03/16/2020'
-- Modified by Humera Ahmed on 3/16/2020 for HDT#70025 - Please add Client Name after the CLNO column
-- Modified by Humera Ahmed on 06/04/2020 for HDT#73469 - Please add Affiliate column to the output of this existing qreport
-- Modified by Radhika Dereddy on 06/11/2020 - Added this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) 
-- and many of more so adding the max length of the excel to accommodate the export.
-- =============================================
CREATE PROCEDURE [dbo].[ZipCrimIntegrationWorkOrderReport]
	@orderNumber int = 0,
	@startDate date = '1/1/1900',
	@endDate date = '1/1/1900'
AS
BEGIN

	SELECT 
		zcwo.APNO,Apstatus,Apdate,Investigator, Replace(REPLACE(Priv_Notes , char(10),';'),char(13),';') as 'PrivateNotes',
		zcwo.WorkOrderID,
		zcwos.PartnerReference AS 'Case Number', 
		a.CLNO [Client Number], 
		c.Name [Client Name], 
		ra.Affiliate,
		c.ZipCrimClientID AS 'ZipCrim Client Code', 
		a.PackageID,
		cp.ZipCrimClientPackageID AS 'ZipCrim Case Type',
		rwos.ItemName AS 'Integration Status',
		zcwo.SubmitWorkOrderAttempts,
		zcwo.GetLeadsAttempts,
		zcwo.CreateDate,
		zcwo.ModifyDate
	FROM dbo.ZipCrimWorkOrders zcwo with (NOLOCK)
	INNER JOIN dbo.refWorkOrderStatus rwos ON zcwo.refWorkOrderStatusID = rwos.refWorkOrderStatusID
	INNER JOIN dbo.Appl a with (NOLOCK) ON zcwo.APNO = a.APNO
	INNER JOIN dbo.Client c with (NOLOCK) ON a.CLNO = c.CLNO
	INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID
	LEFT JOIN dbo.ClientPackages cp with (NOLOCK) ON a.CLNO = cp.CLNO AND a.PackageID = cp.PackageID
	LEFT JOIN dbo.ZipCrimWorkOrdersStaging zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
	WHERE (@orderNumber =0 OR zcwo.APNO = @orderNumber OR zcwo.WorkOrderID = @orderNumber OR cast(zcwos.PartnerReference AS int) = @orderNumber)
	AND (@startDate ='1/1/1900' OR cast(zcwo.CreateDate AS Date)  >= @startDate)
	AND (@endDate ='1/1/1900' OR cast(zcwo.CreateDate AS Date)  <= @endDate)
	and LEN(Replace(REPLACE(Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/11/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.

END
