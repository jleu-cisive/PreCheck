-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 6/2/2016
-- Description:	Function returns formatted services associated with the orderId
-- =============================================
CREATE FUNCTION [dbo].[GetOrderServicePackage] 
(
	-- Add the parameters for the function here
	@OrderId int
)
RETURNS varchar(max)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	DECLARE @SERVICELABEL VARCHAR(MAX)
	SELECT  @SERVICELABEL =  Coalesce(@SERVICELABEL + ', ', '') + (BS.ServiceName + '' + ' - ' + P.PackageDesc + ' (' + CONVERT(VARCHAR(10),OS.BusinessPackageId) + ') - ' +  ISNULL(os.Instruction,'No instructions')) 
	FROM Enterprise.[dbo].[Order] O
		INNER JOIN Enterprise.[dbo].[OrderService]	OS
		ON O.ORDERID = OS.ORDERID
		INNER JOIN Enterprise.[dbo].[BusinessService]	BS
		ON OS.BusinessServiceId = BS.BusinessServiceId
		INNER JOIN PreCheck..PackageMain P
		ON OS.BusinessPackageId=P.PackageID
		WHERE O.OrderId = @ORDERID
	RETURN @SERVICELABEL
END


