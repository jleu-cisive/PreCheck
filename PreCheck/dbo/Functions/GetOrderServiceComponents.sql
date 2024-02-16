-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 6/2/2016
-- Description:	Function returns background check additional components
 -- PRINT  [dbo].[GetOrderServiceComponents] (32804)
-- =============================================
CREATE FUNCTION [dbo].[GetOrderServiceComponents] 
(
	-- Add the parameters for the function here
	@OrderId int
)
RETURNS varchar(max)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	DECLARE @SERVICELABEL VARCHAR(MAX)
	SELECT  @SERVICELABEL =  Coalesce(@SERVICELABEL + ', ', '') + (BS.ComponentName) 
	FROM Enterprise.[dbo].[OrderService]	OS
		INNER JOIN Enterprise.dbo.OrderServiceComponent OSC
			ON OS.OrderServiceId=OSC.OrderServiceId
		INNER JOIN Enterprise.[dbo].[BusinessServiceComponent]	BS
		ON OSC.BusinessServiceComponentId=bs.BusinessServiceComponentId
		WHERE OS.OrderId = @ORDERID
		AND OS.BusinessServiceId=1
	RETURN @SERVICELABEL
END

--SELECT * FROM dbo.OrderService WHERE OrderId=32804
--SELECT * FROM dbo.OrderServiceComponent WHERE OrderServiceId=38250

