-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.ApplReporting_ApplicationAlerts
	@CLNO int,@SPMODE int,@DATEREF datetime
AS
BEGIN

DECLARE @DATESTART datetime;
SET @DATEREF =   DATEADD(mi,-10,@DATEREF);
SET @DATESTART = DATEADD(mi,-60,@DATEREF);

select apno,clno from appl with (nolock) where apdate >= @DATESTART and apdate <= @DATEREF
and clno in (1697,
2366,
2222,
2257,
1981,
1806,
5629,
3099,
3099,
2271,
2233,
1479,
1461,
2248,
2187,
1439,
2193,
3647,
2952,
2953,
2386,
2202,
2387,
4100,
2880,
2880,
3014,
4238);
END
