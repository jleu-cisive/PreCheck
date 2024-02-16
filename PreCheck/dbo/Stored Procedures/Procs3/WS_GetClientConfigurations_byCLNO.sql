
create PROCEDURE [dbo].[WS_GetClientConfigurations_byCLNO] 
	@CLNO int
AS
SELECT ConfigurationKey,  Value from ClientConfiguration where clno=@CLNO or clno=0