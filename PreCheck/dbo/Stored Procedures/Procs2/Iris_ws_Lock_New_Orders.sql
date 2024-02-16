
CREATE PROCEDURE [dbo].[Iris_ws_Lock_New_Orders] 
	@time_stamp VARCHAR(50)
AS

BEGIN
	--Modified by Balaji/Santosh to improve performance 02/17/14
	UPDATE C SET InUseByIntegration = @time_stamp
	FROM Crim C INNER JOIN 	dbo.iris_ws_vendor_searches AS VS 
	ON C.CNTY_NO = VS.county_id AND C.vendorid = VS.vendor_id 
	AND  (C.Clear IN ('M')) and C.InUseByIntegration IS NULL

	--	UPDATE Crim SET InUseByIntegration = @time_stamp
	--WHERE crimid in 
	--( --SELECT  FROM IRIS_WS_NEW_ORDERS
	--	SELECT    C.CrimId 
	--	FROM     dbo.Crim AS C INNER JOIN
	--			 dbo.Appl AS A ON C.APNO = A.APNO INNER JOIN
	--			  dbo.iris_ws_vendor_searches AS VS ON C.CNTY_NO = VS.county_id AND C.vendorid = VS.vendor_id INNER JOIN
	--			  dbo.iris_ws_vendor_type AS VT ON VS.vendor_type_id = VT.id
	--	WHERE     (C.Clear IN ('M')) and C.InUseByIntegration IS NULL
	--) 

END
