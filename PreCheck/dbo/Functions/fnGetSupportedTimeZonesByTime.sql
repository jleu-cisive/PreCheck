

-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 12/14/2015
-- Description:	To return the Suggested Time Zone for a given time
-- =============================================
CREATE FUNCTION [dbo].[fnGetSupportedTimeZonesByTime]
(@CurrentTime Time )
RETURNS 
@SupportedTimeZones TABLE 
(
TimeZone varchar(30)
)
AS
BEGIN
	if (@CurrentTime >= '6:00' and @CurrentTime <= '17:00')
		Insert @SupportedTimeZones (TimeZone) values ('Eastern');

	if (@CurrentTime >= '7:00' and @CurrentTime <= '18:00')
		Insert @SupportedTimeZones (TimeZone) values ('Central');

	if (@CurrentTime >= '8:00' and @CurrentTime <= '18:00')
		Insert @SupportedTimeZones (TimeZone) values ('Mountain');

	if (@CurrentTime >= '9:00' and @CurrentTime <= '19:00')
		Insert @SupportedTimeZones (TimeZone) values ('Pacific');
	
	if (@CurrentTime >= '10:00' and @CurrentTime <= '20:00')
		Insert @SupportedTimeZones (TimeZone) values ('Alaska');

	if (@CurrentTime >= '11:00' and @CurrentTime <= '21:00')
		Insert @SupportedTimeZones (TimeZone) values ('Hawaii-Aleutian');

	--Default the timezone to central if nothing happens
	IF (Select COUNT(1) from @SupportedTimeZones) = 0
		Insert @SupportedTimeZones (TimeZone) values ('Central');

	RETURN 
END


